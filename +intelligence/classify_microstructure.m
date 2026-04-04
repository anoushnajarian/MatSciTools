function results = classify_microstructure(img, varargin)
%INTELLIGENCE.CLASSIFY_MICROSTRUCTURE Classify microstructure images by type
%   RESULTS = INTELLIGENCE.CLASSIFY_MICROSTRUCTURE(IMG) classifies a grayscale
%   microstructure image into one of three types: 'grains', 'porous', or
%   'dual_phase', using statistical features and a rule-based scoring model.
%
%   IMG is a 2D numeric matrix (uint8 or double). If IMG is a cell array of
%   images, batch classification is performed.
%
%   Optional Parameters:
%     'ShowDetails' - Print feature values and predictions (default: false)
%
%   Returns a struct with:
%     prediction    - string: 'grains', 'porous', or 'dual_phase'
%     confidence    - confidence of the prediction (0-1)
%     scores        - struct with raw scores for each class
%     probabilities - struct with softmax-normalized probabilities
%     features      - struct with all extracted feature values
%
%   For batch mode (cell array input), returns:
%     predictions   - cell array of prediction strings
%     confidences   - vector of confidence values
%     individual    - cell array of per-image result structs
%
%   Example:
%     [img, ~] = microstructure.generate_synthetic('Type', 'grains');
%     result = intelligence.classify_microstructure(img);
%     fprintf('Predicted: %s (%.1f%% confidence)\n', result.prediction, result.confidence*100);

    p = inputParser;
    addRequired(p, 'img');
    addParameter(p, 'ShowDetails', false, @islogical);
    parse(p, img, varargin{:});
    opts = p.Results;

    % Batch mode: cell array of images
    if iscell(img)
        n = numel(img);
        results = struct();
        results.predictions = cell(1, n);
        results.confidences = zeros(1, n);
        results.individual = cell(1, n);
        for i = 1:n
            r = intelligence.classify_microstructure(img{i}, 'ShowDetails', opts.ShowDetails);
            results.predictions{i} = r.prediction;
            results.confidences(i) = r.confidence;
            results.individual{i} = r;
        end
        return;
    end

    % Convert to double [0, 1] if needed
    if isa(img, 'uint8')
        img_d = double(img) / 255.0;
    elseif isa(img, 'uint16')
        img_d = double(img) / 65535.0;
    else
        img_d = double(img);
        if max(img_d(:)) > 1
            img_d = img_d / max(img_d(:));
        end
    end

    % Extract features
    features = extract_features(img_d);

    % Compute class scores
    scores = compute_scores(features);

    % Softmax to get probabilities
    probabilities = softmax_scores(scores);

    % Pick the winner
    class_names = {'grains', 'porous', 'dual_phase'};
    prob_vec = [probabilities.grains, probabilities.porous, probabilities.dual_phase];
    [max_prob, max_idx] = max(prob_vec);

    results = struct();
    results.prediction = class_names{max_idx};
    results.confidence = max_prob;
    results.scores = scores;
    results.probabilities = probabilities;
    results.features = features;

    if opts.ShowDetails
        fprintf('\n--- Microstructure Classification ---\n');
        fprintf('Features:\n');
        feat_names = fieldnames(features);
        for i = 1:numel(feat_names)
            fprintf('  %-20s: %.4f\n', feat_names{i}, features.(feat_names{i}));
        end
        fprintf('\nScores:\n');
        fprintf('  grains:     %.4f\n', scores.grains);
        fprintf('  porous:     %.4f\n', scores.porous);
        fprintf('  dual_phase: %.4f\n', scores.dual_phase);
        fprintf('\nProbabilities:\n');
        fprintf('  grains:     %.4f\n', probabilities.grains);
        fprintf('  porous:     %.4f\n', probabilities.porous);
        fprintf('  dual_phase: %.4f\n', probabilities.dual_phase);
        fprintf('\nPrediction: %s (%.1f%% confidence)\n', ...
            results.prediction, results.confidence * 100);
        fprintf('------------------------------------\n');
    end
