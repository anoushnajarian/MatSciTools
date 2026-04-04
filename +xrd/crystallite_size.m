function results = crystallite_size(fwhm_deg, two_theta, varargin)
%XRD.CRYSTALLITE_SIZE Estimate crystallite size via Scherrer or Williamson-Hall
%   RESULTS = XRD.CRYSTALLITE_SIZE(FWHM_DEG, TWO_THETA) estimates crystallite
%   size using the Scherrer equation.
%
%   FWHM_DEG is a vector of peak FWHMs in degrees.
%   TWO_THETA is a vector of corresponding peak positions in degrees.
%
%   Optional Parameters:
%     'Wavelength'      - X-ray wavelength in Angstroms (default: 1.5406)
%     'K'               - Scherrer constant (default: 0.9)
%     'InstrBroadening' - Instrumental broadening in degrees (default: 0)
%     'Method'          - 'scherrer' or 'williamson_hall' (default: 'scherrer')
%
%   Scherrer equation: D = K * lambda / (beta * cos(theta))
%     where beta is the corrected FWHM in radians.
%
%   Williamson-Hall: plots beta*cos(theta) vs 4*sin(theta), fits a line.
%     Intercept = K*lambda/D, slope = microstrain.
%
%   Returns a struct with:
%     crystallite_size_nm - Estimated size in nanometers (scalar for W-H,
%                           vector for Scherrer)
%     method              - Method used
%     For Williamson-Hall also:
%       microstrain       - Microstrain from slope
%       R2                - R-squared of linear fit
%       fit_coeffs        - [slope, intercept] of the linear fit
%
%   Example:
%     fits = xrd.fit_peaks(tt, corrected, peaks.positions);
%     fwhm = cellfun(@(f) f.fwhm, fits);
%     pos  = cellfun(@(f) f.center, fits);
%     res  = xrd.crystallite_size(fwhm, pos);
%     fprintf('Crystallite size: %.1f nm\n', mean(res.crystallite_size_nm));

    p = inputParser;
    addRequired(p, 'fwhm_deg', @isnumeric);
    addRequired(p, 'two_theta', @isnumeric);
    addParameter(p, 'Wavelength', 1.5406, @isnumeric);
    addParameter(p, 'K', 0.9, @isnumeric);
    addParameter(p, 'InstrBroadening', 0, @isnumeric);
    addParameter(p, 'Method', 'scherrer', @(x) ischar(x)||isstring(x));
    parse(p, fwhm_deg, two_theta, varargin{:});

    lambda     = p.Results.Wavelength;
    K          = p.Results.K;
    instr_broad = p.Results.InstrBroadening;
    method     = lower(char(p.Results.Method));

    fwhm_deg  = fwhm_deg(:);
    two_theta = two_theta(:);

    if numel(fwhm_deg) ~= numel(two_theta)
        error('xrd:SizeMismatch', ...
            'FWHM and two_theta vectors must have the same length.');
    end

    % Correct for instrumental broadening (quadrature subtraction)
    if instr_broad > 0
        beta_deg = sqrt(max(fwhm_deg.^2 - instr_broad^2, 0));
    else
        beta_deg = fwhm_deg;
    end

    % Convert to radians
    beta_rad  = beta_deg * pi / 180;
    theta_rad = (two_theta / 2) * pi / 180;

    switch method
        case 'scherrer'
            % D = K * lambda / (beta * cos(theta)), convert Angstroms to nm
            D_angstrom = K * lambda ./ (beta_rad .* cos(theta_rad));
            D_nm = D_angstrom / 10;

            results.crystallite_size_nm = D_nm';
            results.method = 'scherrer';

        case 'williamson_hall'
            if numel(fwhm_deg) < 2
                error('xrd:InsufficientPeaks', ...
                    'Williamson-Hall requires at least 2 peaks.');
            end

            % y = beta*cos(theta), x = 4*sin(theta)
            y_wh = beta_rad .* cos(theta_rad);
            x_wh = 4 * sin(theta_rad);

            % Linear fit: y = slope * x + intercept
            n = numel(x_wh);
            sx  = sum(x_wh);
            sy  = sum(y_wh);
            sxy = sum(x_wh .* y_wh);
            sxx = sum(x_wh.^2);

            slope     = (n * sxy - sx * sy) / (n * sxx - sx^2);
            intercept = (sy - slope * sx) / n;

            % Crystallite size from intercept: intercept = K*lambda/D
            D_angstrom = K * lambda / intercept;
            D_nm = D_angstrom / 10;

            % R-squared
            y_pred = slope * x_wh + intercept;
            ss_res = sum((y_wh - y_pred).^2);
            ss_tot = sum((y_wh - mean(y_wh)).^2);
            if ss_tot > 0
                R2 = 1 - ss_res / ss_tot;
            else
                R2 = 0;
            end

            results.crystallite_size_nm = D_nm;
            results.method       = 'williamson_hall';
            results.microstrain  = slope;
            results.R2           = R2;
            results.fit_coeffs   = [slope, intercept];

        otherwise
            error('xrd:UnknownMethod', ...
                'Unknown method: %s. Use: scherrer, williamson_hall.', method);
    end
end
