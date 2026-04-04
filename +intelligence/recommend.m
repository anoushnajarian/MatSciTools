function T = recommend(requirements, varargin)
%INTELLIGENCE.RECOMMEND Recommend materials based on application requirements
%   T = INTELLIGENCE.RECOMMEND(REQUIREMENTS) finds materials best matching
%   the given application requirements.
%
%   REQUIREMENTS is a struct with fields:
%     application  - String describing the application (optional)
%     constraints  - Struct with property constraints, e.g. constraints.density = [0 3000]
%     objectives   - Struct array with fields: property, goal ('max'/'min'), weight
%
%   Optional Parameters:
%     'TopN' - Number of results (default: 5)
%
%   Example:
%     req.constraints.density = [0 4000];
%     req.constraints.yield_strength = [200 Inf];
%     req.objectives(1) = struct('property','yield_strength','goal','max','weight',0.5);
%     req.objectives(2) = struct('property','cost','goal','min','weight',0.3);
%     req.objectives(3) = struct('property','density','goal','min','weight',0.2);
%     T = intelligence.recommend(req, 'TopN', 10);

    p = inputParser;
    addRequired(p, 'requirements', @isstruct);
    addParameter(p, 'TopN', 5, @isnumeric);
    parse(p, requirements, varargin{:});
    opts = p.Results;

    % Apply constraints
    search_args = {};
    if isfield(requirements, 'constraints')
        fields = fieldnames(requirements.constraints);
        for i = 1:numel(fields)
            search_args{end+1} = fields{i}; %#ok<AGROW>
            search_args{end+1} = requirements.constraints.(fields{i}); %#ok<AGROW>
        end
    end

    if ~isempty(search_args)
        db = matdb.search(search_args{:});
    else
        db = matdb.search('density', [-Inf Inf]);
    end

    if isempty(db)
        T = table();
        fprintf('No materials match the constraints.\n');
        return;
    end

    % Score by objectives
    n = numel(db);
    scores = zeros(1, n);

    if isfield(requirements, 'objectives')
        objectives = requirements.objectives;
        total_weight = sum([objectives.weight]);

        for i = 1:numel(objectives)
            obj = objectives(i);
            vals = [db.(obj.property)];
            min_v = min(vals); max_v = max(vals);

            if max_v == min_v
                norm_vals = ones(1, n) * 0.5;
            elseif strcmpi(obj.goal, 'max')
                norm_vals = (vals - min_v) / (max_v - min_v);
            else
                norm_vals = (max_v - vals) / (max_v - min_v);
            end

            scores = scores + (obj.weight / total_weight) * norm_vals;
        end
    end

    [scores_sorted, sort_idx] = sort(scores, 'descend');
    n_out = min(opts.TopN, numel(db));
    db_sorted = db(sort_idx);

    names = {db_sorted(1:n_out).name}';
    categories = {db_sorted(1:n_out).category}';
    score_vals = scores_sorted(1:n_out)';

    % Add key properties
    density = [db_sorted(1:n_out).density]';
    ys = [db_sorted(1:n_out).yield_strength]';
    cost = [db_sorted(1:n_out).cost]';

    T = table(names, categories, score_vals, density, ys, cost, ...
        'VariableNames', {'Name', 'Category', 'Score', 'Density', 'YieldStrength', 'Cost'});
end
