function filepath = generate_report(results, filename, varargin)
%MECHTEST.GENERATE_REPORT Generate a formatted report file for mechanical test results
%   FILEPATH = MECHTEST.GENERATE_REPORT(RESULTS, FILENAME) writes a formatted text
%   report to the specified file. RESULTS is the output from MECHTEST.ANALYZE.
%
%   FILEPATH = MECHTEST.GENERATE_REPORT(RESULTS, FILENAME, 'Format', 'html') writes
%   an HTML report with inline CSS that can be opened in a browser and printed to PDF.
%
%   Optional Parameters:
%     'SampleName' - Name of the specimen (default: 'Unknown')
%     'Format'     - Output format: 'txt' or 'html' (default: 'txt')
%     'TestDate'   - Date string for the report (default: current date)
%     'Operator'   - Name of the test operator (default: '')
%     'Standard'   - Test standard reference (default: 'ASTM E8')
%
%   Returns the full path of the written file.
%
%   Example:
%     results = mechtest.analyze(strain, stress);
%     mechtest.generate_report(results, 'report.txt', ...
%         'SampleName', 'AISI 1045 Specimen 1', 'Operator', 'J. Smith');
%
%     mechtest.generate_report(results, 'report.html', ...
%         'Format', 'html', 'SampleName', 'Ti-6Al-4V');

    p = inputParser;
    addRequired(p, 'results', @isstruct);
    addRequired(p, 'filename', @(x) ischar(x)||isstring(x));
    addParameter(p, 'SampleName', 'Unknown', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Format', 'txt', @(x) ismember(lower(x), {'txt', 'html'}));
    addParameter(p, 'TestDate', datestr(now, 'yyyy-mm-dd'), @(x) ischar(x)||isstring(x));
    addParameter(p, 'Operator', '', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Standard', 'ASTM E8', @(x) ischar(x)||isstring(x));
    parse(p, results, filename, varargin{:});
    opts = p.Results;

    fmt = lower(char(opts.Format));

    switch fmt
        case 'txt'
            filepath = write_txt(results, filename, opts);
        case 'html'
            filepath = write_html(results, filename, opts);
    end
end

function filepath = write_txt(results, filename, opts)
    fid = fopen(filename, 'w');
    if fid == -1
        error('mechtest:FileError', 'Cannot open file for writing: %s', filename);
    end
    cleanup = onCleanup(@() fclose(fid));

    fprintf(fid, '============================================\n');
    fprintf(fid, '  Mechanical Test Report\n');
    fprintf(fid, '============================================\n');
    fprintf(fid, '  Sample:    %s\n', opts.SampleName);
    fprintf(fid, '  Date:      %s\n', opts.TestDate);
    if ~isempty(opts.Operator)
        fprintf(fid, '  Operator:  %s\n', opts.Operator);
    end
    fprintf(fid, '  Standard:  %s\n', opts.Standard);
    fprintf(fid, '  Data Points: %d\n', results.n_points);
    fprintf(fid, '--------------------------------------------\n');
    fprintf(fid, '  Elastic Modulus:      %8.1f GPa\n', results.youngs_modulus);
    fprintf(fid, '  Yield Strength:       %8.1f MPa\n', results.yield_strength);
    fprintf(fid, '  Ultimate Strength:    %8.1f MPa\n', results.uts);
    fprintf(fid, '  Elongation at Break:  %8.1f %%\n', results.elongation);
    fprintf(fid, '  Fracture Stress:      %8.1f MPa\n', results.fracture_stress);
    fprintf(fid, '  Toughness:            %8.2f MJ/m^3\n', results.toughness);
    fprintf(fid, '  Resilience:           %8.4f MJ/m^3\n', results.resilience);
    fprintf(fid, '  Strain at UTS:        %8.4f mm/mm\n', results.strain_at_uts);
    fprintf(fid, '============================================\n');

    filepath = char(filename);
end

function filepath = write_html(results, filename, opts)
    fid = fopen(filename, 'w');
    if fid == -1
        error('mechtest:FileError', 'Cannot open file for writing: %s', filename);
    end
    cleanup = onCleanup(@() fclose(fid));

    fprintf(fid, '<!DOCTYPE html>\n<html>\n<head>\n');
    fprintf(fid, '<meta charset="UTF-8">\n');
    fprintf(fid, '<title>Mechanical Test Report - %s</title>\n', opts.SampleName);
    fprintf(fid, '<style>\n');
    fprintf(fid, '  body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; color: #333; }\n');
    fprintf(fid, '  h1 { text-align: center; border-bottom: 2px solid #333; padding-bottom: 10px; }\n');
    fprintf(fid, '  table { width: 100%%; border-collapse: collapse; margin: 20px 0; }\n');
    fprintf(fid, '  th, td { padding: 8px 12px; border: 1px solid #ccc; text-align: left; }\n');
    fprintf(fid, '  th { background-color: #f0f0f0; }\n');
    fprintf(fid, '  .meta-table td:first-child { font-weight: bold; width: 150px; }\n');
    fprintf(fid, '  .results-table td:last-child { text-align: right; font-family: monospace; }\n');
    fprintf(fid, '  .footer { margin-top: 40px; font-size: 0.85em; color: #888; text-align: center; border-top: 1px solid #ccc; padding-top: 10px; }\n');
    fprintf(fid, '</style>\n');
    fprintf(fid, '</head>\n<body>\n');

    fprintf(fid, '<h1>Mechanical Test Report</h1>\n');

    % Metadata table
    fprintf(fid, '<table class="meta-table">\n');
    fprintf(fid, '  <tr><td>Sample</td><td>%s</td></tr>\n', opts.SampleName);
    fprintf(fid, '  <tr><td>Date</td><td>%s</td></tr>\n', opts.TestDate);
    if ~isempty(opts.Operator)
        fprintf(fid, '  <tr><td>Operator</td><td>%s</td></tr>\n', opts.Operator);
    end
    fprintf(fid, '  <tr><td>Standard</td><td>%s</td></tr>\n', opts.Standard);
    fprintf(fid, '  <tr><td>Data Points</td><td>%d</td></tr>\n', results.n_points);
    fprintf(fid, '</table>\n');

    % Results table
    fprintf(fid, '<table class="results-table">\n');
    fprintf(fid, '  <tr><th>Property</th><th>Value</th></tr>\n');
    fprintf(fid, '  <tr><td>Elastic Modulus</td><td>%.1f GPa</td></tr>\n', results.youngs_modulus);
    fprintf(fid, '  <tr><td>Yield Strength</td><td>%.1f MPa</td></tr>\n', results.yield_strength);
    fprintf(fid, '  <tr><td>Ultimate Tensile Strength</td><td>%.1f MPa</td></tr>\n', results.uts);
    fprintf(fid, '  <tr><td>Elongation at Break</td><td>%.1f %%</td></tr>\n', results.elongation);
    fprintf(fid, '  <tr><td>Fracture Stress</td><td>%.1f MPa</td></tr>\n', results.fracture_stress);
    fprintf(fid, '  <tr><td>Toughness</td><td>%.2f MJ/m&sup3;</td></tr>\n', results.toughness);
    fprintf(fid, '  <tr><td>Resilience</td><td>%.4f MJ/m&sup3;</td></tr>\n', results.resilience);
    fprintf(fid, '  <tr><td>Strain at UTS</td><td>%.4f mm/mm</td></tr>\n', results.strain_at_uts);
    fprintf(fid, '</table>\n');

    % Footer
    fprintf(fid, '<div class="footer">Generated by matscitools &mdash; %s</div>\n', opts.TestDate);
    fprintf(fid, '</body>\n</html>\n');

    filepath = char(filename);
end
