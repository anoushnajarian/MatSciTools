function results = grainsize(img, varargin)
%MICROSTRUCTURE.GRAINSIZE Measure grain size from a microstructure image
%   RESULTS = MICROSTRUCTURE.GRAINSIZE(IMG) analyzes a grayscale image to estimate
%   grain size using the linear intercept method (ASTM E112).
%
%   IMG can be a filename (string) or a 2D numeric matrix (grayscale image).
%
%   Optional Parameters:
%     'Threshold'    - Binarization threshold (0-1), default: auto (Otsu's method)
%     'NumLines'     - Number of test lines for intercept method (default: 20)
%     'PixelSize'    - Physical size per pixel in micrometers (default: 1)
%     'ShowPlot'     - Display analysis visualization (default: false)
%
%   Returns a struct with:
%     mean_intercept     - Mean linear intercept length (µm)
%     std_intercept      - Standard deviation of intercept lengths
%     grain_count        - Total number of grain boundary intersections
%     astm_grain_number  - ASTM grain size number (G)
%     num_lines          - Number of test lines used
%     pixel_size         - Physical pixel size used
%
%   Example:
%     results = microstructure.grainsize('micrograph.png', 'PixelSize', 0.5);

    p = inputParser;
    addRequired(p, 'img');
    addParameter(p, 'Threshold', [], @isnumeric);
    addParameter(p, 'NumLines', 20, @isnumeric);
    addParameter(p, 'PixelSize', 1, @isnumeric);
    addParameter(p, 'ShowPlot', false, @islogical);
    parse(p, img, varargin{:});
    opts = p.Results;

    % Load image if filename
    if ischar(img) || isstring(img)
        if ~isfile(img)
            error('microstructure:FileNotFound', 'Image file not found: %s', img);
        end
        img = imread(img);
    end

    % Convert to grayscale if RGB
    if size(img, 3) == 3
        img = rgb2gray_simple(img);
    end
    img = double(img);

    % Normalize to 0-1
    img = (img - min(img(:))) / max(max(img(:)) - min(img(:)), eps);

    % Threshold (Otsu's method if not specified)
    if isempty(opts.Threshold)
        thresh = otsu_threshold(img);
    else
        thresh = opts.Threshold;
    end
    bw = img > thresh;

    % Detect grain boundaries using gradient magnitude
    [gx, gy] = gradient(img);
    edge_map = sqrt(gx.^2 + gy.^2);
    edge_thresh = mean(edge_map(:)) + 2 * std(edge_map(:));
    boundaries = edge_map > edge_thresh;

    [rows, cols] = size(img);

    % Linear intercept method
    all_intercepts = [];
    n_lines = opts.NumLines;

    % Horizontal test lines
    line_rows = round(linspace(round(rows*0.1), round(rows*0.9), round(n_lines/2)));
    for i = 1:numel(line_rows)
        r = line_rows(i);
        line_data = boundaries(r, :);
        crossings = find(diff(line_data) ~= 0);
        if numel(crossings) > 1
            intercepts = diff(crossings) * opts.PixelSize;
            all_intercepts = [all_intercepts, intercepts]; %#ok<AGROW>
        end
    end

    % Vertical test lines
    line_cols = round(linspace(round(cols*0.1), round(cols*0.9), round(n_lines/2)));
    for i = 1:numel(line_cols)
        c = line_cols(i);
        line_data = boundaries(:, c)';
        crossings = find(diff(line_data) ~= 0);
        if numel(crossings) > 1
            intercepts = diff(crossings) * opts.PixelSize;
            all_intercepts = [all_intercepts, intercepts]; %#ok<AGROW>
        end
    end

    results = struct();
    if isempty(all_intercepts)
        results.mean_intercept = NaN;
        results.std_intercept = NaN;
        results.grain_count = 0;
    else
        results.mean_intercept = mean(all_intercepts);
        results.std_intercept = std(all_intercepts);
        results.grain_count = numel(all_intercepts);
    end

    % ASTM grain size number: G = -6.644 * log10(mean_intercept_mm) - 3.288
    % where mean_intercept is in mm
    if ~isnan(results.mean_intercept) && results.mean_intercept > 0
        mean_intercept_mm = results.mean_intercept / 1000;
        results.astm_grain_number = -6.644 * log10(mean_intercept_mm) - 3.288;
    else
        results.astm_grain_number = NaN;
    end

    results.num_lines = n_lines;
    results.pixel_size = opts.PixelSize;

    % Optional visualization
    if opts.ShowPlot
        figure('Name', 'Grain Size Analysis', 'NumberTitle', 'off');
        subplot(1,2,1);
        imagesc(img); colormap(gray); axis image; title('Original');
        hold on;
        for i = 1:numel(line_rows)
            plot([1 cols], [line_rows(i) line_rows(i)], 'r-', 'LineWidth', 0.5);
        end
        for i = 1:numel(line_cols)
            plot([line_cols(i) line_cols(i)], [1 rows], 'b-', 'LineWidth', 0.5);
        end
        hold off;
        subplot(1,2,2);
        imagesc(boundaries); colormap(gray); axis image;
        title(sprintf('Boundaries (mean intercept = %.1f µm)', results.mean_intercept));
    end
end

function gray = rgb2gray_simple(rgb)
    gray = uint8(0.2989 * double(rgb(:,:,1)) + 0.5870 * double(rgb(:,:,2)) + 0.1140 * double(rgb(:,:,3)));
end

function t = otsu_threshold(img)
    counts = histcounts(img(:), 256);
    total = numel(img);
    counts = counts / total;
    bins = linspace(0, 1, 256);
    best_t = 0; best_var = 0;
    for i = 1:255
        w0 = sum(counts(1:i));
        w1 = 1 - w0;
        if w0 == 0 || w1 == 0, continue; end
        mu0 = sum(bins(1:i) .* counts(1:i)) / w0;
        mu1 = sum(bins(i+1:256) .* counts(i+1:256)) / w1;
        var_between = w0 * w1 * (mu0 - mu1)^2;
        if var_between > best_var
            best_var = var_between;
            best_t = bins(i);
        end
    end
    t = best_t;
end
