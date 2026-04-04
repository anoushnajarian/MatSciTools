function fig = compare(datasets, varargin)
%MECHTEST.COMPARE Compare multiple stress-strain curves on one plot
%   FIG = MECHTEST.COMPARE(DATASETS) overlays multiple stress-strain curves.
%   DATASETS is a struct array with fields: strain, stress, name.
%
%   Example:
%     ds(1).strain = strain1; ds(1).stress = stress1; ds(1).name = 'Sample A';
%     ds(2).strain = strain2; ds(2).stress = stress2; ds(2).name = 'Sample B';
%     mechtest.compare(ds);

    p = inputParser;
    addRequired(p, 'datasets', @isstruct);
    addParameter(p, 'Title', 'Stress-Strain Comparison', @(x) ischar(x)||isstring(x));
    parse(p, datasets, varargin{:});

    colors = lines(numel(datasets));

    fig = figure('Name', 'Stress-Strain Comparison', 'NumberTitle', 'off', ...
                 'Position', [100 100 900 650]);
    hold on;

    for i = 1:numel(datasets)
        plot(datasets(i).strain * 100, datasets(i).stress, ...
             'Color', colors(i,:), 'LineWidth', 2, ...
             'DisplayName', datasets(i).name);
    end

    hold off;
    xlabel('Strain (%)', 'FontSize', 12);
    ylabel('Stress (MPa)', 'FontSize', 12);
    title(p.Results.Title, 'FontSize', 14);
    legend('Location', 'best');
    grid on;
    set(gca, 'FontSize', 10);
end
