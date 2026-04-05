%% X-Ray Diffraction Analysis Lab
%  MatSciTools Educational Lab
%  -------------------------------------------------------
%  Prerequisites: Run setup() first
%  Time: ~90 minutes (full lab) or ~30 min per section
%  -------------------------------------------------------
%  This lab introduces XRD pattern processing, peak analysis,
%  crystallite size measurement, and phase identification
%  using the MatSciTools XRD toolkit.
%
%  Background reading:
%    Cullity & Stock, "Elements of X-Ray Diffraction", Ch. 1-3

%% Part 1: Understanding XRD Patterns (~15 min)
% X-rays scatter off crystal planes. When Bragg's law is satisfied:
%   n * lambda = 2 * d * sin(theta)
% constructive interference produces a diffraction peak.
%
% lambda = wavelength (Cu Ka = 1.5406 Angstroms)
% d = interplanar spacing
% theta = diffraction angle (we measure 2*theta)

% Generate an FCC aluminum pattern
[two_theta, intensity, meta] = xrd.generate_pattern('Material', 'fcc_al');
fprintf('Material: %s\n', meta.material);
fprintf('Wavelength: %.4f Angstroms (Cu Ka)\n', meta.wavelength);
fprintf('Number of peaks: %d\n', numel(meta.peak_positions));

% Plot the raw pattern
figure('Name', 'FCC Al XRD Pattern', 'NumberTitle', 'off', ...
    'Position', [100 100 900 400]);
plot(two_theta, intensity, 'b-', 'LineWidth', 1.2);
xlabel('2\theta (degrees)'); ylabel('Intensity (a.u.)');
title('XRD Pattern: FCC Aluminum (Cu K\alpha)');
grid on;

% QUESTION: Each peak corresponds to a set of crystal planes (hkl).
% For FCC, the first four peaks are (111), (200), (220), (311).
% Why are some peaks stronger than others?
% Hint: Structure factor and multiplicity

%% Part 2: Background Subtraction and Peak Finding (~15 min)
% Real XRD patterns have background from fluorescence, air scatter,
% and amorphous content. We must remove it before peak analysis.

[~, corrected, bg] = xrd.subtract_background(two_theta, intensity);

figure('Name', 'Background Subtraction', 'NumberTitle', 'off', ...
    'Position', [100 100 900 400]);
