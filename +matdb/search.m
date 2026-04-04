function results = search(varargin)
%MATDB.SEARCH Search materials by property constraints
%   RESULTS = MATDB.SEARCH('Property', [min max], ...) returns materials matching constraints.
%
%   Supported properties: density, youngs_modulus, yield_strength, uts,
%   elongation, hardness, thermal_conductivity, thermal_expansion,
%   melting_point, cost, specific_heat
%
%   Use -Inf or Inf for open-ended ranges.
%
%   Example:
%     % Find materials with density < 3000 and yield_strength > 200
%     results = matdb.search('density', [0 3000], 'yield_strength', [200 Inf]);

    if mod(numel(varargin), 2) ~= 0
        error('matdb:InvalidInput', 'Arguments must be property-range pairs.');
    end

    db = load_database();
    mask = true(1, numel(db));

    for i = 1:2:numel(varargin)
        prop = varargin{i};
        range = varargin{i+1};

        if ~isfield(db, prop)
            error('matdb:InvalidProperty', 'Unknown property: %s', prop);
        end

        vals = [db.(prop)];
        mask = mask & (vals >= range(1)) & (vals <= range(2));
    end

    results = db(mask);

    if isempty(results)
        fprintf('No materials found matching the specified criteria.\n');
    end
end
