function mat = get(name)
%MATDB.GET Get all properties for a specific material
%   MAT = MATDB.GET(NAME) returns a struct with all properties for the named material.
%   NAME matching is case-insensitive and supports partial matching.
%
%   Properties returned:
%     name, category, subcategory, density (kg/m^3), youngs_modulus (GPa),
%     yield_strength (MPa), uts (MPa), elongation (%), hardness (HV),
%     thermal_conductivity (W/m*K), thermal_expansion (um/m*K),
%     melting_point (deg C), poissons_ratio, cost ($/kg), specific_heat (J/kg*K)
%
%   Example:
%     steel = matdb.get('AISI 1045');
%     al = matdb.get('Al 6061');

    if ~ischar(name) && ~isstring(name)
        error('matdb:InvalidInput', 'Material name must be a string.');
    end

    db = load_database();
    names = {db.name};

    % Try exact match first (case-insensitive)
    idx = find(strcmpi(names, name));

    % Try partial match
    if isempty(idx)
        idx = find(contains(names, name, 'IgnoreCase', true));
    end

    if isempty(idx)
        error('matdb:NotFound', 'Material "%s" not found. Use matdb.list() to see available materials.', name);
    end

    if numel(idx) > 1
        fprintf('Multiple matches found:\n');
        for i = 1:numel(idx)
            fprintf('  %s\n', db(idx(i)).name);
        end
        mat = db(idx(1));
        fprintf('Returning first match: %s\n', mat.name);
    else
        mat = db(idx);
    end
end
