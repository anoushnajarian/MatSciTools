function results = williamson_hall_plot(fwhm_deg, two_theta, varargin)
%XRD.WILLIAMSON_HALL_PLOT Williamson-Hall analysis with plot
%   RESULTS = XRD.WILLIAMSON_HALL_PLOT(FWHM_DEG, TWO_THETA) performs
%   Williamson-Hall analysis and generates a beta*cos(theta) vs 4*sin(theta)
%   plot with linear fit.
%
%   Separates crystallite size broadening from microstrain broadening.
%   Intercept = K*lambda/D gives crystallite size D.
%   Slope = microstrain epsilon.
%
%   Optional Parameters:
%     'Wavelength'      - X-ray wavelength in Angstroms (default: 1.5406, Cu Ka)
%     'K'               - Scherrer constant (default: 0.9)
%     'InstrBroadening' - Instrumental broadening in degrees (default: 0)
%     'ShowPlot'        - Generate figure (default: true)
%     'Title'           - Plot title (default: 'Williamson-Hall Plot')
%
%   Returns a struct with:
%     crystallite_size_nm - Estimated crystallite size in nm
%     microstrain         - Microstrain from slope
%     R2                  - R-squared of linear fit
%     fit_coeffs          - [slope, intercept]
%     x                   - 4*sin(theta) values (for custom plotting)
%     y                   - beta*cos(theta) values
%     y_fit               - Fitted line values
%
%   Example:
%     fits = xrd.fit_peaks(tt, corrected, peaks.positions);
%     fwhm = cellfun(@(f) f.fwhm, num2cell(fits));
%     pos  = cellfun(@(f) f.center, num2cell(fits));
%     res  = xrd.williamson_hall_plot(fwhm, pos);

    p = inputParser;
    addRequired(p, 'fwhm_deg', @isnumeric);
    addRequired(p, 'two_theta', @isnumeric);
    addParameter(p, 'Wavelength', 1.5406, @isnumeric);
    addParameter(p, 'K', 0.9, @isnumeric);
    addParameter(p, 'InstrBroadening', 0, @isnumeric);
    addParameter(p, 'ShowPlot', true, @islogical);
    addParameter(p, 'Title', 'Williamson-Hall Plot', @(x) ischar(x)||isstring(x));
    parse(p, fwhm_deg, two_theta, varargin{:});

    lambda      = p.Results.Wavelength;
    K           = p.Results.K;
    instr_broad = p.Results.InstrBroadening;
    show_plot   = p.Results.ShowPlot;
    plot_title  = p.Results.Title;

    fwhm_deg  = fwhm_deg(:);
    two_theta = two_theta(:);

    % Delegate core analysis to crystallite_size
    wh = xrd.crystallite_size(fwhm_deg, two_theta, ...
        'Method', 'williamson_hall', ...
        'Wavelength', lambda, ...
        'K', K, ...
        'InstrBroadening', instr_broad);

    % Recompute x and y vectors for plotting
    if instr_broad > 0
        beta_deg = sqrt(max(fwhm_deg.^2 - instr_broad^2, 0));
    else
        beta_deg = fwhm_deg;
    end
    beta_rad  = beta_deg * pi / 180;
    theta_rad = (two_theta / 2) * pi / 180;

    x = 4 * sin(theta_rad);
    y = beta_rad .* cos(theta_rad);

    slope     = wh.fit_coeffs(1);
    intercept = wh.fit_coeffs(2);
    y_fit     = slope * x + intercept;

    % Build results
    results.crystallite_size_nm = wh.crystallite_size_nm;
    results.microstrain         = wh.microstrain;
    results.R2                  = wh.R2;
    results.fit_coeffs          = wh.fit_coeffs;
    results.x                   = x';
    results.y                   = y';
    results.y_fit               = y_fit';

    % Generate plot
    if show_plot
        figure('Name', plot_title, 'NumberTitle', 'off');
        plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
        hold on;
        x_line = linspace(min(x)*0.95, max(x)*1.05, 100);
        y_line = slope * x_line + intercept;
        plot(x_line, y_line, 'r--', 'LineWidth', 1.5);
        hold off;

        xlabel('4 sin(\theta)');
        ylabel('\beta cos(\theta) (rad)');
        title(plot_title);

        annotation_str = sprintf('D = %.1f nm\n\\epsilon = %.2e\nR^2 = %.4f', ...
            results.crystallite_size_nm, results.microstrain, results.R2);
        text(0.05, 0.95, annotation_str, 'Units', 'normalized', ...
            'VerticalAlignment', 'top', 'FontSize', 10, ...
            'BackgroundColor', 'w', 'EdgeColor', 'k');

        grid on;
        box on;
    end
end
