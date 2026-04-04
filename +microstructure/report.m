function report(results, analysis_type, varargin)
%MICROSTRUCTURE.REPORT Print a formatted microstructure analysis report
%   MICROSTRUCTURE.REPORT(RESULTS, TYPE) prints results.
%   TYPE is 'grainsize', 'porosity', or 'phase_fraction'.
%
%   Example:
%     results = microstructure.grainsize(img);
%     microstructure.report(results, 'grainsize');

    p = inputParser;
    addRequired(p, 'results', @isstruct);
    addRequired(p, 'analysis_type', @(x) ischar(x)||isstring(x));
    addParameter(p, 'SampleName', 'Unknown', @(x) ischar(x)||isstring(x));
    parse(p, results, analysis_type, varargin{:});

    fprintf('\n');
    fprintf('  ============================================\n');
    fprintf('  Microstructure Analysis Report\n');
    fprintf('  ============================================\n');
    fprintf('  Sample: %s\n', p.Results.SampleName);
    fprintf('  Analysis: %s\n', analysis_type);
    fprintf('  --------------------------------------------\n');

    switch lower(analysis_type)
        case 'grainsize'
            fprintf('  Mean Intercept:       %8.1f µm\n', results.mean_intercept);
            fprintf('  Std Dev:              %8.1f µm\n', results.std_intercept);
            fprintf('  Grain Count:          %8d\n', results.grain_count);
            fprintf('  ASTM Grain Number:    %8.1f\n', results.astm_grain_number);
            fprintf('  Test Lines:           %8d\n', results.num_lines);
            fprintf('  Pixel Size:           %8.2f µm\n', results.pixel_size);
        case 'porosity'
            fprintf('  Porosity:             %8.2f %%\n', results.porosity_percent);
            fprintf('  Number of Pores:      %8d\n', results.num_pores);
            fprintf('  Mean Pore Area:       %8.1f px\n', results.mean_pore_area);
            fprintf('  Total Pore Area:      %8d px\n', results.total_pore_area);
            fprintf('  Image Area:           %8d px\n', results.image_area);
        case 'phase_fraction'
            for k = 1:results.num_phases
                fprintf('  Phase %d Fraction:     %8.1f %%\n', k, results.fractions_percent(k));
            end
            if ~isempty(results.thresholds)
                fprintf('  Thresholds:           %s\n', mat2str(results.thresholds, 3));
            end
    end

    fprintf('  ============================================\n\n');
end
