function fig = ashby(prop_x, prop_y, varargin)
%MATSEL.ASHBY Create an Ashby-style material property chart
%   FIG = MATSEL.ASHBY(PROP_X, PROP_Y) creates a log-log material property chart.
%   FIG = MATSEL.ASHBY(PROP_X, PROP_Y, 'Name', Value) with optional parameters.
%
%   Optional Parameters:
%     'Categories'  - Cell array of categories to include (default: all)
%     'LogScale'    - [bool_x, bool_y] for log scale (default: [true, true])
%     'ShowLabels'  - Show material name labels (default: true)
%     'Guidelines'  - Show performance index guidelines (default: false)
%     'GuideSlope'  - Slope of guideline in log space (default: 1)
%
%   Example:
%     matsel.ashby('density', 'youngs_modulus');
%     matsel.ashby('density', 'yield_strength', 'Categories', {'Metal', 'Ceramic'});

    p = inputParser;
    addRequired(p, 'prop_x', @(x) ischar(x) || isstring(x));
    addRequired(p, 'prop_y', @(x) ischar(x) || isstring(x));
    addParameter(p, 'Categories', {'Metal', 'Ceramic', 'Polymer', 'Composite'}, @iscell);
    addParameter(p, 'LogScale', [true, true], @(x) islogical(x) && numel(x)==2);
    addParameter(p, 'ShowLabels', true, @islogical);
    addParameter(p, 'Guidelines', false, @islogical);
    addParameter(p, 'GuideSlope', 1, @isnumeric);
    parse(p, prop_x, prop_y, varargin{:});
    opts = p.Results;

    u = matdb.units();
    if ~isfield(u, prop_x)
        error('matsel:InvalidProperty', 'Unknown property: %s', prop_x);
    end
    if ~isfield(u, prop_y)
        error('matsel:InvalidProperty', 'Unknown property: %s', prop_y);
    end

    % Color map for categories
    colors = struct('Metal', [0.2 0.4 0.8], ...
                    'Ceramic', [0.8 0.2 0.2], ...
                    'Polymer', [0.2 0.7 0.3], ...
                    'Composite', [0.8 0.6 0.1]);

    markers = struct('Metal', 'o', 'Ceramic', 's', 'Polymer', 'd', 'Composite', '^');

    fig = figure('Name', sprintf('Ashby Chart: %s vs %s', prop_x, prop_y), ...
                 'NumberTitle', 'off', 'Position', [100 100 900 700]);
    hold on;

    legend_entries = {};
    legend_handles = [];

    for c = 1:numel(opts.Categories)
        cat = opts.Categories{c};
        mats = matdb.list(cat);

        if isempty(mats) || height(mats) == 0
            continue;
        end

        db_cat = matdb.search('density', [-Inf Inf]); % get all
        db_cat = db_cat(strcmpi({db_cat.category}, cat));

        x_vals = [db_cat.(prop_x)];
        y_vals = [db_cat.(prop_y)];
        mat_names = {db_cat.name};

        h = scatter(x_vals, y_vals, 80, colors.(cat), 'filled', ...
                    'Marker', markers.(cat), 'MarkerEdgeColor', 'k', ...
                    'LineWidth', 0.5);
        legend_handles(end+1) = h; %#ok<AGROW>
        legend_entries{end+1} = cat; %#ok<AGROW>

        if opts.ShowLabels
            for i = 1:numel(mat_names)
                text(x_vals(i), y_vals(i), ['  ' mat_names{i}], ...
                     'FontSize', 7, 'Color', colors.(cat)*0.7, ...
                     'Clipping', 'on');
            end
        end
    end

    if opts.LogScale(1)
        set(gca, 'XScale', 'log');
    end
    if opts.LogScale(2)
        set(gca, 'YScale', 'log');
    end

    xlabel(sprintf('%s (%s)', strrep(prop_x, '_', ' '), u.(prop_x)), 'FontSize', 12);
    ylabel(sprintf('%s (%s)', strrep(prop_y, '_', ' '), u.(prop_y)), 'FontSize', 12);
    title(sprintf('Ashby Chart: %s vs %s', strrep(prop_x, '_', ' '), strrep(prop_y, '_', ' ')), ...
          'FontSize', 14);

    if ~isempty(legend_handles)
        legend(legend_handles, legend_entries, 'Location', 'best');
    end

    grid on;
    set(gca, 'FontSize', 10);
    hold off;
end
