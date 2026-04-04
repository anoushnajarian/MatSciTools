function [img, metadata] = generate_synthetic(varargin)
%MICROSTRUCTURE.GENERATE_SYNTHETIC Generate a synthetic microstructure image
%   [IMG, METADATA] = MICROSTRUCTURE.GENERATE_SYNTHETIC() creates a test image.
%
%   Optional Parameters:
%     'Type'       - 'grains', 'porous', or 'dual_phase' (default: 'grains')
%     'Size'       - Image size [rows, cols] (default: [256, 256])
%     'NumGrains'  - Number of grains/features (default: 30)
%     'Porosity'   - Target porosity fraction for 'porous' type (default: 0.05)
%     'Noise'      - Noise level 0-1 (default: 0.02)
%
%   Example:
%     [img, meta] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 50);

    p = inputParser;
    addParameter(p, 'Type', 'grains', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Size', [256, 256], @isnumeric);
    addParameter(p, 'NumGrains', 30, @isnumeric);
    addParameter(p, 'Porosity', 0.05, @isnumeric);
    addParameter(p, 'Noise', 0.02, @isnumeric);
    parse(p, varargin{:});
    opts = p.Results;

    rows = opts.Size(1); cols = opts.Size(2);

    metadata = struct();
    metadata.type = opts.Type;
    metadata.size = [rows, cols];

    switch lower(opts.Type)
        case 'grains'
            % Voronoi-like grain structure using nearest-neighbor assignment
            n_grains = opts.NumGrains;
            seeds_r = randi(rows, n_grains, 1);
            seeds_c = randi(cols, n_grains, 1);
            intensities = 0.3 + 0.5 * rand(n_grains, 1); % different gray levels

            img = zeros(rows, cols);
            for r = 1:rows
                for c = 1:cols
                    dists = (seeds_r - r).^2 + (seeds_c - c).^2;
                    [~, nearest] = min(dists);
                    img(r, c) = intensities(nearest);
                end
            end

            metadata.num_grains = n_grains;

        case 'porous'
            % Matrix with circular pores
            img = 0.7 * ones(rows, cols) + 0.1 * rand(rows, cols);
            n_pores = opts.NumGrains;
            % Scale pore radius so total area approximates target porosity
            avg_radius = sqrt(opts.Porosity * rows * cols / (n_pores * pi));
            avg_radius = max(2, avg_radius);

            [rr, cc_grid] = meshgrid(1:cols, 1:rows);
            for ip = 1:n_pores
                cr = randi(rows); cc = randi(cols);
                radius = max(2, round(avg_radius + (rand()-0.5) * avg_radius));
                mask = ((cc_grid - cr).^2 + (rr - cc).^2) <= radius^2;
                img(mask) = 0.05 + 0.05 * rand();
            end

            metadata.num_pores = n_pores;
            metadata.target_porosity = opts.Porosity;

        case 'dual_phase'
            % Two-phase microstructure
            n_grains = opts.NumGrains;
            seeds_r = randi(rows, n_grains, 1);
            seeds_c = randi(cols, n_grains, 1);
            phases = randi(2, n_grains, 1);
            phase_intensities = [0.3, 0.8];

            img = zeros(rows, cols);
            for r = 1:rows
                for c = 1:cols
                    dists = (seeds_r - r).^2 + (seeds_c - c).^2;
                    [~, nearest] = min(dists);
                    img(r, c) = phase_intensities(phases(nearest));
                end
            end

            metadata.num_grains = n_grains;
            metadata.phase_fraction = [sum(phases==1)/n_grains, sum(phases==2)/n_grains];

        otherwise
            error('microstructure:UnknownType', ...
                'Unknown type: %s. Use: grains, porous, dual_phase', opts.Type);
    end

    % Add noise
    if opts.Noise > 0
        img = img + opts.Noise * randn(rows, cols);
        img = max(0, min(1, img));
    end

    img = uint8(img * 255);
end
