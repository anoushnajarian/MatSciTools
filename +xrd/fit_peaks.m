function results = fit_peaks(two_theta, intensity, peak_positions, varargin)
%XRD.FIT_PEAKS Fit analytical profiles to XRD peaks
%   RESULTS = XRD.FIT_PEAKS(TWO_THETA, INTENSITY, PEAK_POSITIONS) fits each
%   peak using a pseudo-Voigt profile by default.
%
%   PEAK_POSITIONS is a vector of approximate 2-theta values for each peak.
%
%   Optional Parameters:
%     'Profile' - 'gaussian', 'lorentzian', or 'pseudo_voigt' (default: 'pseudo_voigt')
%     'Window'  - Half-width of fitting window in degrees (default: 2.0)
%
%   Returns a cell array of structs, one per peak, each containing:
%     center    - Fitted peak center (2-theta)
%     fwhm      - Full width at half maximum (degrees)
%     height    - Peak height (intensity units)
%     area      - Integrated peak area
%     R2        - Coefficient of determination for the fit
%     profile   - Profile type used
%     fitted    - Fitted intensity values in the local window
%     two_theta - Local 2-theta values for the window
%
%   Example:
%     [tt, I, meta] = xrd.generate_pattern();
%     [~, corrected] = xrd.subtract_background(tt, I);
%     peaks = xrd.find_peaks(tt, corrected);
%     fits = xrd.fit_peaks(tt, corrected, peaks.positions);
%     fprintf('Peak 1 center: %.2f deg, FWHM: %.3f deg\n', ...
%         fits{1}.center, fits{1}.fwhm);

    p = inputParser;
    addRequired(p, 'two_theta', @isnumeric);
    addRequired(p, 'intensity', @isnumeric);
    addRequired(p, 'peak_positions', @isnumeric);
    addParameter(p, 'Profile', 'pseudo_voigt', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Window', 2.0, @isnumeric);
    parse(p, two_theta, intensity, peak_positions, varargin{:});

    profile_type = lower(char(p.Results.Profile));
    window       = p.Results.Window;

    two_theta = two_theta(:);
    intensity = intensity(:);
    peak_positions = peak_positions(:)';

    opts = optimset('Display', 'off', 'MaxFunEvals', 5000, 'MaxIter', 2000, ...
                    'TolFun', 1e-10, 'TolX', 1e-10);

    n_peaks = numel(peak_positions);
    results = cell(1, n_peaks);

    for k = 1:n_peaks
        pos = peak_positions(k);

        % Extract local window
        mask = two_theta >= (pos - window) & two_theta <= (pos + window);
        x_local = two_theta(mask);
        y_local = intensity(mask);

        if numel(x_local) < 5
            warning('xrd:TooFewPoints', ...
                'Peak at %.2f deg: fewer than 5 points in window. Skipping.', pos);
            results{k} = empty_result(profile_type);
            continue;
        end

        % Initial guesses: height, center, fwhm, eta (for pseudo-Voigt)
        [h0, max_idx] = max(y_local);
        c0 = x_local(max_idx);
        % Estimate FWHM from half-max width
        half_max = h0 / 2;
        above_half = x_local(y_local >= half_max);
        if numel(above_half) >= 2
            w0 = above_half(end) - above_half(1);
        else
            w0 = 0.3;
        end
        w0 = max(w0, 0.05);

        switch profile_type
            case 'gaussian'
                x0 = [h0, c0, w0];
                cost = @(params) penalized_cost(x_local, y_local, params, ...
                    @gaussian_peak, c0, window);
                pfit = fminsearch(cost, x0, opts);
                pfit(1) = abs(pfit(1));
                pfit(3) = abs(pfit(3));
                y_fit = gaussian_peak(x_local, pfit);
                fit_res = struct('center', pfit(2), 'fwhm', pfit(3), ...
                                 'height', pfit(1));

            case 'lorentzian'
                x0 = [h0, c0, w0];
                cost = @(params) penalized_cost(x_local, y_local, params, ...
                    @lorentzian_peak, c0, window);
                pfit = fminsearch(cost, x0, opts);
                pfit(1) = abs(pfit(1));
                pfit(3) = abs(pfit(3));
                y_fit = lorentzian_peak(x_local, pfit);
                fit_res = struct('center', pfit(2), 'fwhm', pfit(3), ...
                                 'height', pfit(1));

            case 'pseudo_voigt'
                x0 = [h0, c0, w0, 0.5];
                cost = @(params) pseudo_voigt_cost(x_local, y_local, params, c0, window);
                pfit = fminsearch(cost, x0, opts);
                pfit(1) = abs(pfit(1));
                pfit(3) = abs(pfit(3));
                pfit(4) = max(0, min(1, pfit(4)));
                y_fit = pseudo_voigt_peak(x_local, pfit);
                fit_res = struct('center', pfit(2), 'fwhm', pfit(3), ...
                                 'height', pfit(1), 'eta', pfit(4));

            otherwise
                error('xrd:UnknownProfile', ...
                    'Unknown profile: %s. Use: gaussian, lorentzian, pseudo_voigt.', ...
                    profile_type);
        end

        % Compute R-squared
        ss_res = sum((y_local - y_fit).^2);
        ss_tot = sum((y_local - mean(y_local)).^2);
        if ss_tot > 0
            R2 = 1 - ss_res / ss_tot;
        else
            R2 = 0;
        end

        % Compute area by trapezoidal integration of fitted curve
        area = trapz(x_local, y_fit);

        results{k} = struct( ...
            'center',    fit_res.center, ...
            'fwhm',      fit_res.fwhm, ...
            'height',    fit_res.height, ...
            'area',      area, ...
            'R2',        R2, ...
            'profile',   profile_type, ...
            'fitted',    y_fit, ...
            'two_theta', x_local);
    end
end

%% ---- Local profile functions ----

function y = gaussian_peak(x, params)
    H = abs(params(1));
    c = params(2);
    w = abs(params(3));
    y = H * exp(-4 * log(2) * ((x - c) / w).^2);
end

function y = lorentzian_peak(x, params)
    H = abs(params(1));
    c = params(2);
    w = abs(params(3));
    y = H ./ (1 + 4 * ((x - c) / w).^2);
end

function y = pseudo_voigt_peak(x, params)
    H   = abs(params(1));
    c   = params(2);
    w   = abs(params(3));
    eta = max(0, min(1, params(4)));
    G = exp(-4 * log(2) * ((x - c) / w).^2);
    L = 1 ./ (1 + 4 * ((x - c) / w).^2);
    y = H * (eta * L + (1 - eta) * G);
end

function cost = penalized_cost(x, y_data, params, profile_fn, c0, window)
%PENALIZED_COST Cost with penalties for Gaussian/Lorentzian fits
    y_fit = profile_fn(x, params);
    cost = sum((y_data - y_fit).^2);
    % Penalty for negative height or width
    if params(1) < 0
        cost = cost + 1e6 * params(1)^2;
    end
    if params(3) < 0
        cost = cost + 1e6 * params(3)^2;
    end
    % Penalty for center drifting outside the window
    if abs(params(2) - c0) > window
        cost = cost + 1e6 * (params(2) - c0)^2;
    end
    % Penalty for unreasonably wide FWHM
    if params(3) > 2 * window
        cost = cost + 1e6 * (params(3) - 2*window)^2;
    end
end

function cost = pseudo_voigt_cost(x, y_data, params, c0, window)
    y_fit = pseudo_voigt_peak(x, params);
    cost = sum((y_data - y_fit).^2);
    % Penalty to keep eta in [0, 1]
    eta = params(4);
    if eta < 0
        cost = cost + 1e6 * eta^2;
    elseif eta > 1
        cost = cost + 1e6 * (eta - 1)^2;
    end
    % Penalty for negative height or width
    if params(1) < 0
        cost = cost + 1e6 * params(1)^2;
    end
    if params(3) < 0
        cost = cost + 1e6 * params(3)^2;
    end
    % Penalty for center drifting outside the window
    if abs(params(2) - c0) > window
        cost = cost + 1e6 * (params(2) - c0)^2;
    end
    % Penalty for unreasonably wide FWHM
    if params(3) > 2 * window
        cost = cost + 1e6 * (params(3) - 2*window)^2;
    end
end

function res = empty_result(profile_type)
    res = struct('center', NaN, 'fwhm', NaN, 'height', NaN, 'area', NaN, ...
                 'R2', NaN, 'profile', profile_type, 'fitted', [], 'two_theta', []);
end
