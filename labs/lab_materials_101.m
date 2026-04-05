%% Materials Science 101: Mechanical Testing Fundamentals
%  MatSciTools Educational Lab
%  -------------------------------------------------------
%  Prerequisites: Run setup() first
%  Time: ~90 minutes (full lab) or ~30 min per section
%  -------------------------------------------------------
%  This lab introduces tensile testing, mechanical property
%  extraction, alloy comparison, and ASTM E8 compliance
%  using the MatSciTools analysis toolkit.

%% Part 1: Understanding Stress-Strain Curves (~15 min)
% In a tensile test, a specimen is pulled until it breaks.
% The machine records force and displacement, which we convert
% to engineering stress (sigma = F/A0) and strain (epsilon = dL/L0).
%
% Key regions: elastic, yielding, strain hardening, necking, fracture.

% Generate synthetic steel tensile data
[strain, stress] = mechtest.generate_sample('AISI 1045 Steel');

% Plot the stress-strain curve
figure('Name', 'Steel Tensile Test', 'NumberTitle', 'off', ...
    'Position', [100 100 800 500]);
plot(strain * 100, stress, 'b-', 'LineWidth', 1.5);
xlabel('Engineering Strain (%)');
ylabel('Engineering Stress (MPa)');
title('AISI 1045 Steel - Tensile Test');
grid on;

% QUESTION: Identify these regions on your plot:
%   1. Linear elastic region
%   2. Yield point (where plastic deformation begins)
%   3. Strain hardening region
%   4. Ultimate tensile strength (maximum stress)
%   5. Fracture point

%% Part 2: Extracting Mechanical Properties (~20 min)
% Key properties from a tensile test:
%   E  = Young's modulus (slope of elastic region) [GPa]
%   YS = Yield strength (0.2% offset method) [MPa]
%   UTS = Ultimate tensile strength (max stress) [MPa]
%   Elongation = strain at fracture [%]
%   Toughness = area under the curve [MJ/m^3]

results = mechtest.analyze(strain, stress);
mechtest.report(results, 'SampleName', 'AISI 1045 Steel');

% Plot with annotations
mechtest.plot(strain, stress, results, 'Title', 'Steel Properties');

% TODO: Calculate Young's modulus manually from the elastic region.
% Steps:
%   1. Find points where strain < 0.002 (elastic region)
%   2. Use polyfit(strain_elastic, stress_elastic, 1) to fit a line
%   3. The slope is E in MPa; divide by 1000 for GPa
%
% elastic_mask = strain < 0.002;
% your_E_GPa = ???;
% fprintf('Manual E = %.0f GPa, MatSciTools E = %.0f GPa\n', your_E_GPa, results.youngs_modulus);

% EXPECTED:
% your_E_GPa should be approximately 200-210 GPa

% QUESTION: Why is the 0.2% offset method used to define yield
% strength instead of just reading the stress where the curve bends?

%% Part 3: Comparing Multiple Materials (~20 min)
% Different material classes have vastly different properties.
% Let's compare a metal, a polymer, and a ceramic (via database).

% Generate stress-strain data for multiple materials
materials = {'AISI 1045 Steel', 'Al 6061-T6', 'Polycarbonate'};
colors = [0.000 0.447 0.741; 0.850 0.325 0.098; 0.466 0.674 0.188];

figure('Name', 'Material Comparison', 'NumberTitle', 'off', ...
    'Position', [100 100 900 500]);
all_results = cell(1, numel(materials));

for i = 1:numel(materials)
    [s, st] = mechtest.generate_sample(materials{i});
    all_results{i} = mechtest.analyze(s, st);
    plot(s * 100, st, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
        'DisplayName', materials{i});
    hold on;
end
hold off;
xlabel('Strain (%)'); ylabel('Stress (MPa)');
title('Stress-Strain Comparison');
legend('Location', 'best'); grid on;

% Compare properties side-by-side using the database
T = matdb.compare(materials);
disp(T);

% TODO: Calculate specific strength (UTS / density) for each material.
% Use matdb.get() to look up density for each material.
%
% for i = 1:numel(materials)
%     mat = matdb.get(materials{i});
%     specific_strength = mat.uts / mat.density;
%     fprintf('%s: specific strength = %.2f MPa/(kg/m^3)\n', ...
%         materials{i}, specific_strength);
% end

