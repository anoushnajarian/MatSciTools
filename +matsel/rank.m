function T = rank(criteria, varargin)
%MATSEL.RANK Rank materials by weighted multi-criteria scoring
%   T = MATSEL.RANK(CRITERIA) ranks materials using weighted criteria.
%   CRITERIA is a struct array with fields: property, weight, goal ('max' or 'min').
%
%   T = MATSEL.RANK(CRITERIA, 'Categories', {'Metal'}) filters by category.
%   T = MATSEL.RANK(CRITERIA, 'TopN', 10) returns top N results.
%
%   Scoring uses min-max normalization: for 'max' goals, score = (val-min)/(max-min);
%   for 'min' goals, score = (max-val)/(max-min).
%
%   Example:
%     criteria(1).property = 'yield_strength'; criteria(1).weight = 0.4; criteria(1).goal = 'max';
%     criteria(2).property = 'density';        criteria(2).weight = 0.3; criteria(2).goal = 'min';
%     criteria(3).property = 'cost';           criteria(3).weight = 0.3; criteria(3).goal = 'min';
%     T = matsel.rank(criteria, 'TopN', 10);

    p = inputParser;
    addRequired(p, 'criteria');
    addParameter(p, 'Categories', {}, @iscell);
    addParameter(p, 'TopN', Inf, @isnumeric);
    parse(p, criteria, varargin{:});
    opts = p.Results;

    % Validate weights sum to 1
    weights = [criteria.weight];
    if abs(sum(weights) - 1) > 0.01
        error('matsel:InvalidWeights', 'Criteria weights must sum to 1.0 (current sum: %.2f)', sum(weights));
    end

    db = matdb.search('density', [-Inf Inf]); % get all

    if ~isempty(opts.Categories)
        mask = false(1, numel(db));
        for i = 1:numel(opts.Categories)
            mask = mask | strcmpi({db.category}, opts.Categories{i});
        end
        db = db(mask);
    end

    n = numel(db);
    scores = zeros(1, n);

    for c = 1:numel(criteria)
        vals = [db.(criteria(c).property)];
        min_v = min(vals);
        max_v = max(vals);

        if max_v == min_v
            norm_vals = ones(1, n) * 0.5;
        elseif strcmpi(criteria(c).goal, 'max')
            norm_vals = (vals - min_v) / (max_v - min_v);
        else
            norm_vals = (max_v - vals) / (max_v - min_v);
        end

        scores = scores + criteria(c).weight * norm_vals;
    end

    [scores_sorted, sort_idx] = sort(scores, 'descend');
    db_sorted = db(sort_idx);
    n_out = min(opts.TopN, numel(db_sorted));

    names = {db_sorted(1:n_out).name}';
    categories = {db_sorted(1:n_out).category}';
    score_vals = scores_sorted(1:n_out)';

    T = table(names, categories, score_vals, ...
        'VariableNames', {'Name', 'Category', 'Score'});
end
