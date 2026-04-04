function results = batch_process(images, varargin)
%MICROSTRUCTURE.BATCH_PROCESS Batch processing of multiple microstructure images
%   RESULTS = MICROSTRUCTURE.BATCH_PROCESS(IMAGES) runs grain size and porosity
%   analyses on each image in the cell array IMAGES.
%
%   IMAGES is a cell array of image filenames (strings) or 2D numeric matrices.
%
%   Optional Parameters:
%     'Analyses'     - Cell array of analyses to run (default: {'grainsize', 'porosity'})
%                      Valid values: 'grainsize', 'porosity', 'phase_fraction'
%     'PixelSize'    - Physical pixel size in µm (default: 1)
%     'NumPhases'    - Number of phases for phase_fraction analysis (default: 2)
%     'ShowProgress' - Print progress messages (default: true)
%     'NumLines'     - Number of test lines for grain size analysis (default: 20)
%
%   Returns a struct with:
%     n_images    - Number of images processed
%     individual  - Cell array of per-image result structs, each containing
%                   .grainsize, .porosity, .phase_fraction fields as applicable.
%                   If an image fails, the struct contains an .error field instead.
%     summary     - Struct with aggregate statistics across all images:
%                   If grainsize was run:
%                     mean_grain_size, std_grain_size, mean_astm_number, all_grain_sizes
%                   If porosity was run:
%                     mean_porosity, std_porosity, all_porosities
%                   If phase_fraction was run:
%                     mean_fractions, std_fractions
%
%   Example:
%     % Batch process three micrograph files
%     imgs = {'sample1.png', 'sample2.png', 'sample3.png'};
%     results = microstructure.batch_process(imgs, 'PixelSize', 0.5);
%
%     % Run all analyses including phase fraction
%     results = microstructure.batch_process(imgs, ...
%         'Analyses', {'grainsize', 'porosity', 'phase_fraction'}, ...
%         'NumPhases', 3);
%
%     % Process in-memory images without progress output
%     matrices = {img1, img2, img3};
%     results = microstructure.batch_process(matrices, 'ShowProgress', false);

    valid_analyses = {'grainsize', 'porosity', 'phase_fraction'};

    p = inputParser;
    addRequired(p, 'images', @iscell);
    addParameter(p, 'Analyses', {'grainsize', 'porosity'}, ...
        @(x) iscell(x) && all(cellfun(@(a) any(strcmp(a, valid_analyses)), x)));
    addParameter(p, 'PixelSize', 1, @isnumeric);
    addParameter(p, 'NumPhases', 2, @isnumeric);
    addParameter(p, 'ShowProgress', true, @islogical);
    addParameter(p, 'NumLines', 20, @isnumeric);
    parse(p, images, varargin{:});
    opts = p.Results;

    n = numel(images);
    analyses = opts.Analyses;
    run_grainsize = any(strcmp('grainsize', analyses));
    run_porosity = any(strcmp('porosity', analyses));
    run_phase_fraction = any(strcmp('phase_fraction', analyses));

    individual = cell(1, n);

    for i = 1:n
        img = images{i};

        if opts.ShowProgress
            if ischar(img) || isstring(img)
                fprintf('Processing image %d/%d: %s\n', i, n, img);
            else
                fprintf('Processing image %d/%d\n', i, n);
            end
        end

        img_result = struct();

        try
            if run_grainsize
                img_result.grainsize = microstructure.grainsize(img, ...
                    'PixelSize', opts.PixelSize, 'NumLines', opts.NumLines);
            end

            if run_porosity
                img_result.porosity = microstructure.porosity(img);
            end

            if run_phase_fraction
                img_result.phase_fraction = microstructure.phase_fraction(img, ...
                    'NumPhases', opts.NumPhases);
            end
        catch me
            img_result.error = me.message;
            if opts.ShowProgress
                fprintf('  ERROR: %s\n', me.message);
            end
        end

        individual{i} = img_result;
    end

    % Build summary
    summary = struct();

    if run_grainsize
        grain_sizes = [];
        astm_numbers = [];
        for i = 1:n
            if isfield(individual{i}, 'grainsize')
                val = individual{i}.grainsize.mean_intercept;
                if ~isnan(val)
                    grain_sizes(end+1) = val; %#ok<AGROW>
                end
                val = individual{i}.grainsize.astm_grain_number;
                if ~isnan(val)
                    astm_numbers(end+1) = val; %#ok<AGROW>
                end
            end
        end
        summary.all_grain_sizes = grain_sizes;
        summary.mean_grain_size = mean(grain_sizes);
        summary.std_grain_size = std(grain_sizes);
        summary.mean_astm_number = mean(astm_numbers);
    end

    if run_porosity
        porosities = [];
        for i = 1:n
            if isfield(individual{i}, 'porosity')
                porosities(end+1) = individual{i}.porosity.porosity_percent; %#ok<AGROW>
            end
        end
        summary.all_porosities = porosities;
        summary.mean_porosity = mean(porosities);
        summary.std_porosity = std(porosities);
    end

    if run_phase_fraction
        all_fractions = [];
        for i = 1:n
            if isfield(individual{i}, 'phase_fraction')
                all_fractions(end+1, :) = individual{i}.phase_fraction.fractions; %#ok<AGROW>
            end
        end
        if ~isempty(all_fractions)
            summary.mean_fractions = mean(all_fractions, 1);
            summary.std_fractions = std(all_fractions, 0, 1);
        else
            summary.mean_fractions = [];
            summary.std_fractions = [];
        end
    end

    results = struct();
    results.n_images = n;
    results.individual = individual;
    results.summary = summary;

    if opts.ShowProgress
        fprintf('Batch processing complete: %d images processed.\n', n);
    end
end
