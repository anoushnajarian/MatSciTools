function results = circular_intercept(img, varargin)
%MICROSTRUCTURE.CIRCULAR_INTERCEPT Grain size via Abrams three-circle method (ASTM E112)
%   RESULTS = MICROSTRUCTURE.CIRCULAR_INTERCEPT(IMG) measures grain size using
%   the circular intercept method per ASTM E112.
%
%   This method draws concentric circles on the microstructure image and
%   counts grain boundary intersections along each circle. It provides
%   more isotropic measurements than the linear intercept method.
%
%   IMG can be a filename (string) or a 2D numeric matrix (grayscale image).
%
%   Optional Parameters:
%     'NumCircles'     - Number of concentric circles (default: 3)
%     'RadiusFraction' - Max radius as fraction of image half-size (default: 0.4)
%     'PixelSize'      - Physical size per pixel in micrometers (default: 1)
%     'Threshold'      - Binarization threshold (0-1), default: auto (Otsu)
%     'ShowPlot'       - Display analysis visualization (default: false)
%
%   Returns a struct with:
%     mean_intercept     - Mean circular intercept length (µm)
%     std_intercept      - Standard deviation
%     grain_count        - Total number of intersections
%     astm_grain_number  - ASTM grain size number (G)
%     num_circles        - Number of circles used
%     pixel_size         - Physical pixel size used
%     circle_results     - Per-circle results [struct array]
%
%   Example:
%     [img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 50);
%     results = microstructure.circular_intercept(img, 'PixelSize', 0.5);

    p = inputParser;
    addRequired(p, 'img');
    addParameter(p, 'NumCircles', 3, @isnumeric);
    addParameter(p, 'RadiusFraction', 0.4, @isnumeric);
    addParameter(p, 'PixelSize', 1, @isnumeric);
    addParameter(p, 'Threshold', [], @isnumeric);
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

    % Detect grain boundaries using gradient magnitude
    [gx, gy] = gradient(img);
    edge_map = sqrt(gx.^2 + gy.^2);
    edge_thresh = mean(edge_map(:)) + 2 * std(edge_map(:));
    boundaries = edge_map > edge_thresh;

    [rows, cols] = size(img);

    % Set up concentric circles
    centerX = round(cols / 2);
    centerY = round(rows / 2);
    half_size = min(rows, cols) / 2;
    max_radius = half_size * opts.RadiusFraction;
    radii = linspace(max_radius / opts.NumCircles, max_radius, opts.NumCircles);

    all_intercepts = [];
    circle_results = struct('radius_px', {}, 'circumference_um', {}, ...
        'num_intersections', {}, 'mean_intercept', {});

    for ci = 1:opts.NumCircles
        radius = radii(ci);
        nPoints = max(200, round(2 * pi * radius));
        theta = linspace(0, 2*pi, nPoints);
        xc = round(centerX + radius * cos(theta));
        yc = round(centerY + radius * sin(theta));

        % Clip to image bounds
        valid = xc >= 1 & xc <= cols & yc >= 1 & yc <= rows;
        xc = xc(valid);
        yc = yc(valid);

        % Sample boundary image along circle
        idx = sub2ind([rows, cols], yc, xc);
        sampled = boundaries(idx);

        % Count transitions (boundary crossings)
        crossings = sum(abs(diff(double(sampled))) > 0);

        circumference_um = 2 * pi * radius * opts.PixelSize;

        if crossings > 0
            intercept_len = circumference_um / crossings;
        else
            intercept_len = NaN;
        end

        circle_results(ci).radius_px = radius;
        circle_results(ci).circumference_um = circumference_um;
        circle_results(ci).num_intersections = crossings;
        circle_results(ci).mean_intercept = intercept_len;

        if crossings > 0
            all_intercepts = [all_intercepts, repmat(intercept_len, 1, crossings)]; %#ok<AGROW>
        end
    end

    % Aggregate results
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
    if ~isnan(results.mean_intercept) && results.mean_intercept > 0
        mean_intercept_mm = results.mean_intercept / 1000;
        results.astm_grain_number = -6.644 * log10(mean_intercept_mm) - 3.288;
    else
        results.astm_grain_number = NaN;
    end

    results.num_circles = opts.NumCircles;
    results.pixel_size = opts.PixelSize;
    results.circle_results = circle_results;

    % Optional visualization
    if opts.ShowPlot
        figure('Name', 'Circular Intercept Analysis', 'NumberTitle', 'off');
        subplot(1,2,1);
        imagesc(img); colormap(gray); axis image; title('Original');
        hold on;
        for ci = 1:opts.NumCircles
            th = linspace(0, 2*pi, 200);
            plot(centerX + radii(ci) * cos(th), centerY + radii(ci) * sin(th), ...
                'r-', 'LineWidth', 1.5);
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
