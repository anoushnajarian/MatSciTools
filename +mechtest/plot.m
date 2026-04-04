function fig = plot(strain, stress, results, varargin)
%MECHTEST.PLOT Plot stress-strain curve with annotated mechanical properties
%   FIG = MECHTEST.PLOT(STRAIN, STRESS, RESULTS) creates an annotated plot.
%   RESULTS is the output from MECHTEST.ANALYZE.
%
%   FIG = MECHTEST.PLOT(STRAIN, STRESS, RESULTS, 'Title', 'My Test') with custom title.
%
%   Example:
%     results = mechtest.analyze(strain, stress);
%     mechtest.plot(strain, stress, results);

    p = inputParser;
    addRequired(p, 'strain', @isnumeric);
    addRequired(p, 'stress', @isnumeric);
    addRequired(p, 'results', @isstruct);
    addParameter(p, 'Title', 'Stress-Strain Curve', @(x) ischar(x)||isstring(x));
    addParameter(p, 'ShowOffset', true, @islogical);
    parse(p, strain, stress, results, varargin{:});
    opts = p.Results;

    strain = strain(:);
    stress = stress(:);

    fig = figure('Name', 'Stress-Strain Analysis', 'NumberTitle', 'off', ...
                 'Position', [100 100 900 650]);

    % Main curve
    plot(strain * 100, stress, 'b-', 'LineWidth', 2);
    hold on;

    % Mark UTS
    plot(results.strain_at_uts * 100, results.uts, 'rv', 'MarkerSize', 12, ...
         'MarkerFaceColor', 'r', 'DisplayName', sprintf('UTS = %.0f MPa', results.uts));

    % Mark Yield Strength
    yield_strain = results.yield_strength / (results.youngs_modulus * 1000);
    plot(yield_strain * 100, results.yield_strength, 'g^', 'MarkerSize', 12, ...
         'MarkerFaceColor', 'g', 'DisplayName', sprintf('\\sigma_y = %.0f MPa', results.yield_strength));

    % Mark fracture
    plot(strain(end) * 100, stress(end), 'kx', 'MarkerSize', 14, 'LineWidth', 2, ...
         'DisplayName', 'Fracture');

    % Draw 0.2% offset line
    if opts.ShowOffset
        E_mpa = results.youngs_modulus * 1000;
        offset = 0.002;
        x_line = linspace(offset, yield_strain + 0.01, 50);
        y_line = E_mpa * (x_line - offset);
        y_line(y_line > results.yield_strength * 1.1) = NaN;
        plot(x_line * 100, y_line, 'g--', 'LineWidth', 1, 'DisplayName', '0.2% offset');
    end

    hold off;

    xlabel('Strain (%)', 'FontSize', 12);
    ylabel('Stress (MPa)', 'FontSize', 12);
    title(opts.Title, 'FontSize', 14);
    legend('Location', 'best');
    grid on;
    set(gca, 'FontSize', 10);

    % Add text box with results
    info_str = sprintf(['E = %.1f GPa\n' ...
                        '\\sigma_y = %.0f MPa\n' ...
                        'UTS = %.0f MPa\n' ...
                        'Elong. = %.1f%%\n' ...
                        'Toughness = %.1f MJ/m^3'], ...
                        results.youngs_modulus, results.yield_strength, ...
                        results.uts, results.elongation, results.toughness);

    annotation('textbox', [0.15 0.65 0.25 0.2], 'String', info_str, ...
               'FontSize', 10, 'BackgroundColor', [1 1 0.9], ...
               'EdgeColor', [0.5 0.5 0.5], 'FitBoxToText', 'on');
end
