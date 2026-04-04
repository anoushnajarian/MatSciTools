function results = materials_project(api_key, varargin)
%MATDB.MATERIALS_PROJECT Query the Materials Project API for material properties
%   RESULTS = MATDB.MATERIALS_PROJECT(API_KEY) fetches material data from the
%   Materials Project REST API (v2). Returns a struct with count, data, and table.
%
%   Use API_KEY = 'demo' to return example data without a real API key.
%
%   RESULTS = MATDB.MATERIALS_PROJECT(API_KEY, 'Formula', 'Fe2O3') searches by formula.
%   RESULTS = MATDB.MATERIALS_PROJECT(API_KEY, 'Elements', 'Fe,O') searches by elements.
%   RESULTS = MATDB.MATERIALS_PROJECT(API_KEY, 'MaterialID', 'mp-149') fetches a specific entry.
%   RESULTS = MATDB.MATERIALS_PROJECT(API_KEY, 'Fields', {'material_id','density'}) selects fields.
%   RESULTS = MATDB.MATERIALS_PROJECT(API_KEY, 'MaxResults', 20) limits result count.
%
%   Example:
%     % Demo mode (no API key needed)
%     results = matdb.materials_project('demo', 'Formula', 'Al');
%
%     % Real API call
%     results = matdb.materials_project('YOUR_KEY', 'Formula', 'Fe2O3', 'MaxResults', 5);
%     disp(results.table);

    if nargin < 1 || isempty(api_key)
        error('matdb:NoAPIKey', ...
            ['An API key is required. Get one at https://materialsproject.org/api\n' ...
             'Usage: matdb.materials_project(''YOUR_KEY'', ''Formula'', ''Fe2O3'')\n' ...
             'For demo data: matdb.materials_project(''demo'')']);
    end

    p = inputParser;
    p.addRequired('api_key', @(x) ischar(x) || isstring(x));
    p.addParameter('Formula', '', @(x) ischar(x) || isstring(x));
    p.addParameter('Elements', '', @(x) ischar(x) || isstring(x));
    p.addParameter('MaterialID', '', @(x) ischar(x) || isstring(x));
    p.addParameter('Fields', {'material_id', 'formula_pretty', 'density', ...
        'symmetry', 'band_gap', 'formation_energy_per_atom', 'energy_above_hull'}, ...
        @iscell);
    p.addParameter('MaxResults', 10, @(x) isnumeric(x) && x > 0);
    p.parse(api_key, varargin{:});

    opts = p.Results;

    % --- Demo mode ---
    if strcmpi(opts.api_key, 'demo')
        results = build_demo_results(opts);
        return;
    end

    % --- Build URL and query ---
    base_url = 'https://api.materialsproject.org/materials/summary/';

    query_parts = {};
    if ~isempty(opts.Formula)
        query_parts{end+1} = ['formula=' urlencode(opts.Formula)];
    end
    if ~isempty(opts.Elements)
        query_parts{end+1} = ['elements=' urlencode(opts.Elements)];
    end
    if ~isempty(opts.MaterialID)
        query_parts{end+1} = ['material_ids=' urlencode(opts.MaterialID)];
    end
    query_parts{end+1} = ['_limit=' num2str(opts.MaxResults)];
    for i = 1:numel(opts.Fields)
        query_parts{end+1} = ['fields=' urlencode(opts.Fields{i})]; %#ok<AGROW>
    end

    url = [base_url '?' strjoin(query_parts, '&')];

    % --- Call API ---
    web_opts = weboptions('HeaderFields', {'X-API-KEY', opts.api_key}, ...
        'ContentType', 'json', 'Timeout', 30);

    try
        response = webread(url, web_opts);
    catch me
        results.count = 0;
        results.data = [];
        results.table = table();
        results.error = sprintf('API request failed: %s', me.message);
        return;
    end

    % --- Parse response ---
    if ~isfield(response, 'data') || isempty(response.data)
        results.count = 0;
        results.data = [];
        results.table = table();
        results.error = 'No results found for the given query.';
        return;
    end

    data = response.data;
    if isstruct(data)
        n = numel(data);
    else
        n = length(data);
    end

    results.count = n;
    results.data = data;
    results.table = struct_array_to_table(data, opts.Fields);
end


function results = build_demo_results(opts)
%BUILD_DEMO_RESULTS Return pre-built example data for demo mode

    demo_data = struct( ...
        'material_id',              {'mp-134', 'mp-13', 'mp-46', 'mp-30', 'mp-149'}, ...
        'formula_pretty',           {'Al', 'Fe', 'Ti', 'Cu', 'Si'}, ...
        'density',                  {2.70, 7.87, 4.51, 8.96, 2.33}, ...
        'symmetry',                 {struct('crystal_system','cubic','symbol','Fm-3m'), ...
                                     struct('crystal_system','cubic','symbol','Im-3m'), ...
                                     struct('crystal_system','hexagonal','symbol','P6_3/mmc'), ...
                                     struct('crystal_system','cubic','symbol','Fm-3m'), ...
                                     struct('crystal_system','cubic','symbol','Fd-3m')}, ...
        'band_gap',                 {0, 0, 0, 0, 1.11}, ...
        'formation_energy_per_atom',{0, 0, 0, 0, 0}, ...
        'energy_above_hull',        {0, 0, 0, 0, 0});

    % Filter by Formula if provided
    if ~isempty(opts.Formula)
        match = strcmpi({demo_data.formula_pretty}, opts.Formula);
        demo_data = demo_data(match);
    end

    % Filter by Elements if provided
    if ~isempty(opts.Elements)
        elements = strsplit(opts.Elements, ',');
        elements = strtrim(elements);
        match = false(1, numel(demo_data));
        for i = 1:numel(demo_data)
            match(i) = any(strcmpi(demo_data(i).formula_pretty, elements));
        end
        demo_data = demo_data(match);
    end

    % Filter by MaterialID if provided
    if ~isempty(opts.MaterialID)
        match = strcmpi({demo_data.material_id}, opts.MaterialID);
        demo_data = demo_data(match);
    end

    % Limit results
    if numel(demo_data) > opts.MaxResults
        demo_data = demo_data(1:opts.MaxResults);
    end

    results.count = numel(demo_data);
    results.data = demo_data;
    results.table = struct_array_to_table(demo_data, opts.Fields);
    results.demo = true;

    fprintf('Note: Using demo data. Provide a real API key for live results.\n');
end


function T = struct_array_to_table(data, fields)
%STRUCT_ARRAY_TO_TABLE Convert struct array to a MATLAB table

    if isempty(data)
        T = table();
        return;
    end

    n = numel(data);
    available = fieldnames(data);

    % Use only scalar/string fields that exist in the data
    use_fields = intersect(fields, available, 'stable');

    % Build cell array for table construction
    col_data = cell(1, numel(use_fields));
    for j = 1:numel(use_fields)
        fname = use_fields{j};
        vals = {data.(fname)};
        if all(cellfun(@isnumeric, vals)) && all(cellfun(@isscalar, vals))
            col_data{j} = [vals{:}]';
        else
            col_data{j} = cell(n, 1);
            for i = 1:n
                v = data(i).(fname);
                if isstruct(v) && isfield(v, 'symbol')
                    col_data{j}{i} = v.symbol;
                elseif ischar(v) || isstring(v)
                    col_data{j}{i} = char(v);
                else
                    col_data{j}{i} = v;
                end
            end
        end
    end

    T = table(col_data{:}, 'VariableNames', use_fields);
end
