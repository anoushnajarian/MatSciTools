function peaks = find_peaks(two_theta, intensity, varargin)
%XRD.FIND_PEAKS Detect peaks in an XRD pattern
%   PEAKS = XRD.FIND_PEAKS(TWO_THETA, INTENSITY) finds peaks by local
%   maximum detection with prominence and distance filtering.
%
%   Optional Parameters:
%     'MinHeight'     - Minimum peak height as fraction of max (default: 0.05)
%     'MinDistance'    - Minimum separation between peaks in degrees (default: 0.5)
%     'MinProminence' - Minimum prominence as fraction of max (default: 0.03)
%
%   Returns a struct with:
%     positions   - 2-theta values of detected peaks
%     intensities - Intensity values at peaks
%     indices     - Array indices of peaks
%     count       - Number of peaks found
%
%   Example:
%     [tt, I] = xrd.generate_pattern();
%     [~, corrected] = xrd.subtract_background(tt, I);
%     peaks = xrd.find_peaks(tt, corrected);
%     plot(tt, corrected); hold on;
%     plot(peaks.positions, peaks.intensities, 'rv', 'MarkerSize', 8);

    p = inputParser;
    addRequired(p, 'two_theta', @isnumeric);
    addRequired(p, 'intensity', @isnumeric);
    addParameter(p, 'MinHeight', 0.05, @isnumeric);
    addParameter(p, 'MinDistance', 0.5, @isnumeric);
    addParameter(p, 'MinProminence', 0.03, @isnumeric);
    parse(p, two_theta, intensity, varargin{:});

    min_height = p.Results.MinHeight;
    min_dist   = p.Results.MinDistance;
    min_prom   = p.Results.MinProminence;

    two_theta = two_theta(:);
    intensity = intensity(:);
    n = numel(intensity);
    max_int = max(intensity);

    % Step 1: Find local maxima (higher than both neighbors, above MinHeight)
    height_thresh = min_height * max_int;
    is_peak = false(n, 1);
    for i = 2:n-1
        if intensity(i) > intensity(i-1) && intensity(i) > intensity(i+1) ...
                && intensity(i) >= height_thresh
            is_peak(i) = true;
        end
    end

    candidate_idx = find(is_peak);

    % Step 2: Filter by prominence
    prom_thresh = min_prom * max_int;
    keep = true(size(candidate_idx));
    for k = 1:numel(candidate_idx)
        idx = candidate_idx(k);
        prom = compute_prominence(intensity, idx);
        if prom < prom_thresh
            keep(k) = false;
        end
    end
    candidate_idx = candidate_idx(keep);

    % Step 3: Filter by minimum distance (keep taller of two close peaks)
    if numel(candidate_idx) > 1
        candidate_idx = filter_by_distance(two_theta, intensity, candidate_idx, min_dist);
    end

    % Build output struct
    peaks.positions   = two_theta(candidate_idx)';
    peaks.intensities = intensity(candidate_idx)';
    peaks.indices     = candidate_idx';
    peaks.count       = numel(candidate_idx);
end

function prom = compute_prominence(intensity, idx)
%COMPUTE_PROMINENCE Prominence = peak height minus max of nearest valleys
    n = numel(intensity);

    % Search left for the nearest valley
    left_min = intensity(idx);
    for j = idx-1:-1:1
        if intensity(j) < left_min
            left_min = intensity(j);
        end
        if intensity(j) > intensity(idx)
            break;
        end
    end

    % Search right for the nearest valley
    right_min = intensity(idx);
    for j = idx+1:n
        if intensity(j) < right_min
            right_min = intensity(j);
        end
        if intensity(j) > intensity(idx)
            break;
        end
    end

    prom = intensity(idx) - max(left_min, right_min);
end

function idx_out = filter_by_distance(two_theta, intensity, idx_in, min_dist)
%FILTER_BY_DISTANCE Keep taller peak when two are closer than min_dist
    % Sort by intensity (descending) so taller peaks get priority
    [~, sort_order] = sort(intensity(idx_in), 'descend');
    sorted_idx = idx_in(sort_order);

    keep = true(size(sorted_idx));
    for i = 1:numel(sorted_idx)
        if ~keep(i)
            continue;
        end
        for j = i+1:numel(sorted_idx)
            if ~keep(j)
                continue;
            end
            if abs(two_theta(sorted_idx(i)) - two_theta(sorted_idx(j))) < min_dist
                keep(j) = false;
            end
        end
    end

    idx_out = sort(sorted_idx(keep));
end
