function results = cost_estimate(mode, varargin)
%MATSEL.COST_ESTIMATE Material cost estimation and cost-performance analysis
%   RESULTS = MATSEL.COST_ESTIMATE(MODE, ...) performs cost analysis in one of
%   three modes: 'component', 'ranking', or 'substitute'.
%
%   --- Component Cost Estimation ---
%   RESULTS = MATSEL.COST_ESTIMATE('component', 'Material', name, 'Volume', vol)
%   estimates the cost of a component given a material and volume (m^3).
%
%   Optional: 'ManufacturingFactor' (default: 1.0) multiplier for total cost.
%
%   Returns struct with: material_name, density, cost_per_kg, mass_kg,
%   raw_cost, manufacturing_factor, total_cost.
%
%   --- Cost-Performance Ranking ---
%   RESULTS = MATSEL.COST_ESTIMATE('ranking', 'PerformanceIndex', expr)
%   ranks materials by a cost-weighted performance index expression.
%
%   Optional: 'Category' (filter by category), 'TopN' (limit results).
%
%   The expression is evaluated with material property variables available
%   (e.g., 'yield_strength ./ cost', 'youngs_modulus ./ (density .* cost)').
%
%   Returns a table sorted descending by index value.
%
%   --- Material Substitution Analysis ---
%   RESULTS = MATSEL.COST_ESTIMATE('substitute', 'Current', name)
%   finds cheaper alternatives to the current material.
%
%   Optional constraints: 'MinYield', 'MinUTS', 'MinModulus', 'MaxDensity',
%   'MinElongation', 'MinHardness', 'MinThermalConductivity'.
%
%   Returns a table of cheaper alternatives sorted by cost ascending, with
%   cost savings percentage.
%
%   Examples:
%     % Component cost
%     r = matsel.cost_estimate('component', 'Material', 'AISI 1045', ...
%         'Volume', 0.001, 'ManufacturingFactor', 2.5);
%
%     % Cost-performance ranking
%     T = matsel.cost_estimate('ranking', 'PerformanceIndex', ...
%         'yield_strength ./ cost', 'Category', 'Metal', 'TopN', 10);
%
%     % Substitution analysis
%     T = matsel.cost_estimate('substitute', 'Current', 'Ti-6Al-4V', ...
%         'MinYield', 500, 'MaxDensity', 9000);

    if nargin < 1
        error('matsel:InvalidInput', 'Mode is required. Use ''component'', ''ranking'', or ''substitute''.');
    end

    if ~ischar(mode) && ~isstring(mode)
        error('matsel:InvalidInput', 'Mode must be a string.');
    end

    switch lower(mode)
        case 'component'
            results = component_cost(varargin{:});
        case 'ranking'
            results = cost_ranking(varargin{:});
        case 'substitute'
            results = substitution_analysis(varargin{:});
        otherwise
            error('matsel:InvalidMode', ...
                'Unknown mode ''%s''. Use ''component'', ''ranking'', or ''substitute''.', mode);
    end
end

%% ---- Component Cost Estimation ----
function results = component_cost(varargin)
    p = inputParser;
    addParameter(p, 'Material', '', @(x) ischar(x) || isstring(x));
    addParameter(p, 'Volume', [], @isnumeric);
    addParameter(p, 'ManufacturingFactor', 1.0, @isnumeric);
    parse(p, varargin{:});
    opts = p.Results;

    if isempty(opts.Material)
        error('matsel:InvalidInput', 'Material name is required.');
    end
    if isempty(opts.Volume) || opts.Volume <= 0
        error('matsel:InvalidInput', 'Volume must be a positive number (m^3).');
    end
    if opts.ManufacturingFactor < 1
        error('matsel:InvalidInput', 'ManufacturingFactor must be >= 1.');
    end

    mat = matdb.get(opts.Material);

    mass_kg = mat.density * opts.Volume;
    raw_cost = mass_kg * mat.cost;
    total_cost = raw_cost * opts.ManufacturingFactor;

    results.material_name = mat.name;
    results.density = mat.density;
    results.cost_per_kg = mat.cost;
    results.mass_kg = mass_kg;
    results.raw_cost = raw_cost;
    results.manufacturing_factor = opts.ManufacturingFactor;
    results.total_cost = total_cost;
end

