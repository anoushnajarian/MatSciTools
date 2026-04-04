%% MatSciTools Demo: Advanced Mechanical Testing
% This demo shows Phase 2 features: true stress-strain conversion,
% multi-specimen statistics, and the expanded material database.

%% Setup
addpath(fileparts(fileparts(mfilename('fullpath'))));

%% 1. True Stress-Strain Conversion
fprintf('=== True vs Engineering Stress-Strain ===\n');
[eng_strain, eng_stress] = mechtest.generate_sample('steel', 'Noise', 0);
[true_strain, true_stress] = mechtest.true_stress_strain(eng_strain, eng_stress);

figure('Name', 'True vs Engineering', 'NumberTitle', 'off', 'Position', [100 100 800 550]);
plot(eng_strain*100, eng_stress, 'b-', 'LineWidth', 2, 'DisplayName', 'Engineering');
hold on;
plot(true_strain*100, true_stress, 'r--', 'LineWidth', 2, 'DisplayName', 'True');
hold off;
xlabel('Strain (%)'); ylabel('Stress (MPa)');
title('Engineering vs True Stress-Strain'); legend('Location', 'best'); grid on;

%% 2. Multi-Specimen Statistical Analysis
fprintf('\n=== Multi-Specimen Statistics (5 steel specimens) ===\n');
clear results_batch;
for i = 1:5
    [s, st] = mechtest.generate_sample('steel');
    results_batch(i) = mechtest.analyze(s, st); %#ok<SAGROW>
end
stats = mechtest.statistics(results_batch);
mechtest.stats_report(stats, 'TestName', 'Steel Batch (5 specimens)');

%% 3. Expanded Database
fprintf('=== Expanded Material Database ===\n');
T = matdb.list();
fprintf('Total materials in database: %d\n', height(T));
fprintf('\nNew high-performance metals:\n');
mat = matdb.get('Maraging Steel 250');
fprintf('  %s: sy=%.0f MPa, UTS=%.0f MPa\n', mat.name, mat.yield_strength, mat.uts);
mat = matdb.get('Inconel 718');
fprintf('  %s: sy=%.0f MPa, UTS=%.0f MPa\n', mat.name, mat.yield_strength, mat.uts);

fprintf('\nNew polymers:\n');
mat = matdb.get('PEEK');
fprintf('  %s: E=%.1f GPa, sy=%.0f MPa\n', mat.name, mat.youngs_modulus, mat.yield_strength);
mat = matdb.get('ABS');
fprintf('  %s: E=%.1f GPa, sy=%.0f MPa\n', mat.name, mat.youngs_modulus, mat.yield_strength);

fprintf('\nDemo complete!\n');