end

function features = extract_features(img_d)
%EXTRACT_FEATURES Compute statistical features from a normalized image
    pixels = img_d(:);
    n = numel(pixels);

    % 1. Mean intensity
    features.mean_intensity = mean(pixels);

    % 2. Std of intensity
    features.std_intensity = std(pixels);

    % 3. Skewness
    mu = features.mean_intensity;
    s = features.std_intensity;
    if s > 0
        features.skewness = mean(((pixels - mu) / s).^3);
    else
        features.skewness = 0;
    end

    % 4. Kurtosis
    if s > 0
        features.kurtosis = mean(((pixels - mu) / s).^4);
    else
        features.kurtosis = 0;
    end

    % 5. Edge density — fraction of edge pixels using gradient magnitude
    [gx, gy] = gradient(img_d);
    grad_mag = sqrt(gx.^2 + gy.^2);
    edge_threshold = 0.05;
    features.edge_density = sum(grad_mag(:) > edge_threshold) / n;

    % 6. Dark region count — connected components below 30% intensity, normalized by area
    dark_mask = img_d < 0.3;
    dark_labels = label_connected_components(dark_mask);
    num_dark = max(dark_labels(:));
    features.dark_region_count = num_dark / (n / 1e4);

    % 7. Bimodality — difference between means of lower and upper halves of histogram
    med_val = median(pixels);
    lower_half = pixels(pixels <= med_val);
    upper_half = pixels(pixels > med_val);
    if isempty(lower_half)
        lower_mean = 0;
    else
        lower_mean = mean(lower_half);
    end
    if isempty(upper_half)
        upper_mean = 1;
    else
        upper_mean = mean(upper_half);
    end
    features.bimodality = upper_mean - lower_mean;

    % 8. Contrast — 90th percentile minus 10th percentile
    sorted_pixels = sort(pixels);
    p10_idx = max(1, round(0.10 * n));
    p90_idx = min(n, round(0.90 * n));
    features.contrast = sorted_pixels(p90_idx) - sorted_pixels(p10_idx);
end

