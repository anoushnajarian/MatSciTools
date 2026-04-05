%% Microstructure Analysis Lab
%  MatSciTools Educational Lab
%  -------------------------------------------------------
%  Prerequisites: Run setup() first
%  Time: ~90 minutes (full lab) or ~20-40 min per section
%  -------------------------------------------------------
%  This lab introduces metallographic image analysis:
%  synthetic microstructure generation, grain size measurement
%  (ASTM E112), porosity analysis, and phase fraction quantification.
%
%  Background reading:
%    Vander Voort, "Metallography: Principles and Practice"
%    ASTM E112-13 Standard Test Methods for Grain Size

%% Part 1: Generating and Viewing Microstructures (~15 min)
% In metallography, polished and etched samples reveal the
% microstructure under a microscope. Grain boundaries appear
% as dark lines because etching preferentially attacks the
% high-energy boundary regions.

% Generate a fine-grained microstructure
[img_fine, meta_fine] = microstructure.generate_synthetic( ...
    'Type', 'grains', 'NumGrains', 100, 'Size', [512 512]);
fprintf('Fine grain image: %dx%d, %d grains\n', ...
    meta_fine.size(1), meta_fine.size(2), meta_fine.num_grains);

% Generate a coarse-grained microstructure
[img_coarse, meta_coarse] = microstructure.generate_synthetic( ...
    'Type', 'grains', 'NumGrains', 20, 'Size', [512 512]);
fprintf('Coarse grain image: %dx%d, %d grains\n', ...
    meta_coarse.size(1), meta_coarse.size(2), meta_coarse.num_grains);

% Display side by side
figure('Name', 'Grain Structures', 'NumberTitle', 'off', ...
    'Position', [100 100 1000 450]);
subplot(1,2,1);
imagesc(img_fine); colormap(gray); axis image;
title(sprintf('Fine Grains (%d grains)', meta_fine.num_grains));
subplot(1,2,2);
imagesc(img_coarse); colormap(gray); axis image;
title(sprintf('Coarse Grains (%d grains)', meta_coarse.num_grains));

% QUESTION: If the image covers a 256 um x 256 um field of view
% at 512x512 pixels, what is the pixel size in micrometers?
% EXPECTED: 256/512 = 0.5 um/pixel

% QUESTION: Why do grain boundaries appear darker than grain interiors?

%% Part 2: Grain Size Measurement — Linear Intercept (~20 min)
% ASTM E112 defines grain size measurement methods.
% Linear Intercept (Heyn method):
%   1. Draw test lines across the image
%   2. Count grain boundary intersections
%   3. Mean intercept length = total line length / number of intercepts
%   4. ASTM grain size number: G = -6.644 * log10(l_mm) - 3.288

pixelSize = 0.5;  % um/pixel (calibration)

% Measure fine grains
gs_fine = microstructure.grainsize(img_fine, 'PixelSize', pixelSize, ...
    'NumLines', 30);
fprintf('\nFine Grain Analysis (Linear Intercept):\n');
fprintf('  Mean intercept: %.1f um\n', gs_fine.mean_intercept);
fprintf('  Std deviation:  %.1f um\n', gs_fine.std_intercept);
fprintf('  Grain count:    %d intercepts\n', gs_fine.grain_count);
fprintf('  ASTM G number:  %.1f\n', gs_fine.astm_grain_number);

% Measure coarse grains
gs_coarse = microstructure.grainsize(img_coarse, 'PixelSize', pixelSize, ...
    'NumLines', 30);
fprintf('\nCoarse Grain Analysis:\n');
fprintf('  Mean intercept: %.1f um\n', gs_coarse.mean_intercept);
fprintf('  ASTM G number:  %.1f\n', gs_coarse.astm_grain_number);

% Compare: higher G = finer grains
fprintf('\nComparison: Fine G=%.1f vs Coarse G=%.1f\n', ...
    gs_fine.astm_grain_number, gs_coarse.astm_grain_number);
fprintf('Higher G = finer grain structure\n');

% TODO: Manually count intercepts along one horizontal line.
% Pick the middle row of the fine-grain image:
%   [gx, gy] = gradient(double(img_fine));
%   edge_map = sqrt(gx.^2 + gy.^2);
%   edge_thresh = mean(edge_map(:)) + 2*std(edge_map(:));
%   boundaries = edge_map > edge_thresh;
%   middle_line = boundaries(256, :);
%   my_intercepts = sum(diff(middle_line) ~= 0);
%   my_intercept_length = (512 * pixelSize) / my_intercepts;
%   fprintf('Manual: %d intercepts, mean length = %.1f um\n', ...
%       my_intercepts, my_intercept_length);