plot(two_theta, intensity, 'b-', 'DisplayName', 'Raw');
hold on;
plot(two_theta, bg, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Background');
plot(two_theta, corrected, 'k-', 'DisplayName', 'Corrected');
hold off;
xlabel('2\theta (degrees)'); ylabel('Intensity (a.u.)');
title('Background Subtraction'); legend('Location', 'best'); grid on;

% Find peaks
peaks = xrd.find_peaks(two_theta, corrected);
fprintf('\nDetected %d peaks:\n', peaks.count);
for i = 1:peaks.count
    d = xrd.bragg(peaks.positions(i));
    fprintf('  Peak %d: 2theta = %.2f deg, d = %.4f A, I = %.0f\n', ...
        i, peaks.positions(i), d, peaks.intensities(i));
end

% TODO: Calculate d-spacing manually for each peak using Bragg's law.
%   lambda = 1.5406;  % Angstroms
%   my_d = lambda ./ (2 * sind(peaks.positions / 2));
% Compare with xrd.bragg() results.

% QUESTION: If you used Mo Ka radiation (lambda = 0.7107 A) instead
% of Cu Ka, how would all peak positions shift? Why?
% EXPECTED: All peaks shift to lower 2-theta values (shorter wavelength
% means smaller angles satisfy Bragg's law)

%% Part 3: Peak Fitting (~20 min)
% Peaks are fitted with analytical profiles to extract precise
% center, width (FWHM), and area.
%
% Profile types:
%   Gaussian  - dominated by strain broadening
%   Lorentzian - dominated by size broadening
%   Pseudo-Voigt - weighted mixture (most realistic)

fits = xrd.fit_peaks(two_theta, corrected, peaks.positions);

fprintf('\nPeak Fitting Results (pseudo-Voigt):\n');
fprintf('  %-8s %-10s %-10s %-10s %-8s\n', ...
    'Peak', 'Center', 'FWHM', 'Area', 'R²');
for i = 1:numel(fits)
    fprintf('  %-8d %-10.3f %-10.4f %-10.1f %-8.4f\n', ...
        i, fits{i}.center, fits{i}.fwhm, fits{i}.area, fits{i}.R2);
end

% Compare different profile types
profiles = {'gaussian', 'lorentzian', 'pseudo_voigt'};
figure('Name', 'Profile Comparison', 'NumberTitle', 'off', ...
    'Position', [100 100 900 400]);
for ip = 1:3
    subplot(1, 3, ip);
    fp = xrd.fit_peaks(two_theta, corrected, peaks.positions(1), ...
        'Profile', profiles{ip});
    plot(fp{1}.two_theta, corrected(two_theta >= fp{1}.two_theta(1) & ...
        two_theta <= fp{1}.two_theta(end)), 'b.', 'MarkerSize', 4);
    hold on;
    plot(fp{1}.two_theta, fp{1}.fitted, 'r-', 'LineWidth', 1.5);
    hold off;
    title(sprintf('%s (R²=%.3f)', strrep(profiles{ip}, '_', '-'), fp{1}.R2));
    xlabel('2\theta'); ylabel('Intensity');
    grid on;
end

% TODO: Which profile type gives the best R² for this material?
% Try fitting all peaks with each profile and compare average R².

%% Part 4: Crystallite Size Analysis (~20 min)
% Peak broadening contains information about crystallite size
% and microstrain:
%
% Scherrer equation (size only):
%   D = K * lambda / (beta * cos(theta))
%   K = 0.9 (shape factor), beta = FWHM in radians
%
% Williamson-Hall (size + strain separation):
%   beta*cos(theta) = K*lambda/D + 4*epsilon*sin(theta)
%   Plot beta*cos(theta) vs 4*sin(theta)
%   Intercept -> crystallite size, Slope -> microstrain

% Scherrer analysis on each peak
fwhm_values = zeros(1, numel(fits));
center_values = zeros(1, numel(fits));
for i = 1:numel(fits)
    fwhm_values(i) = fits{i}.fwhm;
    center_values(i) = fits{i}.center;
end

scherrer = xrd.crystallite_size(fwhm_values, center_values);
fprintf('\nScherrer Crystallite Size:\n');
for i = 1:numel(scherrer.crystallite_size_nm)
    fprintf('  Peak at %.1f deg: D = %.1f nm\n', ...
        center_values(i), scherrer.crystallite_size_nm(i));
end

% Williamson-Hall analysis (needs >= 2 peaks)
if numel(fits) >= 2
    wh = xrd.crystallite_size(fwhm_values, center_values, ...
        'Method', 'williamson_hall');
    fprintf('\nWilliamson-Hall Analysis:\n');
    fprintf('  Crystallite size: %.1f nm\n', wh.crystallite_size_nm);
    fprintf('  Microstrain: %.2e\n', wh.microstrain);
    fprintf('  R² of fit: %.4f\n', wh.R2);

    % Plot W-H diagram
    wh_plot = xrd.williamson_hall_plot(fwhm_values, center_values);
end

% TODO: Calculate Scherrer size manually for the first peak.
%   K = 0.9;
%   lambda = 1.5406;
%   beta_rad = fits{1}.fwhm * pi / 180;
%   theta_rad = fits{1}.center / 2 * pi / 180;
%   D_angstrom = K * lambda / (beta_rad * cos(theta_rad));
%   D_nm = D_angstrom / 10;
% Compare with the automated result.

% QUESTION: If all peaks give similar crystallite sizes, what does
% that tell you about microstrain in the sample?
% EXPECTED: Minimal microstrain — broadening is dominated by size effects.

% TODO: Try adding instrument broadening correction:
%   res = xrd.crystallite_size(fwhm_values, center_values, ...
%       'InstrBroadening', 0.05);
% How does the corrected size compare to uncorrected?

%% Part 5: Comparing Crystal Structures (~20 min)
% Different crystal structures produce different diffraction patterns.
% This is the basis for phase identification.

structures = {'fcc_al', 'bcc_fe', 'hcp_ti', 'fcc_cu'};
names = {'FCC Aluminum', 'BCC Iron', 'HCP Titanium', 'FCC Copper'};

figure('Name', 'Crystal Structure Comparison', 'NumberTitle', 'off', ...
    'Position', [100 100 900 600]);
for i = 1:numel(structures)
    [tt, int_i] = xrd.generate_pattern('Material', structures{i});
    [~, cor_i] = xrd.subtract_background(tt, int_i);
    subplot(numel(structures), 1, i);
    plot(tt, cor_i, 'LineWidth', 1.2);
    ylabel('I (a.u.)');
    title(names{i}); grid on;
    if i == numel(structures)
        xlabel('2\theta (degrees)');
    end
end

% TODO: Compare FCC Al and FCC Cu patterns. They have the same
% crystal structure but different lattice parameters.
% Calculate the lattice parameter 'a' for each from the (111) peak:
%   d_111 = xrd.bragg(peak_position_111);
%   a = d_111 * sqrt(1^2 + 1^2 + 1^2);  % a = d * sqrt(h^2+k^2+l^2)
% Reference: Al a=4.050 A, Cu a=3.615 A

% QUESTION: How would you distinguish between FCC iron (austenite)
% and FCC aluminum from XRD alone? They have the same structure.
% EXPECTED: Different lattice parameters give different peak positions.
% Compare d-spacings at same (hkl).

% QUESTION: A dual-phase steel contains both BCC ferrite and FCC
% austenite. Sketch what its XRD pattern would look like.

%% Grading Rubric (Instructor Reference)
% Part 1: Pattern understanding (15 pts)
%   - Identifies peak origins (structure factor, multiplicity) (10 pts)
%   - Clean labeled plot (5 pts)
%
% Part 2: Processing and peak finding (20 pts)
%   - Manual d-spacing matches xrd.bragg() within 0.5% (10 pts)
%   - Mo Ka question correct (5 pts)
%   - Understands background sources (5 pts)
%
% Part 3: Peak fitting (20 pts)
%   - Profile comparison completed (10 pts)
%   - Best profile identified with justification (5 pts)
%   - Clean overlay plots (5 pts)
%
% Part 4: Crystallite size (25 pts)
%   - Manual Scherrer within 5% of automated (10 pts)
%   - W-H interpretation correct (10 pts)
%   - Instrument broadening effect understood (5 pts)
%
% Part 5: Structure comparison (20 pts)
%   - Lattice parameter calculation correct (10 pts)
%   - FCC Fe vs FCC Al distinction explained (5 pts)
%   - Dual-phase sketch reasonable (5 pts)
