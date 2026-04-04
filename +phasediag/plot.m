function fig = plot(system_name, varargin)
%PHASEDIAG.PLOT Plot a binary phase diagram
%   FIG = PHASEDIAG.PLOT(SYSTEM) computes and plots the phase diagram.
%   See PHASEDIAG.BINARY for available systems.
%
%   Optional Parameters:
%     'ShowTieLine' - Show a tie line at specified temperature (K) (default: [])
%     'Composition' - Mark a specific composition on the diagram (default: [])
%     'Units'       - Temperature units: 'K' or 'C' (default: 'C')
%
%   Example:
%     phasediag.plot('Cu-Ni');
%     phasediag.plot('Cu-Ni', 'ShowTieLine', 1500, 'Composition', 0.4);

    p = inputParser;
    addRequired(p, 'system_name');
    addParameter(p, 'ShowTieLine', [], @isnumeric);
    addParameter(p, 'Composition', [], @isnumeric);
    addParameter(p, 'Units', 'C', @(x) ischar(x)||isstring(x));
    parse(p, system_name, varargin{:});
    opts = p.Results;

    [T_grid, x_grid, phase_map] = phasediag.binary(system_name);

    % Temperature conversion
    if strcmpi(opts.Units, 'C')
        T_display = T_grid - 273.15;
        T_label = 'Temperature (°C)';
    else
        T_display = T_grid;
        T_label = 'Temperature (K)';
    end

    % Get system label
    switch lower(system_name)
        case 'cu-ni'; label_A = 'Cu'; label_B = 'Ni';
        case 'pb-sn'; label_A = 'Pb'; label_B = 'Sn';
        case 'al-si'; label_A = 'Al'; label_B = 'Si';
        case 'al-cu'; label_A = 'Al'; label_B = 'Cu';
        case 'fe-ni'; label_A = 'Fe'; label_B = 'Ni';
        otherwise;    label_A = 'A';  label_B = 'B';
    end

    fig = figure('Name', sprintf('Phase Diagram: %s', system_name), ...
                 'NumberTitle', 'off', 'Position', [100 100 800 600]);

    % Plot phase regions using contour
    hold on;

    % Find liquidus and solidus lines from phase_map
    % Liquidus: boundary between liquid(1) and two-phase(3)
    % Solidus: boundary between two-phase(3) and solid(2)
    liquidus_T = zeros(size(x_grid));
    solidus_T = zeros(size(x_grid));

    for j = 1:numel(x_grid)
        col = phase_map(:, j);

        % Liquidus: last temperature where phase is liquid
        liq_idx = find(col == 1, 1, 'last');
        if isempty(liq_idx)
            liquidus_T(j) = T_display(1);
        else
            liquidus_T(j) = T_display(liq_idx);
        end

        % Solidus: first temperature where phase is solid
        sol_idx = find(col == 2, 1, 'last');
        if isempty(sol_idx)
            solidus_T(j) = T_display(1);
        else
            solidus_T(j) = T_display(sol_idx);
        end
    end

    % Fill regions
    x_pct = x_grid * 100;
    fill([x_pct, fliplr(x_pct)], [liquidus_T, ones(size(liquidus_T))*max(T_display)], ...
         [1.0 0.85 0.85], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    fill([x_pct, fliplr(x_pct)], [solidus_T, fliplr(liquidus_T)], ...
         [0.85 0.95 0.85], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    fill([x_pct, fliplr(x_pct)], [ones(size(solidus_T))*min(T_display), solidus_T], ...
         [0.85 0.85 1.0], 'EdgeColor', 'none', 'FaceAlpha', 0.5);

    % Plot lines
    plot(x_pct, liquidus_T, 'r-', 'LineWidth', 2, 'DisplayName', 'Liquidus');
    plot(x_pct, solidus_T, 'b-', 'LineWidth', 2, 'DisplayName', 'Solidus');

    % Phase labels
    [~, mid_idx] = min(abs(x_grid - 0.5));
    text(50, max(T_display)*0.95, 'Liquid', 'FontSize', 12, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', 'Color', [0.8 0.1 0.1]);
    text(50, (liquidus_T(mid_idx) + solidus_T(mid_idx))/2, 'L + S', ...
         'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
         'Color', [0.1 0.6 0.1]);
    text(50, min(T_display) + (solidus_T(mid_idx) - min(T_display))*0.3, 'Solid', ...
         'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
         'Color', [0.1 0.1 0.8]);

    % Tie line
    if ~isempty(opts.ShowTieLine)
        T_tie = opts.ShowTieLine;
        if strcmpi(opts.Units, 'C')
            T_tie_display = T_tie - 273.15;
        else
            T_tie_display = T_tie;
        end
        plot([0 100], [T_tie_display T_tie_display], 'k--', 'LineWidth', 1.5, ...
             'DisplayName', sprintf('Tie line @ %.0f%s', T_tie_display, char(176)));

        if ~isempty(opts.Composition)
            xB = opts.Composition;
            plot(xB*100, T_tie_display, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'y', ...
                 'DisplayName', sprintf('x_B = %.2f', xB));
        end
    end

    hold off;

    xlabel(sprintf('Composition (wt%% %s)', label_B), 'FontSize', 12);
    ylabel(T_label, 'FontSize', 12);
    title(sprintf('%s-%s Phase Diagram', label_A, label_B), 'FontSize', 14);
    legend('Location', 'best');
    grid on;
    set(gca, 'FontSize', 10);
    xlim([0 100]);
end