function scores = compute_scores(features)
%COMPUTE_SCORES Rule-based scoring for each microstructure class

    % --- Grains scoring ---
    grains_score = 0;

    % Moderate edge density (grain boundaries)
    if features.edge_density >= 0.02 && features.edge_density <= 0.15
        grains_score = grains_score + 1.0;
    elseif features.edge_density > 0.15 && features.edge_density <= 0.25
        grains_score = grains_score + 0.3;
    end

    % Low dark-region count (no pores)
    if features.dark_region_count < 0.5
        grains_score = grains_score + 0.8;
    elseif features.dark_region_count < 1.0
        grains_score = grains_score + 0.3;
    end

    % Moderate contrast (different grains, but not bimodal)
    if features.contrast >= 0.15 && features.contrast <= 0.55
        grains_score = grains_score + 0.7;
    elseif features.contrast > 0.55 && features.contrast <= 0.7
        grains_score = grains_score + 0.3;
    end

    % Skewness near zero (roughly symmetric distribution)
    if abs(features.skewness) < 0.5
        grains_score = grains_score + 0.5;
    elseif abs(features.skewness) < 1.0
        grains_score = grains_score + 0.2;
    end

    % Low bimodality (no two distinct phases)
    if features.bimodality < 0.3
        grains_score = grains_score + 0.5;
    end

    % Moderate std (varied grain intensities but not extreme)
    if features.std_intensity >= 0.08 && features.std_intensity <= 0.18
        grains_score = grains_score + 0.5;
    end

    % --- Porous scoring ---
    porous_score = 0;

    % Dark regions present (pores)
    if features.dark_region_count > 1.0
        porous_score = porous_score + 1.5;
    elseif features.dark_region_count > 0.3
        porous_score = porous_score + 0.8;
    end

    % Lower mean intensity (dark pores pull it down)
    if features.mean_intensity < 0.6
        porous_score = porous_score + 0.8;
    elseif features.mean_intensity < 0.7
        porous_score = porous_score + 0.4;
    end

    % Negative skewness (tail towards dark)
    if features.skewness < -0.5
        porous_score = porous_score + 0.8;
    elseif features.skewness < -0.2
        porous_score = porous_score + 0.3;
    end

    % Edge density around pores
    if features.edge_density >= 0.01 && features.edge_density <= 0.20
        porous_score = porous_score + 0.4;
    end

    % High kurtosis (sharp pore boundaries create heavy tails)
    if features.kurtosis > 3.5
        porous_score = porous_score + 0.5;
    end

    % High bimodality is NOT porous — it's dual-phase
    if features.bimodality > 0.35
        porous_score = porous_score - 1.0;
    elseif features.bimodality > 0.25
        porous_score = porous_score - 0.5;
    end

    % --- Dual-phase scoring ---
    dual_phase_score = 0;

    % High bimodality (two distinct phases)
    if features.bimodality > 0.35
        dual_phase_score = dual_phase_score + 1.5;
    elseif features.bimodality > 0.25
        dual_phase_score = dual_phase_score + 0.7;
    end

    % High contrast
    if features.contrast > 0.4
        dual_phase_score = dual_phase_score + 1.0;
    elseif features.contrast > 0.3
        dual_phase_score = dual_phase_score + 0.4;
    end

    % Moderate edge density (phase boundaries)
    if features.edge_density >= 0.02 && features.edge_density <= 0.15
        dual_phase_score = dual_phase_score + 0.5;
    end

    % Low std relative to contrast (two tight clusters)
    % High kurtosis indicates peaked distributions (two narrow peaks)
    if features.kurtosis < 2.5
        dual_phase_score = dual_phase_score + 0.5;
    end

    % Low dark-region count (it's phases, not pores)
    if features.dark_region_count < 0.5
        dual_phase_score = dual_phase_score + 0.5;
    end

    % High std intensity (two well-separated clusters)
    if features.std_intensity > 0.20
        dual_phase_score = dual_phase_score + 0.8;
    elseif features.std_intensity > 0.15
        dual_phase_score = dual_phase_score + 0.3;
    end

    scores = struct();
    scores.grains = grains_score;
    scores.porous = porous_score;
    scores.dual_phase = dual_phase_score;
end

function probs = softmax_scores(scores)
%SOFTMAX_SCORES Convert raw scores to normalized probabilities via softmax
    s = [scores.grains, scores.porous, scores.dual_phase];
    % Subtract max for numerical stability
    s = s - max(s);
    e = exp(s);
    e = e / sum(e);
    probs = struct();
    probs.grains = e(1);
    probs.porous = e(2);
    probs.dual_phase = e(3);
end

function labels = label_connected_components(mask)
%LABEL_CONNECTED_COMPONENTS Simple flood-fill connected component labeling
%   Works with 4-connectivity on a logical 2D mask. No toolbox required.
    [rows, cols] = size(mask);
    labels = zeros(rows, cols);
    current_label = 0;

    for r = 1:rows
        for c = 1:cols
            if mask(r, c) && labels(r, c) == 0
                current_label = current_label + 1;
                % BFS flood fill
                queue = [r, c];
                labels(r, c) = current_label;
                head = 1;
                while head <= size(queue, 1)
                    cr = queue(head, 1);
                    cc = queue(head, 2);
                    head = head + 1;
                    % 4-connected neighbors
                    neighbors = [cr-1, cc; cr+1, cc; cr, cc-1; cr, cc+1];
                    for k = 1:4
                        nr = neighbors(k, 1);
                        nc = neighbors(k, 2);
                        if nr >= 1 && nr <= rows && nc >= 1 && nc <= cols
                            if mask(nr, nc) && labels(nr, nc) == 0
                                labels(nr, nc) = current_label;
                                queue = [queue; nr, nc]; %#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end
    end
end
