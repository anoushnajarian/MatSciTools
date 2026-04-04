function T = index(numerator, denominator, varargin)
%MATSEL.INDEX Calculate material performance index and rank materials
%   T = MATSEL.INDEX(NUMERATOR, DENOMINATOR) calculates the performance index
%   as NUMERATOR/DENOMINATOR for all materials and sorts by descending index.
%
%   T = MATSEL.INDEX(NUM, DEN, 'Power', [p_num, p_den]) calculates NUM^p_num / DEN^p_den.
%   T = MATSEL.INDEX(NUM, DEN, ..., 'Categories', {'Metal'}) filters by category.
%   T = MATSEL.INDEX(NUM, DEN, ..., 'TopN', 10) returns only top N results.
%
%   Common performance indices:
%     E/density          - Specific stiffness (lightweight stiff design)
%     yield_strength/density - Specific strength
%     E^(1/2)/density    - Light, stiff beam
%     E^(1/3)/density    - Light, stiff plate
%     thermal_conductivity/cost - Cost-effective heat transfer
%
%   Example:
%     T = matsel.index('youngs_modulus', 'density');
%     T = matsel.index('youngs_modulus', 'density', 'Power', [0.5 1], 'TopN', 10);

    p = inputParser;
    addRequired(p, 'numerator', @(x) ischar(x) || isstring(x));
    addRequired(p, 'denominator', @(x) ischar(x) || isstring(x));
    addParameter(p, 'Power', [1 1], @(x) isnumeric(x) && numel(x)==2);
    addParameter(p, 'Categories', {}, @iscell);
    addParameter(p, 'TopN', Inf, @isnumeric);
    parse(p, numerator, denominator, varargin{:});
    opts = p.Results;

    db = matdb.search('density', [-Inf Inf]); % get all

    if ~isempty(opts.Categories)
        mask = false(1, numel(db));
        for i = 1:numel(opts.Categories)
            mask = mask | strcmpi({db.category}, opts.Categories{i});
        end
        db = db(mask);
    end

    num_vals = [db.(numerator)];
    den_vals = [db.(denominator)];

    perf_index = (num_vals .^ opts.Power(1)) ./ (den_vals .^ opts.Power(2));

    [perf_index_sorted, sort_idx] = sort(perf_index, 'descend');
    db_sorted = db(sort_idx);

    n = min(opts.TopN, numel(db_sorted));

    names = {db_sorted(1:n).name}';
    categories = {db_sorted(1:n).category}';
    pi_vals = perf_index_sorted(1:n)';
    num_data = [db_sorted(1:n).(numerator)]';
    den_data = [db_sorted(1:n).(denominator)]';

    u = matdb.units();
    pi_label = sprintf('%s^%.1f / %s^%.1f', numerator, opts.Power(1), denominator, opts.Power(2));

    T = table(names, categories, pi_vals, num_data, den_data, ...
        'VariableNames', {'Name', 'Category', 'PerformanceIndex', numerator, denominator});
    T.Properties.Description = sprintf('Performance Index: %s', pi_label);
end