%% ---- Cost-Performance Ranking ----
function results = cost_ranking(varargin)
    p = inputParser;
    addParameter(p, 'PerformanceIndex', '', @(x) ischar(x) || isstring(x));
    addParameter(p, 'Category', '', @(x) ischar(x) || isstring(x));
    addParameter(p, 'TopN', Inf, @isnumeric);
    parse(p, varargin{:});
    opts = p.Results;

    if isempty(opts.PerformanceIndex)
        error('matsel:InvalidInput', 'PerformanceIndex expression is required.');
    end

    db = matdb.search('density', [-Inf Inf]); % get all

    if ~isempty(opts.Category)
        mask = strcmpi({db.category}, opts.Category);
        db = db(mask);
    end

    if isempty(db)
        results = table();
        return;
    end

    % Build workspace variables for eval
    density = [db.density];                                 %#ok<NASGU>
    youngs_modulus = [db.youngs_modulus];                    %#ok<NASGU>
    yield_strength = [db.yield_strength];                   %#ok<NASGU>
    uts = [db.uts];                                         %#ok<NASGU>
    elongation = [db.elongation];                           %#ok<NASGU>
    hardness = [db.hardness];                               %#ok<NASGU>
    thermal_conductivity = [db.thermal_conductivity];       %#ok<NASGU>
    thermal_expansion = [db.thermal_expansion];             %#ok<NASGU>
    melting_point = [db.melting_point];                      %#ok<NASGU>
    poissons_ratio = [db.poissons_ratio];                   %#ok<NASGU>
    cost = [db.cost];                                       %#ok<NASGU>
    specific_heat = [db.specific_heat];                     %#ok<NASGU>

    try
        index_vals = eval(opts.PerformanceIndex);
    catch me
        error('matsel:InvalidExpression', ...
            'Could not evaluate PerformanceIndex expression: %s', me.message);
    end

    % Remove non-finite entries
    valid = isfinite(index_vals);
    db = db(valid);
    index_vals = index_vals(valid);

    [index_sorted, sort_idx] = sort(index_vals, 'descend');
    db_sorted = db(sort_idx);

    n = min(opts.TopN, numel(db_sorted));

    names = {db_sorted(1:n).name}';
    categories = {db_sorted(1:n).category}';
    pi_vals = index_sorted(1:n)';
    cost_vals = [db_sorted(1:n).cost]';

    % Extract property names referenced in the expression
    all_props = {'density', 'youngs_modulus', 'yield_strength', 'uts', ...
        'elongation', 'hardness', 'thermal_conductivity', 'thermal_expansion', ...
        'melting_point', 'poissons_ratio', 'cost', 'specific_heat'};
    expr_props = {};
    for i = 1:numel(all_props)
        if contains(opts.PerformanceIndex, all_props{i})
            expr_props{end+1} = all_props{i}; %#ok<AGROW>
        end
    end

    results = table(names, categories, pi_vals, cost_vals, ...
        'VariableNames', {'Name', 'Category', 'PerformanceIndex', 'Cost'});

    % Append referenced properties as additional columns
    for i = 1:numel(expr_props)
        prop = expr_props{i};
        if ~strcmp(prop, 'cost')
            prop_vals = [db_sorted(1:n).(prop)]';
            results.(prop) = prop_vals;
        end
    end

    results.Properties.Description = sprintf('Cost-Performance Index: %s', opts.PerformanceIndex);
end

%% ---- Material Substitution Analysis ----
function results = substitution_analysis(varargin)
    p = inputParser;
    addParameter(p, 'Current', '', @(x) ischar(x) || isstring(x));
    addParameter(p, 'MinYield', -Inf, @isnumeric);
    addParameter(p, 'MinUTS', -Inf, @isnumeric);
    addParameter(p, 'MinModulus', -Inf, @isnumeric);
    addParameter(p, 'MaxDensity', Inf, @isnumeric);
    addParameter(p, 'MinElongation', -Inf, @isnumeric);
    addParameter(p, 'MinHardness', -Inf, @isnumeric);
    addParameter(p, 'MinThermalConductivity', -Inf, @isnumeric);
    parse(p, varargin{:});
    opts = p.Results;

    if isempty(opts.Current)
        error('matsel:InvalidInput', 'Current material name is required.');
    end

    current = matdb.get(opts.Current);
    db = matdb.search('density', [-Inf Inf]); % get all

    % Filter: cheaper than current material
    mask = [db.cost] < current.cost;

    % Apply property constraints
    mask = mask & [db.yield_strength] >= opts.MinYield;
    mask = mask & [db.uts] >= opts.MinUTS;
    mask = mask & [db.youngs_modulus] >= opts.MinModulus;
    mask = mask & [db.density] <= opts.MaxDensity;
    mask = mask & [db.elongation] >= opts.MinElongation;
    mask = mask & [db.hardness] >= opts.MinHardness;
    mask = mask & [db.thermal_conductivity] >= opts.MinThermalConductivity;

    % Remove the current material itself
    mask = mask & ~strcmpi({db.name}, current.name);

    candidates = db(mask);

    if isempty(candidates)
        fprintf('No cheaper alternatives found for %s with the specified constraints.\n', current.name);
        results = table();
        return;
    end

    % Sort by cost ascending
    [~, sort_idx] = sort([candidates.cost], 'ascend');
    candidates = candidates(sort_idx);

    n = numel(candidates);
    names = {candidates.name}';
    categories = {candidates.category}';
    cost_vals = [candidates.cost]';
    savings_pct = ((current.cost - cost_vals) / current.cost) * 100;
    density_vals = [candidates.density]';
    ys_vals = [candidates.yield_strength]';
    uts_vals = [candidates.uts]';
    E_vals = [candidates.youngs_modulus]';
    elong_vals = [candidates.elongation]';

    results = table(names, categories, cost_vals, savings_pct, ...
        density_vals, ys_vals, uts_vals, E_vals, elong_vals, ...
        'VariableNames', {'Name', 'Category', 'Cost', 'CostSavingsPct', ...
        'Density', 'YieldStrength', 'UTS', 'YoungsModulus', 'Elongation'});
    results.Properties.Description = sprintf('Substitution candidates for %s (cost: $%.2f/kg)', ...
        current.name, current.cost);
end
