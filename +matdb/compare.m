function T = compare(names)
%MATDB.COMPARE Compare properties of multiple materials side by side
%   T = MATDB.COMPARE(NAMES) returns a comparison table for the specified materials.
%   NAMES is a cell array of material name strings.
%
%   Example:
%     T = matdb.compare({'Al 6061-T6', 'Ti-6Al-4V', 'CFRP (Carbon/Epoxy)'});
%     disp(T);

    if ~iscell(names)
        error('matdb:InvalidInput', 'NAMES must be a cell array of strings.');
    end

    props = {'density', 'youngs_modulus', 'yield_strength', 'uts', 'elongation', ...
             'hardness', 'thermal_conductivity', 'thermal_expansion', ...
             'melting_point', 'poissons_ratio', 'cost', 'specific_heat'};

    units = {'kg/m^3', 'GPa', 'MPa', 'MPa', '%', 'HV', 'W/(m*K)', ...
             'um/(m*K)', 'deg C', '-', '$/kg', 'J/(kg*K)'};

    prop_labels = strcat(props', ' (', units', ')');

    n = numel(names);
    data = zeros(numel(props), n);
    col_names = cell(1, n);

    for i = 1:n
        mat = matdb.get(names{i});
        col_names{i} = mat.name;
        for j = 1:numel(props)
            data(j, i) = mat.(props{j});
        end
    end

    % Make valid MATLAB variable names for columns
    valid_cols = matlab.lang.makeValidName(col_names);

    T = array2table(data, 'RowNames', prop_labels, 'VariableNames', valid_cols);
end
