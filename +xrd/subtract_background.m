function [two_theta, corrected, background] = subtract_background(two_theta, intensity, varargin)
%XRD.SUBTRACT_BACKGROUND Remove background from XRD intensity data
%   [TWO_THETA, CORRECTED, BACKGROUND] = XRD.SUBTRACT_BACKGROUND(TWO_THETA, INTENSITY)
%   subtracts an iteratively-fitted polynomial background from the XRD pattern.
%
%   Optional Parameters:
%     'Method' - 'polynomial' or 'linear' (default: 'polynomial')
%     'Order'  - Polynomial order for 'polynomial' method (default: 4)
%
%   The polynomial method iteratively fits, then clips data to the minimum of
%   the current data and fit, repeating until convergence. This pulls the fit
%   beneath the peaks to estimate the true background.
%
%   CORRECTED is clipped at zero (no negative intensities).
%
%   Example:
%     [tt, I] = xrd.generate_pattern();
%     [tt, corrected, bg] = xrd.subtract_background(tt, I);
%     plot(tt, I, tt, bg, tt, corrected);

    p = inputParser;
    addRequired(p, 'two_theta', @isnumeric);
    addRequired(p, 'intensity', @isnumeric);
    addParameter(p, 'Method', 'polynomial', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Order', 4, @isnumeric);
    parse(p, two_theta, intensity, varargin{:});

    method = lower(char(p.Results.Method));
    order  = p.Results.Order;

    two_theta = two_theta(:);
    intensity = intensity(:);

    switch method
        case 'polynomial'
            background = fit_iterative_poly(two_theta, intensity, order);
        case 'linear'
            background = fit_linear_bg(two_theta, intensity);
        otherwise
            error('xrd:UnknownMethod', ...
                'Unknown method: %s. Use: polynomial, linear.', method);
    end

    corrected = intensity - background;
    corrected = max(corrected, 0);
end

function bg = fit_iterative_poly(x, y, order)
%FIT_ITERATIVE_POLY Iterative polynomial background estimation
    max_iter = 100;
    tol = 1e-6;

    % Normalize x for numerical stability
    x_min = min(x);
    x_max = max(x);
    x_norm = (x - x_min) / (x_max - x_min);

    working = y;
    for iter = 1:max_iter
        % Fit polynomial to current working data
        coeffs = polyfit(x_norm, working, order);
        fit_vals = polyval(coeffs, x_norm);

        % Clip: take minimum of data and fit
        new_working = min(working, fit_vals);

        % Check convergence
        if max(abs(new_working - working)) < tol * max(abs(y))
            break;
        end
        working = new_working;
    end

    % Final fit on the converged working data
    coeffs = polyfit(x_norm, working, order);
    bg = polyval(coeffs, x_norm);
end

function bg = fit_linear_bg(x, y)
%FIT_LINEAR_BG Simple linear background between endpoints
    n = numel(x);
    % Average a few points at each end for robustness
    n_avg = max(1, round(0.02 * n));
    y_start = mean(y(1:n_avg));
    y_end   = mean(y(end-n_avg+1:end));

    bg = y_start + (y_end - y_start) * (x - x(1)) / (x(end) - x(1));
end
