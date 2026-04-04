%% MatSciTools Demo: Mechanical Testing Analysis
% This demo shows how to use the mechtest module to analyze
% stress-strain curves from tensile tests.

%% Setup
addpath(fileparts(fileparts(mfilename('fullpath'))));

%% 1. Generate sample steel data
fprintf('=== Generate Synthetic Steel Tensile Test Data ===\n');
[strain_steel, stress_steel] = mechtest.generate_sample('steel');
fprintf('Generated %d data points\n', numel(strain_steel));

%% 2. Analyze the stress-strain curve
fprintf('\n=== Analyze Stress-Strain Data ===\n');
results_steel = mechtest.analyze(strain_steel, stress_steel);

%% 3. Print a formatted report
mechtest.report(results_steel, 'SampleName', 'Synthetic Steel Sample');

%% 4. Plot with annotations
fprintf('=== Plotting Annotated Stress-Strain Curve ===\n');
mechtest.plot(strain_steel, stress_steel, results_steel, ...
    'Title', 'Steel Tensile Test');

%% 5. Compare multiple materials
fprintf('\n=== Comparing Steel vs Aluminum vs Polymer ===\n');
[strain_al, stress_al] = mechtest.generate_sample('aluminum');
[strain_poly, stress_poly] = mechtest.generate_sample('polymer');

results_al = mechtest.analyze(strain_al, stress_al);
results_poly = mechtest.analyze(strain_poly, stress_poly);

mechtest.report(results_al, 'SampleName', 'Synthetic Aluminum');
mechtest.report(results_poly, 'SampleName', 'Synthetic Polymer');

% Overlay comparison plot
ds(1).strain = strain_steel; ds(1).stress = stress_steel; ds(1).name = 'Steel';
ds(2).strain = strain_al;    ds(2).stress = stress_al;    ds(2).name = 'Aluminum';
ds(3).strain = strain_poly;  ds(3).stress = stress_poly;  ds(3).name = 'Polymer';
mechtest.compare(ds, 'Title', 'Material Comparison: Stress-Strain Curves');

fprintf('\nDemo complete!\n');
