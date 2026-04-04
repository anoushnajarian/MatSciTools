function [strain, stress] = import_data(filename, varargin)
%MECHTEST.IMPORT_DATA Import stress-strain data from a CSV or Excel file
%   [STRAIN, STRESS] = MECHTEST.IMPORT_DATA(FILENAME) reads data from file.
%
%   Assumes columns: Column 1 = Strain, Column 2 = Stress (MPa).
%   [STRAIN, STRESS] = MECHTEST.IMPORT_DATA(FILENAME, 'StrainCol', 1, 'StressCol', 2)
%
%   Optional Parameters:
%     'StrainCol'   - Column index for strain (default: 1)
%     'StressCol'   - Column index for stress (default: 2)
%     'StrainUnit'  - 'mm/mm' (default), 'percent', or 'microstrain'
%     'HeaderRows'  - Number of header rows to skip (default: 1)
%
%   Example:
%     [strain, stress] = mechtest.import_data('test_data.csv');

    p = inputParser;
    addRequired(p, 'filename', @(x) ischar(x) || isstring(x));
    addParameter(p, 'StrainCol', 1, @isnumeric);
    addParameter(p, 'StressCol', 2, @isnumeric);
    addParameter(p, 'StrainUnit', 'mm/mm', @(x) ischar(x) || isstring(x));
    addParameter(p, 'HeaderRows', 1, @isnumeric);
    parse(p, filename, varargin{:});
    opts = p.Results;

    if ~isfile(filename)
        error('mechtest:FileNotFound', 'File not found: %s', filename);
    end

    [~, ~, ext] = fileparts(filename);

    if strcmpi(ext, '.csv')
        data = readmatrix(filename, 'NumHeaderLines', opts.HeaderRows);
    elseif any(strcmpi(ext, {'.xls', '.xlsx'}))
        data = readmatrix(filename);
    else
        error('mechtest:UnsupportedFormat', 'Unsupported file format: %s. Use .csv, .xls, or .xlsx', ext);
    end

    strain = data(:, opts.StrainCol);
    stress = data(:, opts.StressCol);

    % Convert strain units
    switch lower(opts.StrainUnit)
        case 'percent'
            strain = strain / 100;
        case 'microstrain'
            strain = strain / 1e6;
        case 'mm/mm'
            % already correct
        otherwise
            warning('mechtest:UnknownUnit', 'Unknown strain unit: %s. Assuming mm/mm.', opts.StrainUnit);
    end

    % Remove NaN rows
    valid = ~isnan(strain) & ~isnan(stress);
    strain = strain(valid);
    stress = stress(valid);
end