% QUESTION: ASTM E112 requires at least 50 intercepts for a valid
% measurement. How many test lines do you need to achieve this?

%% Part 3: Circular Intercept Method (~15 min)
% The Abrams three-circle method is an alternative to linear intercept.
% Circles provide more isotropic sampling (no directional bias).
%
% Method: draw concentric circles, count boundary crossings,
% mean intercept = total circumference / total intersections

circ_fine = microstructure.circular_intercept(img_fine, ...
    'PixelSize', pixelSize, 'NumCircles', 3);
fprintf('\nCircular Intercept (Fine Grains):\n');
fprintf('  Mean intercept: %.1f um\n', circ_fine.mean_intercept);
fprintf('  ASTM G number:  %.1f\n', circ_fine.astm_grain_number);
fprintf('  Total intersections: %d\n', circ_fine.grain_count);

circ_coarse = microstructure.circular_intercept(img_coarse, ...
    'PixelSize', pixelSize, 'NumCircles', 3);
fprintf('\nCircular Intercept (Coarse Grains):\n');
fprintf('  Mean intercept: %.1f um\n', circ_coarse.mean_intercept);
fprintf('  ASTM G number:  %.1f\n', circ_coarse.astm_grain_number);

% Compare linear vs circular results
fprintf('\n--- Method Comparison ---\n');
fprintf('Fine grains:  Linear G=%.1f, Circular G=%.1f\n', ...
    gs_fine.astm_grain_number, circ_fine.astm_grain_number);
fprintf('Coarse grains: Linear G=%.1f, Circular G=%.1f\n', ...
    gs_coarse.astm_grain_number, circ_coarse.astm_grain_number);

% TODO: Vary the number of circles (1, 3, 5, 7) and plot
% how the ASTM G number converges:
%   numCirc = [1, 3, 5, 7];
%   G_vals = zeros(size(numCirc));
%   for i = 1:numel(numCirc)
%       r = microstructure.circular_intercept(img_fine, ...
%           'PixelSize', pixelSize, 'NumCircles', numCirc(i));
%       G_vals(i) = r.astm_grain_number;
%   end
%   figure; plot(numCirc, G_vals, 'bo-', 'LineWidth', 1.5);
%   xlabel('Number of Circles'); ylabel('ASTM G');

% QUESTION: Why might the circular method give different results
% than the linear method on an elongated (non-equiaxed) grain structure?

%% Part 4: Porosity and Phase Fraction Analysis (~20 min)
% Porous microstructures (cast metals, ceramics, sintered parts):

[img_porous, meta_p] = microstructure.generate_synthetic( ...
    'Type', 'porous', 'Porosity', 0.08, 'Size', [512 512]);
fprintf('\nPorous Microstructure: target porosity = %.0f%%\n', ...
    meta_p.target_porosity * 100);

por_results = microstructure.porosity(img_porous);
fprintf('Measured porosity: %.1f%%\n', por_results.porosity_percent);
fprintf('Number of pores: %d\n', por_results.num_pores);
microstructure.report(por_results, 'porosity', 'SampleName', 'Porous Sample');

% Dual-phase microstructure (e.g., ferrite + pearlite in steel):
[img_dp, meta_dp] = microstructure.generate_synthetic( ...
    'Type', 'dual_phase', 'NumGrains', 80, 'Size', [512 512]);

pf_results = microstructure.phase_fraction(img_dp, 'NumPhases', 2);
fprintf('\nDual-Phase Analysis:\n');
fprintf('  Phase 1 fraction: %.1f%%\n', pf_results.fractions(1) * 100);
fprintf('  Phase 2 fraction: %.1f%%\n', pf_results.fractions(2) * 100);

figure('Name', 'Porosity and Phase Fraction', 'NumberTitle', 'off', ...
    'Position', [100 100 1000 450]);
subplot(1,2,1);
imagesc(img_porous); colormap(gray); axis image;
title(sprintf('Porous (%.1f%% porosity)', por_results.porosity_percent));
subplot(1,2,2);
imagesc(img_dp); colormap(gray); axis image;
title(sprintf('Dual-Phase (%.0f%% / %.0f%%)', ...
    pf_results.fractions(1)*100, pf_results.fractions(2)*100));

