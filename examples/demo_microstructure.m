%% MatSciTools Demo: Microstructure Analysis
% This demo shows how to use the microstructure module for grain size
% measurement, porosity analysis, and phase fraction estimation.

%% Setup
addpath(fileparts(fileparts(mfilename('fullpath'))));

%% 1. Generate synthetic grain structure
fprintf('=== Generate Synthetic Grain Microstructure ===\n');
[img_grains, meta] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 40);
fprintf('Generated %dx%d image with %d grains\n', meta.size(1), meta.size(2), meta.num_grains);

%% 2. Grain size analysis
fprintf('\n=== Grain Size Analysis (Linear Intercept Method) ===\n');
gs_results = microstructure.grainsize(img_grains, 'PixelSize', 0.5, 'NumLines', 30);
microstructure.report(gs_results, 'grainsize', 'SampleName', 'Synthetic Grain Structure');

%% 3. Generate porous structure
fprintf('=== Generate Synthetic Porous Microstructure ===\n');
[img_porous, meta_p] = microstructure.generate_synthetic('Type', 'porous', 'Porosity', 0.08);
fprintf('Generated image with %d pores (target: %.0f%% porosity)\n', ...
    meta_p.num_pores, meta_p.target_porosity * 100);

%% 4. Porosity analysis
fprintf('\n=== Porosity Analysis ===\n');
por_results = microstructure.porosity(img_porous);
microstructure.report(por_results, 'porosity', 'SampleName', 'Synthetic Porous Sample');

%% 5. Dual-phase microstructure
fprintf('=== Dual-Phase Analysis ===\n');
[img_dp, meta_dp] = microstructure.generate_synthetic('Type', 'dual_phase', 'NumGrains', 50);
pf_results = microstructure.phase_fraction(img_dp, 'NumPhases', 2);
microstructure.report(pf_results, 'phase_fraction', 'SampleName', 'Dual-Phase Steel');

fprintf('\nDemo complete!\n');
