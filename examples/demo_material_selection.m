%% MatSciTools Demo: Material Selection
% This demo shows how to use the matsel module for Ashby-style material
% selection, performance index ranking, and multi-criteria optimization.

%% Setup
addpath(fileparts(fileparts(mfilename('fullpath'))));

%% 1. Ashby Chart: Density vs Young's Modulus
fprintf('=== Ashby Chart: Density vs Youngs Modulus ===\n');
matsel.ashby('density', 'youngs_modulus');

%% 2. Ashby Chart: Yield Strength vs Cost (metals only)
fprintf('\n=== Ashby Chart: Yield Strength vs Cost (Metals) ===\n');
matsel.ashby('cost', 'yield_strength', 'Categories', {'Metal'});

%% 3. Filter for lightweight strong materials
fprintf('\n=== Filtered Materials: density < 3000, yield > 200 MPa ===\n');
T = matsel.filter('density', [0 3000], 'yield_strength', [200 Inf]);
disp(T);

%% 4. Performance Index: Specific Stiffness (E/rho)
fprintf('\n=== Top 10 by Specific Stiffness (E/density) ===\n');
T = matsel.index('youngs_modulus', 'density', 'TopN', 10);
disp(T);

%% 5. Performance Index for lightweight stiff beams (E^1/2 / rho)
fprintf('\n=== Top 10 for Light Stiff Beams (E^0.5/density) ===\n');
T = matsel.index('youngs_modulus', 'density', 'Power', [0.5, 1], 'TopN', 10);
disp(T);

%% 6. Multi-criteria ranking
fprintf('\n=== Multi-Criteria Ranking ===\n');
fprintf('  Criteria: High strength (40%%), low density (30%%), low cost (30%%)\n\n');
criteria(1).property = 'yield_strength'; criteria(1).weight = 0.4; criteria(1).goal = 'max';
criteria(2).property = 'density';        criteria(2).weight = 0.3; criteria(2).goal = 'min';
criteria(3).property = 'cost';           criteria(3).weight = 0.3; criteria(3).goal = 'min';
T = matsel.rank(criteria, 'TopN', 10);
disp(T);

fprintf('Demo complete!\n');