% TODO: Generate porous images with different target porosities
% (2%, 5%, 10%, 15%) and plot measured vs target:
%   targets = [0.02, 0.05, 0.10, 0.15];
%   measured = zeros(size(targets));
%   for i = 1:numel(targets)
%       [im, ~] = microstructure.generate_synthetic('Type', 'porous', ...
%           'Porosity', targets(i));
%       r = microstructure.porosity(im);
%       measured(i) = r.porosity_percent / 100;
%   end
%   figure; plot(targets*100, measured*100, 'ro-', 'LineWidth', 1.5);
%   hold on; plot([0 20], [0 20], 'k--'); hold off;
%   xlabel('Target Porosity (%)'); ylabel('Measured Porosity (%)');
%   title('Porosity Measurement Accuracy');

% QUESTION: Why is area fraction equivalent to volume fraction
% for a random cross-section? (Hint: Delesse principle / stereology)

%% Part 5: ASTM E112 Compliance and Reporting (~20 min)
% ASTM E112 specifies requirements for valid grain size measurements.

% Check compliance for the fine-grain measurement
e112 = standards.astm_e112(gs_fine);
fprintf('\nASTM E112 Compliance (Fine Grains):\n');
fields = fieldnames(e112.checks);
for i = 1:numel(fields)
    check = e112.checks.(fields{i});
    if check.pass
        fprintf('  [PASS] %s\n', check.description);
    else
        fprintf('  [FAIL] %s\n', check.description);
    end
end

% Generate a formal report
microstructure.report(gs_fine, 'grainsize', ...
    'SampleName', 'Fine-Grained Steel');

% ASTM G-number reference table
fprintf('\nASTM E112 Reference Table:\n');
fprintf('  %-6s %-20s\n', 'G', 'Mean Intercept (um)');
fprintf('  %s\n', repmat('-', 1, 28));
for G = 1:10
    l_mm = 10^(-(G + 3.288) / 6.644);
    fprintf('  %-6d %-20.1f\n', G, l_mm * 1000);
end

% TODO: A customer specification requires ASTM G >= 7.
% Do both the fine and coarse samples meet this requirement?
% What heat treatment could be used to refine a coarse structure?

% QUESTION: Two labs measure the same sample: Lab A gets G=7.2,
% Lab B gets G=6.8. Is this acceptable reproducibility per ASTM E112?
% EXPECTED: ASTM E112 states reproducibility of +/- 0.5 G between labs.
% A difference of 0.4 is within acceptable range.

% Batch processing example
fprintf('\n=== Batch Processing ===\n');
images = cell(1, 3);
labels = {'Fine', 'Medium', 'Coarse'};
grainCounts = [100, 50, 20];
for i = 1:3
    [images{i}, ~] = microstructure.generate_synthetic( ...
        'Type', 'grains', 'NumGrains', grainCounts(i), 'Size', [256 256]);
end
batch = microstructure.batch_process(images, 'PixelSize', pixelSize);
fprintf('Batch results:\n');
for i = 1:numel(batch.results)
    fprintf('  %s: G = %.1f, mean intercept = %.1f um\n', ...
        labels{i}, batch.results(i).astm_grain_number, ...
        batch.results(i).mean_intercept);
end

%% Grading Rubric (Instructor Reference)
% Part 1: Image understanding (10 pts)
%   - Pixel size calculation correct (5 pts)
%   - Grain boundary etching mechanism understood (5 pts)
%
% Part 2: Linear intercept (25 pts)
%   - Manual intercept count within 20% of automated (10 pts)
%   - Understands minimum intercept requirement (5 pts)
%   - Correct G number interpretation (higher=finer) (10 pts)
%
% Part 3: Circular intercept (20 pts)
%   - Convergence plot completed (10 pts)
%   - Linear vs circular comparison discussed (5 pts)
%   - Isotropy advantage understood (5 pts)
%
% Part 4: Porosity and phase fraction (25 pts)
%   - Measured vs target porosity plot (10 pts)
%   - Phase fraction interpretation correct (10 pts)
%   - Stereology principle understood (5 pts)
%
% Part 5: Compliance and reporting (20 pts)
%   - ASTM G requirement analysis (10 pts)
%   - Reproducibility question correct (5 pts)
%   - Batch processing completed (5 pts)
