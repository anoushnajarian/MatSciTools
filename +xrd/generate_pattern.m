function [two_theta, intensity, metadata] = generate_pattern(varargin)
%XRD.GENERATE_PATTERN Generate synthetic XRD pattern for testing
%   [TWO_THETA, INTENSITY, METADATA] = XRD.GENERATE_PATTERN() generates a
%   synthetic XRD pattern for FCC aluminum with default parameters.
%
%   Optional Parameters:
%     'Material'      - Material type: 'fcc_al', 'bcc_fe', 'fcc_austenite',
%                       'dual_phase', 'hcp_ti', 'fcc_cu', 'fcc_ni',
%                       'bcc_cr', 'diamond_si', 'wurtzite_zno',
%                       'rocksalt_nacl' (default: 'fcc_al')
%     'Wavelength'    - X-ray wavelength in Angstroms (default: 1.5406, Cu Ka)
%     'NoiseLevel'    - Noise as fraction of max intensity (default: 0.02)
%     'NumPoints'     - Number of data points (default: 2000)
%     'TwoThetaRange' - [min max] in degrees (default: [20 90])
%
%   METADATA is a struct with: material, wavelength, peak_positions,
%   peak_hkl (ground truth values used for generation).
%
%   Example:
%     [tt, I, meta] = xrd.generate_pattern('Material', 'bcc_fe');
%     plot(tt, I);
%     xlabel('2\theta (degrees)'); ylabel('Intensity (a.u.)');

    p = inputParser;
    addParameter(p, 'Material', 'fcc_al', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Wavelength', 1.5406, @isnumeric);
    addParameter(p, 'NoiseLevel', 0.02, @isnumeric);
    addParameter(p, 'NumPoints', 2000, @isnumeric);
    addParameter(p, 'TwoThetaRange', [20 90], @(x) isnumeric(x)&&numel(x)==2);
    parse(p, varargin{:});

    material   = lower(char(p.Results.Material));
    wavelength = p.Results.Wavelength;
    noise_lvl  = p.Results.NoiseLevel;
    n_pts      = p.Results.NumPoints;
    tt_range   = p.Results.TwoThetaRange;

    % Define peak data for each material (Cu Ka positions)
    switch material
        case 'fcc_al'
            positions = [38.5, 44.7, 65.1, 78.2];
            hkl       = {'111', '200', '220', '311'};
            heights   = [1.0,  0.47, 0.22, 0.24];
            widths    = [0.3,  0.35, 0.40, 0.45];
        case 'bcc_fe'
            positions = [44.7, 65.0, 82.3];
            hkl       = {'110', '200', '211'};
            heights   = [1.0,  0.20, 0.30];
            widths    = [0.35, 0.40, 0.45];
        case 'fcc_austenite'
            positions = [43.6, 50.8, 74.7, 90.7];
            hkl       = {'111', '200', '220', '311'};
            heights   = [1.0,  0.45, 0.25, 0.20];
            widths    = [0.30, 0.35, 0.40, 0.45];
        case 'dual_phase'
            % BCC ferrite + FCC austenite (austenite at lower intensity)
            positions = [43.6, 44.7, 50.8, 65.0, 74.7, 82.3];
            hkl       = {'A111', 'F110', 'A200', 'F200', 'A220', 'F211'};
            heights   = [0.40,  1.0,  0.18, 0.20, 0.10, 0.30];
            widths    = [0.30,  0.35, 0.35, 0.40, 0.40, 0.45];
        case 'hcp_ti'
            positions = [35.1, 38.4, 40.2, 53.0, 63.0, 70.7, 76.2];
            hkl       = {'100', '002', '101', '102', '110', '103', '112'};
            heights   = [0.25, 0.30, 1.0,  0.15, 0.15, 0.12, 0.10];
            widths    = [0.35, 0.30, 0.30, 0.40, 0.40, 0.45, 0.45];
        case 'fcc_cu'
            positions = [43.3, 50.4, 74.1, 89.9];
            hkl       = {'111', '200', '220', '311'};
            heights   = [1.0,  0.46, 0.20, 0.17];
            widths    = [0.30, 0.35, 0.40, 0.45];
        case 'fcc_ni'
            positions = [44.5, 51.8, 76.4];
            hkl       = {'111', '200', '220'};
            heights   = [1.0,  0.42, 0.21];
            widths    = [0.30, 0.35, 0.40];
        case 'bcc_cr'
            positions = [44.4, 64.6, 81.7];
            hkl       = {'110', '200', '211'};
            heights   = [1.0,  0.16, 0.18];
            widths    = [0.35, 0.40, 0.45];
        case 'diamond_si'
            % Silicon — diamond cubic, a = 5.431 A
            positions = [28.4, 47.3, 56.1, 69.1, 76.4];
            hkl       = {'111', '220', '311', '400', '331'};
            heights   = [1.0,  0.55, 0.30, 0.06, 0.11];
            widths    = [0.25, 0.30, 0.35, 0.40, 0.40];
        case 'wurtzite_zno'
            % Zinc oxide — wurtzite (hexagonal), a = 3.250 A, c = 5.207 A
            positions = [31.8, 34.4, 36.3, 47.5, 56.6, 62.9, 67.9];
            hkl       = {'100', '002', '101', '102', '110', '103', '112'};
            heights   = [0.57, 0.44, 1.0,  0.23, 0.32, 0.29, 0.23];
            widths    = [0.30, 0.30, 0.30, 0.35, 0.35, 0.40, 0.40];
        case 'rocksalt_nacl'
            % Sodium chloride — rock salt (FCC), a = 5.640 A
            positions = [31.7, 45.4, 56.5, 66.2, 75.3];
            hkl       = {'200', '220', '222', '400', '420'};
            heights   = [1.0,  0.55, 0.15, 0.12, 0.06];
            widths    = [0.30, 0.35, 0.40, 0.40, 0.45];
        otherwise
            error('xrd:UnknownMaterial', ...
                'Unknown material: %s. Use: fcc_al, bcc_fe, fcc_austenite, dual_phase, hcp_ti, fcc_cu, fcc_ni, bcc_cr, diamond_si, wurtzite_zno, rocksalt_nacl.', ...
                material);
    end

    % Filter peaks to within the requested range
    in_range  = positions >= tt_range(1) & positions <= tt_range(2);
    positions = positions(in_range);
    hkl       = hkl(in_range);
    heights   = heights(in_range);
    widths    = widths(in_range);

    % Generate 2-theta axis
    two_theta = linspace(tt_range(1), tt_range(2), n_pts)';

    % Build intensity from pseudo-Voigt peaks
    intensity = zeros(n_pts, 1);
    eta = 0.5; % mixing parameter for pseudo-Voigt

    for k = 1:numel(positions)
        x = two_theta - positions(k);
        w = widths(k);
        h = heights(k);

        % Gaussian component
        G = exp(-4 * log(2) * (x / w).^2);
        % Lorentzian component
        L = 1 ./ (1 + 4 * (x / w).^2);
        % Pseudo-Voigt
        pv = h * (eta * L + (1 - eta) * G);

        intensity = intensity + pv;
    end

    % Scale to ~1000 counts
    intensity = intensity * 1000;

    % Add polynomial background
    t_norm = (two_theta - tt_range(1)) / (tt_range(2) - tt_range(1));
    background = 50 + 30 * t_norm - 20 * t_norm.^2 + 10 * t_norm.^3;
    intensity = intensity + background;

    % Add Gaussian noise
    if noise_lvl > 0
        rng(42);
        intensity = intensity + noise_lvl * max(intensity) * randn(n_pts, 1);
        intensity = max(intensity, 0);
    end

    % Build metadata
    metadata.material       = material;
    metadata.wavelength     = wavelength;
    metadata.peak_positions = positions;
    metadata.peak_hkl       = hkl;
end