% QUESTION: A bicycle frame needs to be light AND strong.
% Rank these materials by specific strength. Which would you choose,
% and what other factors (cost, corrosion, fatigue) matter?

%% Part 4: True vs Engineering Stress-Strain (~15 min)
% Engineering stress uses original area A0 and length L0.
% True stress accounts for the changing cross-section:
%   sigma_true = sigma_eng * (1 + epsilon_eng)
%   epsilon_true = ln(1 + epsilon_eng)
% Valid only up to necking (uniform deformation).

[strain_steel, stress_steel] = mechtest.generate_sample('AISI 1045 Steel', 'Noise', 0);
[true_strain, true_stress] = mechtest.true_stress_strain(strain_steel, stress_steel);

figure('Name', 'True vs Engineering', 'NumberTitle', 'off', ...
    'Position', [100 100 800 500]);
plot(strain_steel * 100, stress_steel, 'b-', 'LineWidth', 2, ...
    'DisplayName', 'Engineering');
hold on;
plot(true_strain * 100, true_stress, 'r--', 'LineWidth', 2, ...
    'DisplayName', 'True');
hold off;
xlabel('Strain (%)'); ylabel('Stress (MPa)');
title('Engineering vs True Stress-Strain');
legend('Location', 'best'); grid on;

% TODO: Compute true stress-strain manually from the engineering data
% (up to the UTS point only).
%
% [~, uts_idx] = max(stress_steel);
% eng_s = strain_steel(1:uts_idx);
% eng_st = stress_steel(1:uts_idx);
% my_true_strain = ???;   % Hint: log(1 + eng_s)
% my_true_stress = ???;   % Hint: eng_st .* (1 + eng_s)

% EXPECTED:
% my_true_strain = log(1 + eng_s);
% my_true_stress = eng_st .* (1 + eng_s);

% QUESTION: Why does the true stress-strain curve NOT show a
% peak and decline like the engineering curve?
% Hint: Think about what happens to cross-sectional area during necking.

%% Part 5: Constitutive Models and ASTM Compliance (~20 min)
% Constitutive models describe the plastic flow behavior:
%   Hollomon:  sigma = K * epsilon^n
%   Ludwik:    sigma = sigma_0 + K * epsilon^n
%   Voce:      sigma = sigma_s - (sigma_s - sigma_0) * exp(-n*epsilon)
%   Swift:     sigma = K * (epsilon_0 + epsilon)^n

% Fit constitutive models
models = mechtest.constitutive_models(strain_steel, stress_steel);
fprintf('\nConstitutive Model Parameters:\n');
fprintf('  Hollomon: K=%.0f MPa, n=%.3f (R²=%.4f)\n', ...
    models.hollomon.K, models.hollomon.n, models.hollomon.R2);
fprintf('  Voce:     sigma_s=%.0f, sigma_0=%.0f (R²=%.4f)\n', ...
    models.voce.sigma_s, models.voce.sigma_0, models.voce.R2);

% Check ASTM E8 compliance
e8 = standards.astm_e8(strain_steel, stress_steel);
fprintf('\nASTM E8 Compliance:\n');
fields = fieldnames(e8.checks);
for i = 1:numel(fields)
    check = e8.checks.(fields{i});
    if check.pass
        fprintf('  [PASS] %s\n', check.description);
    else
        fprintf('  [FAIL] %s\n', check.description);
    end
end

% TODO: Use matsel.ashby() to create an Ashby chart of
% density vs Young's modulus for all materials.
% Identify where our three test materials fall on the chart.
%
% matsel.ashby('density', 'youngs_modulus');

% QUESTION: If a test fails ASTM E8 compliance, what should
% the technician do? Can the data still be reported?

%% Grading Rubric (Instructor Reference)
% Part 1: Curve regions identified correctly (15 pts)
% Part 2: Manual E within 10% of automated; 0.2% offset understood (20 pts)
% Part 3: Specific strength calculated; material selection justified (25 pts)
% Part 4: Manual true stress-strain matches automated (20 pts)
% Part 5: ASTM compliance interpreted; Ashby chart created (20 pts)
