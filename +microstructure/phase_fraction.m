function results = phase_fraction(img, varargin)
%MICROSTRUCTURE.PHASE_FRACTION Estimate phase fractions from a microstructure image
%   RESULTS = MICROSTRUCTURE.PHASE_FRACTION(IMG) estimates phase area fractions
%   by thresholding the image into distinct intensity bands.
%
%   Optional Parameters:
%     'NumPhases'  - Number of phases to detect (default: 2)
%     'Thresholds' - Manual threshold values (vector of length NumPhases-1)
%     'ShowPlot'   - Display analysis visualization (default: false)
%
%   Returns a struct with:
%     num_phases        - Number of phases detected
%     fractions         - Area fraction of each phase (vector)
%     fractions_percent - Area fraction in percent
%     thresholds        - Threshold values used
%
%   Example:
%     results = microstructure.phase_fraction('dual_phase.png', 'NumPhases', 2);

    p = inputParser;
    addRequired(p, 'img');
    addParameter(p, 'NumPhases', 2, @isnumeric);
    addParameter(p, 'Thresholds', [], @isnumeric);
    addParameter(p, 'ShowPlot', false, @islogical);
    parse(p, img, varargin{:});
    opts = p.Results;

    % Load image
    if ischar(img) || isstring(img)
        if ~isfile(img)
            error('microstructure:FileNotFound', 'Image file not found: %s', img);
        end
        img = imread(img);
    end

    if size(img, 3) == 3
        img = uint8(0.2989*double(img(:,:,1)) + 0.5870*double(img(:,:,2)) + 0.1140*double(img(:,:,3)));
    end
    img_norm = double(img) / double(max(img(:)));

    n_phases = opts.NumPhases;

    if isempty(opts.Thresholds)
        % Auto-generate evenly spaced thresholds
        thresholds = linspace(0, 1, n_phases + 1);
        thresholds = thresholds(2:end-1);

        % Refine using k-means-like approach (simple iterative)
        pixels = img_norm(:);
        centers = linspace(min(pixels), max(pixels), n_phases);
        for iter = 1:20
            % Assign pixels to nearest center
            dists = abs(pixels - centers);
            if n_phases == 2
                dists = [abs(pixels - centers(1)), abs(pixels - centers(2))];
                [~, labels] = min(dists, [], 2);
            else
                dists_mat = zeros(numel(pixels), n_phases);
                for k = 1:n_phases
                    dists_mat(:, k) = abs(pixels - centers(k));
                end
                [~, labels] = min(dists_mat, [], 2);
            end
            % Update centers
            new_centers = centers;
            for k = 1:n_phases
                members = pixels(labels == k);
                if ~isempty(members)
                    new_centers(k) = mean(members);
                end
            end
            if max(abs(new_centers - centers)) < 1e-6
                break;
            end
            centers = new_centers;
        end

        % Derive thresholds from centers
        centers_sorted = sort(centers);
        thresholds = zeros(1, n_phases - 1);
        for k = 1:n_phases-1
            thresholds(k) = (centers_sorted(k) + centers_sorted(k+1)) / 2;
        end
    else
        thresholds = sort(opts.Thresholds);
        if numel(thresholds) ~= n_phases - 1
            error('microstructure:InvalidThresholds', ...
                'Number of thresholds must be NumPhases - 1 (%d)', n_phases - 1);
        end
    end

    % Calculate fractions
    total_pixels = numel(img_norm);
    fractions = zeros(1, n_phases);

    all_thresh = [0, thresholds, 1.001]; % add boundaries
    for k = 1:n_phases
        mask = img_norm >= all_thresh(k) & img_norm < all_thresh(k+1);
        fractions(k) = sum(mask(:)) / total_pixels;
    end

    results = struct();
    results.num_phases = n_phases;
    results.fractions = fractions;
    results.fractions_percent = fractions * 100;
    results.thresholds = thresholds;

    if opts.ShowPlot
        figure('Name', 'Phase Fraction Analysis', 'NumberTitle', 'off');
        subplot(1, n_phases + 1, 1);
        imagesc(img_norm); colormap(gray); axis image; title('Original');
        for k = 1:n_phases
            subplot(1, n_phases + 1, k + 1);
            if k == 1
                mask = img_norm < all_thresh(2);
            elseif k == n_phases
                mask = img_norm >= all_thresh(k);
            else
                mask = img_norm >= all_thresh(k) & img_norm < all_thresh(k+1);
            end
            imagesc(mask); colormap(gray); axis image;
            title(sprintf('Phase %d: %.1f%%', k, fractions(k)*100));
        end
    end
end
