function results = filter(varargin)
%MATSEL.FILTER Filter materials by property constraints
%   RESULTS = MATSEL.FILTER('Property', [min max], ...) returns filtered material table.
%   This is a convenience wrapper around matdb.search that returns a table.
%
%   Example:
%     % Lightweight, strong materials
%     T = matsel.filter('density', [0 3000], 'yield_strength', [200 Inf]);
%     disp(T);

    results_struct = matdb.search(varargin{:});

    if isempty(results_struct)
        results = table();
        return;
    end

    names = {results_struct.name}';
    categories = {results_struct.category}';
    density = [results_struct.density]';
    E = [results_struct.youngs_modulus]';
    ys = [results_struct.yield_strength]';
    uts_vals = [results_struct.uts]';
    cost = [results_struct.cost]';

    results = table(names, categories, density, E, ys, uts_vals, cost, ...
        'VariableNames', {'Name', 'Category', 'Density', 'YoungsModulus', ...
        'YieldStrength', 'UTS', 'Cost'});
end
