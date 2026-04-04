function filepath = generate_report(results_struct, filename, varargin)
%MICROSTRUCTURE.GENERATE_REPORT Generate a formatted report file for microstructure analysis
%   FILEPATH = MICROSTRUCTURE.GENERATE_REPORT(RESULTS_STRUCT, FILENAME) writes a
%   formatted text report to the specified file.
%
%   RESULTS_STRUCT is a struct with optional fields:
%     .grainsize      - Output from MICROSTRUCTURE.GRAINSIZE
%     .porosity        - Output from MICROSTRUCTURE.POROSITY
%     .phase_fraction  - Output from MICROSTRUCTURE.PHASE_FRACTION
%
%   Only present fields are included in the report.
%
%   FILEPATH = MICROSTRUCTURE.GENERATE_REPORT(RESULTS_STRUCT, FILENAME, 'Format', 'html')
%   writes an HTML report with inline CSS that can be printed to PDF from a browser.
%
%   Optional Parameters:
%     'SampleName' - Name of the specimen (default: 'Unknown')
%     'Format'     - Output format: 'txt' or 'html' (default: 'txt')
%     'ImageType'  - Imaging technique used, e.g. 'Optical Micrograph' (default: '')
%
%   Returns the full path of the written file.
%
%   Example:
%     gs = microstructure.grainsize(img, 'PixelSize', 0.5);
%     por = microstructure.porosity(img);
%     r.grainsize = gs;
%     r.porosity = por;
%     microstructure.generate_report(r, 'micro_report.txt', ...
%         'SampleName', 'Al-7075', 'ImageType', 'SEM BSE');
%
%     microstructure.generate_report(r, 'micro_report.html', ...
%         'Format', 'html', 'SampleName', 'Al-7075');

    p = inputParser;
    addRequired(p, 'results_struct', @isstruct);
    addRequired(p, 'filename', @(x) ischar(x)||isstring(x));
    addParameter(p, 'SampleName', 'Unknown', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Format', 'txt', @(x) ismember(lower(x), {'txt', 'html'}));
    addParameter(p, 'ImageType', '', @(x) ischar(x)||isstring(x));
    parse(p, results_struct, filename, varargin{:});
    opts = p.Results;

    fmt = lower(char(opts.Format));

    switch fmt
        case 'txt'
            filepath = write_txt(results_struct, filename, opts);
        case 'html'
            filepath = write_html(results_struct, filename, opts);
    end
end

function filepath = write_txt(rs, filename, opts)
    fid = fopen(filename, 'w');
    if fid == -1
        error('microstructure:FileError', 'Cannot open file for writing: %s', filename);
    end
    cleanup = onCleanup(@() fclose(fid));

    fprintf(fid, '============================================\n');
    fprintf(fid, '  Microstructure Analysis Report\n');
    fprintf(fid, '============================================\n');
    fprintf(fid, '  Sample:      %s\n', opts.SampleName);
    if ~isempty(opts.ImageType)
        fprintf(fid, '  Image Type:  %s\n', opts.ImageType);
    end

    if isfield(rs, 'grainsize')
        g = rs.grainsize;
        fprintf(fid, '--------------------------------------------\n');
        fprintf(fid, '  Grain Size Analysis\n');
        fprintf(fid, '--------------------------------------------\n');
        fprintf(fid, '  Mean Intercept:       %8.1f um\n', g.mean_intercept);
        fprintf(fid, '  Std Dev:              %8.1f um\n', g.std_intercept);
        fprintf(fid, '  Grain Count:          %8d\n', g.grain_count);
        fprintf(fid, '  ASTM Grain Number:    %8.1f\n', g.astm_grain_number);
        fprintf(fid, '  Test Lines:           %8d\n', g.num_lines);
        fprintf(fid, '  Pixel Size:           %8.2f um\n', g.pixel_size);
    end

    if isfield(rs, 'porosity')
        por = rs.porosity;
        fprintf(fid, '--------------------------------------------\n');
        fprintf(fid, '  Porosity Analysis\n');
        fprintf(fid, '--------------------------------------------\n');
        fprintf(fid, '  Porosity:             %8.2f %%\n', por.porosity_percent);
        fprintf(fid, '  Number of Pores:      %8d\n', por.num_pores);
        fprintf(fid, '  Mean Pore Area:       %8.1f px\n', por.mean_pore_area);
        fprintf(fid, '  Total Pore Area:      %8d px\n', por.total_pore_area);
        fprintf(fid, '  Image Area:           %8d px\n', por.image_area);
    end

    if isfield(rs, 'phase_fraction')
        pf = rs.phase_fraction;
        fprintf(fid, '--------------------------------------------\n');
        fprintf(fid, '  Phase Fraction Analysis\n');
        fprintf(fid, '--------------------------------------------\n');
        for k = 1:pf.num_phases
            fprintf(fid, '  Phase %d Fraction:     %8.1f %%\n', k, pf.fractions_percent(k));
        end
        if ~isempty(pf.thresholds)
            fprintf(fid, '  Thresholds:           %s\n', mat2str(pf.thresholds, 3));
        end
    end

    fprintf(fid, '============================================\n');

    filepath = char(filename);
end

function filepath = write_html(rs, filename, opts)
    fid = fopen(filename, 'w');
    if fid == -1
        error('microstructure:FileError', 'Cannot open file for writing: %s', filename);
    end
    cleanup = onCleanup(@() fclose(fid));

    fprintf(fid, '<!DOCTYPE html>\n<html>\n<head>\n');
    fprintf(fid, '<meta charset="UTF-8">\n');
    fprintf(fid, '<title>Microstructure Report - %s</title>\n', opts.SampleName);
    fprintf(fid, '<style>\n');
    fprintf(fid, '  body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; color: #333; }\n');
    fprintf(fid, '  h1 { text-align: center; border-bottom: 2px solid #333; padding-bottom: 10px; }\n');
    fprintf(fid, '  h2 { color: #555; margin-top: 30px; }\n');
    fprintf(fid, '  table { width: 100%%; border-collapse: collapse; margin: 15px 0; }\n');
    fprintf(fid, '  th, td { padding: 8px 12px; border: 1px solid #ccc; text-align: left; }\n');
    fprintf(fid, '  th { background-color: #f0f0f0; }\n');
    fprintf(fid, '  .meta-table td:first-child { font-weight: bold; width: 150px; }\n');
    fprintf(fid, '  .results-table td:last-child { text-align: right; font-family: monospace; }\n');
    fprintf(fid, '  .footer { margin-top: 40px; font-size: 0.85em; color: #888; text-align: center; border-top: 1px solid #ccc; padding-top: 10px; }\n');
    fprintf(fid, '</style>\n');
    fprintf(fid, '</head>\n<body>\n');

    fprintf(fid, '<h1>Microstructure Analysis Report</h1>\n');

    % Metadata table
    fprintf(fid, '<table class="meta-table">\n');
    fprintf(fid, '  <tr><td>Sample</td><td>%s</td></tr>\n', opts.SampleName);
    if ~isempty(opts.ImageType)
        fprintf(fid, '  <tr><td>Image Type</td><td>%s</td></tr>\n', opts.ImageType);
    end
    fprintf(fid, '</table>\n');

    % Grain size section
    if isfield(rs, 'grainsize')
        g = rs.grainsize;
        fprintf(fid, '<h2>Grain Size Analysis</h2>\n');
        fprintf(fid, '<table class="results-table">\n');
        fprintf(fid, '  <tr><th>Property</th><th>Value</th></tr>\n');
        fprintf(fid, '  <tr><td>Mean Intercept</td><td>%.1f &mu;m</td></tr>\n', g.mean_intercept);
        fprintf(fid, '  <tr><td>Std Dev</td><td>%.1f &mu;m</td></tr>\n', g.std_intercept);
        fprintf(fid, '  <tr><td>Grain Count</td><td>%d</td></tr>\n', g.grain_count);
        fprintf(fid, '  <tr><td>ASTM Grain Number</td><td>%.1f</td></tr>\n', g.astm_grain_number);
        fprintf(fid, '  <tr><td>Test Lines</td><td>%d</td></tr>\n', g.num_lines);
        fprintf(fid, '  <tr><td>Pixel Size</td><td>%.2f &mu;m</td></tr>\n', g.pixel_size);
        fprintf(fid, '</table>\n');
    end

    % Porosity section
    if isfield(rs, 'porosity')
        por = rs.porosity;
        fprintf(fid, '<h2>Porosity Analysis</h2>\n');
        fprintf(fid, '<table class="results-table">\n');
        fprintf(fid, '  <tr><th>Property</th><th>Value</th></tr>\n');
        fprintf(fid, '  <tr><td>Porosity</td><td>%.2f %%</td></tr>\n', por.porosity_percent);
        fprintf(fid, '  <tr><td>Number of Pores</td><td>%d</td></tr>\n', por.num_pores);
        fprintf(fid, '  <tr><td>Mean Pore Area</td><td>%.1f px</td></tr>\n', por.mean_pore_area);
        fprintf(fid, '  <tr><td>Total Pore Area</td><td>%d px</td></tr>\n', por.total_pore_area);
        fprintf(fid, '  <tr><td>Image Area</td><td>%d px</td></tr>\n', por.image_area);
        fprintf(fid, '</table>\n');
    end

    % Phase fraction section
    if isfield(rs, 'phase_fraction')
        pf = rs.phase_fraction;
        fprintf(fid, '<h2>Phase Fraction Analysis</h2>\n');
        fprintf(fid, '<table class="results-table">\n');
        fprintf(fid, '  <tr><th>Phase</th><th>Fraction</th></tr>\n');
        for k = 1:pf.num_phases
            fprintf(fid, '  <tr><td>Phase %d</td><td>%.1f %%</td></tr>\n', k, pf.fractions_percent(k));
        end
        fprintf(fid, '</table>\n');
        if ~isempty(pf.thresholds)
            fprintf(fid, '<p><em>Thresholds: %s</em></p>\n', mat2str(pf.thresholds, 3));
        end
    end

    % Footer
    fprintf(fid, '<div class="footer">Generated by matscitools &mdash; %s</div>\n', datestr(now, 'yyyy-mm-dd'));
    fprintf(fid, '</body>\n</html>\n');

    filepath = char(filename);
end
