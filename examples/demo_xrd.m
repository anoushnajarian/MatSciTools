%% MatSciTools Demo: X-Ray Diffraction Analysis
% This demo shows how to use the xrd module for pattern generation,
% background subtraction, peak fitting, and crystallite size estimation.

%% Setup
addpath(fileparts(fileparts(mfilename('fullpath'))));

%% 1. Generate XRD pattern for FCC Aluminum
fprintf('=== Generate XRD Pattern: FCC Aluminum ===\n');
[two_theta, intensity, meta] = xrd.generate_pattern('Material', 'fcc_al');
fprintf('Material: %s\n', meta.material);
fprintf('Wavelength: %.5f A (Cu Ka)\n', meta.wavelength);
fprintf('Generated %d data points over %.0f-%.0f deg 2theta\n', ...
    numel(two_theta), two_theta(1), two_theta(end));

%% 2. Plot raw pattern
figure('Name', 'XRD Pattern', 'NumberTitle', 'off', 'Position', [100 100 900 400]);
plot(two_theta, intensity, 'b-', 'LineWidth', 1.2);
xlabel('2\theta (degrees)'); ylabel('Intensity (a.u.)');
title('XRD Pattern: FCC Aluminum'); grid on;

%% 3. Background subtraction
fprintf('\n=== Background Subtraction ===\n');
[~, corrected, bg] = xrd.subtract_background(two_theta, intensity);
fprintf('Background subtracted successfully\n');

figure('Name', 'Background Correction', 'NumberTitle', 'off', 'Position', [100 100 900 400]);
plot(two_theta, intensity, 'b-', 'DisplayName', 'Raw');
hold on;
plot(two_theta, bg, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Background');
plot(two_theta, corrected, 'k-', 'DisplayName', 'Corrected');
hold off;
xlabel('2\theta (degrees)'); ylabel('Intensity (a.u.)');
title('Background Subtraction'); legend('Location', 'best'); grid on;

%% 4. Peak finding
fprintf('\n=== Peak Finding ===\n');
peaks = xrd.find_peaks(two_theta, corrected);
fprintf('Found %d peaks:\n', numel(peaks.positions));
for i = 1:numel(peaks.positions)
    fprintf('  Peak %d: 2theta = %.2f deg, intensity = %.1f\n', ...
        i, peaks.positions(i), peaks.intensities(i));
end

%% 5. Peak fitting
fprintf('\n=== Peak Fitting (Pseudo-Voigt) ===\n');
fits = xrd.fit_peaks(two_theta, corrected, peaks.positions);
fprintf('Fitted %d peaks:\n', numel(fits));
for i = 1:numel(fits)
    fprintf('  Peak %d: center=%.2f, FWHM=%.3f, area=%.1f\n', ...
        i, fits(i).center, fits(i).fwhm, fits(i).area);
end

%% 6. Crystallite size estimation (Scherrer equation)
fprintf('\n=== Crystallite Size (Scherrer Equation) ===\n');
for i = 1:min(3, numel(fits))
    cs = xrd.crystallite_size(fits(i).fwhm, fits(i).center);
    fprintf('  Peak at %.2f deg: crystallite size = %.1f nm\n', ...
        fits(i).center, cs);
end

%% 7. Compare different crystal structures
fprintf('\n=== Comparing Crystal Structures ===\n');
materials = {'fcc_al', 'bcc_fe', 'fcc_cu'};
names = {'FCC Al', 'BCC Fe', 'FCC Cu'};

figure('Name', 'XRD Comparison', 'NumberTitle', 'off', 'Position', [100 100 900 500]);
for i = 1:numel(materials)
    [tt, int_i] = xrd.generate_pattern('Material', materials{i});
    subplot(numel(materials), 1, i);
    plot(tt, int_i, 'LineWidth', 1.2);
    xlabel('2\theta (degrees)'); ylabel('Intensity');
    title(names{i}); grid on;
end

fprintf('\nDemo complete!\n');
