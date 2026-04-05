%% Material Selection and Design Lab
%  MatSciTools Educational Lab
%  -------------------------------------------------------
%  Prerequisites: Run setup() first
%  Time: ~90 minutes (full lab) or ~15-20 min per section
%  -------------------------------------------------------
%  This lab introduces systematic material selection using
%  Ashby charts, performance indices, multi-criteria ranking,
%  cost estimation, and design case studies with the MatSciTools
%  material selection toolkit.
%
%  Background reading:
%    Ashby, "Materials Selection in Mechanical Design", Ch. 4-6

%% Part 1: Ashby Charts (~15 min)
% Material property charts (Ashby charts) plot one property against
% another for a wide range of materials. They reveal the landscape
% of available materials and expose trade-offs.
%
% Key features:
%   - Log-log scales span the enormous range of material properties
%   - Materials cluster into families (metals, ceramics, polymers, composites)
%   - Gaps in the chart represent opportunities for new materials
%   - Guidelines of constant performance index appear as straight lines

% Generate a density vs Young's modulus chart
matsel.ashby('density', 'youngs_modulus');

% Generate a yield strength vs density chart
matsel.ashby('yield_strength', 'density');

% Examine a specific material to understand the data behind the charts
al = matdb.get('Al 6061-T6');
fprintf('Al 6061-T6: density = %.0f kg/m^3, E = %.0f GPa, YS = %.0f MPa\n', ...
    al.density, al.youngs_modulus, al.yield_strength);

% TODO: Create an Ashby chart of thermal_conductivity vs cost.
% Which material families dominate the upper-left (high conductivity,
% low cost)?
%
% matsel.ashby('cost', 'thermal_conductivity');

% QUESTION: Why are Ashby charts plotted on log-log scales?
% EXPECTED: Material properties span many orders of magnitude (e.g.,
% modulus from ~0.01 GPa for foams to >1000 GPa for diamond). Log-log
% scales allow all material classes to be visible on one chart. Also,
% performance index guidelines plot as straight lines on log-log axes.

%% Part 2: Material Filtering and Performance Indices (~20 min)
% Constraint-based selection eliminates materials that cannot meet
% hard requirements (e.g., density < 3000 kg/m^3, YS > 200 MPa).
%
% Performance indices rank the survivors by a figure of merit derived
% from the design objective:
%   E/rho      - lightweight stiffness (tie, tension)
%   sigma_y/rho - lightweight strength (tie, tension)
%   E^(1/2)/rho - lightweight stiff beam
%   E^(1/3)/rho - lightweight stiff panel

% Filter: lightweight strong materials (density < 3000, yield > 200 MPa)
T_filtered = matsel.filter('density', [0 3000], 'yield_strength', [200 Inf]);
fprintf('\nLightweight strong materials (%d found):\n', height(T_filtered));
disp(T_filtered);

% Rank by specific stiffness (E/rho)
T_stiffness = matsel.index('youngs_modulus', 'density', 'TopN', 10);
fprintf('\nTop 10 materials by specific stiffness (E/rho):\n');
disp(T_stiffness);

% Visualize the top performers on an Ashby chart with guidelines
matsel.ashby('density', 'youngs_modulus', 'Guidelines', true, 'GuideSlope', 1);

% TODO: Find the top 5 materials by specific strength (yield_strength/density).
% Use matsel.index() with 'TopN', 5.
%
% T_strength = matsel.index('yield_strength', 'density', 'TopN', 5);
% disp(T_strength);

% QUESTION: For a panel that must resist buckling, the relevant
% performance index is E^(1/3)/rho. Which material wins?
% Hint: Use the 'Power' parameter in matsel.index().
%
% T_panel = matsel.index('youngs_modulus', 'density', 'Power', [1/3, 1], 'TopN', 5);
% disp(T_panel);
%
% EXPECTED: CFRP composites and wood typically have the best E^(1/3)/rho
% because they combine moderate modulus with very low density. This is
% why aircraft panels use composites.

%% Part 3: Multi-Criteria Ranking (~20 min)
% Real design involves trade-offs: strength vs weight vs cost.
% Weighted scoring normalizes each property to [0,1], multiplies
% by a weight, and sums to produce a composite score.
%
% For 'max' goals: score = (val - min) / (max - min)
% For 'min' goals: score = (max - val) / (max - min)

% Define criteria: strong (0.5), light (0.3), cheap (0.2)
criteria(1).property = 'yield_strength'; criteria(1).weight = 0.5; criteria(1).goal = 'max';
criteria(2).property = 'density';        criteria(2).weight = 0.3; criteria(2).goal = 'min';
criteria(3).property = 'cost';           criteria(3).weight = 0.2; criteria(3).goal = 'min';

T_rank = matsel.rank(criteria, 'TopN', 10);
fprintf('\nMulti-criteria ranking (YS:0.5, density:0.3, cost:0.2):\n');
disp(T_rank);

% Compare: what if cost matters more?
criteria2(1).property = 'yield_strength'; criteria2(1).weight = 0.3; criteria2(1).goal = 'max';
criteria2(2).property = 'density';        criteria2(2).weight = 0.2; criteria2(2).goal = 'min';
criteria2(3).property = 'cost';           criteria2(3).weight = 0.5; criteria2(3).goal = 'min';

T_rank2 = matsel.rank(criteria2, 'TopN', 10);
fprintf('\nCost-driven ranking (YS:0.3, density:0.2, cost:0.5):\n');
disp(T_rank2);

% Show how rankings shift
fprintf('\nRanking comparison (top 5):\n');
fprintf('  %-5s %-25s %-25s\n', 'Rank', 'Strength-driven', 'Cost-driven');
for i = 1:min(5, height(T_rank))
    fprintf('  %-5d %-25s %-25s\n', i, ...
        T_rank.Name{i}, T_rank2.Name{i});
end

% TODO: Design criteria for a bicycle frame. It should be strong,
% light, and affordable. Choose weights that reflect these priorities,
% then rank materials. Justify your weight choices.
%
% bike(1).property = 'yield_strength'; bike(1).weight = ???; bike(1).goal = 'max';
% bike(2).property = 'density';        bike(2).weight = ???; bike(2).goal = 'min';
% bike(3).property = 'cost';           bike(3).weight = ???; bike(3).goal = 'min';
% T_bike = matsel.rank(bike, 'TopN', 10);
% disp(T_bike);

% QUESTION: How sensitive is the ranking to weight changes? Try swapping
% the weights for density and cost. Does the winner change?
% EXPECTED: Rankings can be quite sensitive. A material that ranks #1
% under one weighting may drop several places under another. This
% sensitivity analysis is a critical step in material selection.

%% Part 4: Cost Estimation and Unit Conversion (~15 min)
% Material cost is not just the raw price per kilogram. Total component
% cost includes:
%   Raw material cost  = density * volume * cost_per_kg
%   Manufacturing cost = raw_cost * manufacturing_factor
%   The manufacturing factor accounts for machining, forming, joining, etc.

% Estimate cost for an aluminum component (1 liter volume = 0.001 m^3)
cost_al = matsel.cost_estimate('component', 'Material', 'Al 6061-T6', 'Volume', 0.001);
fprintf('\nAl 6061-T6 component (1 L volume):\n');
fprintf('  Mass: %.2f kg\n', cost_al.mass_kg);
fprintf('  Raw cost: $%.2f\n', cost_al.raw_cost);
fprintf('  Total cost: $%.2f\n', cost_al.total_cost);

% Compare steel vs aluminum vs titanium for the same volume
materials = {'AISI 1045 Steel', 'Al 6061-T6', 'Ti-6Al-4V'};
fprintf('\nCost comparison for 1 L component:\n');
fprintf('  %-20s %-10s %-12s %-12s\n', 'Material', 'Mass(kg)', 'Raw($)', 'Total($)');
for i = 1:numel(materials)
    c = matsel.cost_estimate('component', 'Material', materials{i}, 'Volume', 0.001);
    fprintf('  %-20s %-10.2f %-12.2f %-12.2f\n', ...
        materials{i}, c.mass_kg, c.raw_cost, c.total_cost);
end

% Unit conversions for international collaboration
ys_ksi = matsel.convert_units(276, 'MPa', 'ksi');
fprintf('\n276 MPa = %.1f ksi\n', ys_ksi);

T_F = matsel.convert_units(660, 'C', 'F');
fprintf('660 C = %.0f F\n', T_F);

len_in = matsel.convert_units(25.4, 'mm', 'in');
fprintf('25.4 mm = %.3f in\n', len_in);

% TODO: Calculate cost per unit strength (cost_per_kg / yield_strength)
% for 3 materials of your choice. Which gives the best value?
%
% value_materials = {'AISI 1045 Steel', 'Al 6061-T6', 'Ti-6Al-4V'};
% fprintf('\nCost per unit strength:\n');
% for i = 1:numel(value_materials)
%     mat = matdb.get(value_materials{i});
%     cost_per_strength = mat.cost / mat.yield_strength;
%     fprintf('  %s: $%.4f per MPa\n', mat.name, cost_per_strength);
% end

% QUESTION: Why might a more expensive raw material be cheaper overall?
% EXPECTED: A lighter material (e.g., aluminum vs steel) uses less mass
% for the same volume, reducing raw cost. Higher-strength materials may
% allow thinner sections, reducing both material volume and weight.
% Manufacturing costs (e.g., machining titanium) can reverse this advantage.

%% Part 5: Design Case Study — Pressure Vessel (~20 min)
% Scenario: Select a material for a pressure vessel.
% Requirements:
%   - High yield strength (must contain internal pressure)
%   - Reasonable density (portable vessel)
%   - Good weldability (approximated here by thermal conductivity,
%     as high thermal conductivity aids weld quality in practice)
%
% Approach: filter -> rank -> cost estimate -> compare

% Step 1: Apply constraints
T_pv = matsel.filter('yield_strength', [300 Inf], 'density', [0 9000]);
fprintf('\nPressure vessel candidates (%d found):\n', height(T_pv));
disp(T_pv);

% Step 2: Rank by weighted criteria
pv_crit(1).property = 'yield_strength';       pv_crit(1).weight = 0.5; pv_crit(1).goal = 'max';
pv_crit(2).property = 'density';              pv_crit(2).weight = 0.2; pv_crit(2).goal = 'min';
pv_crit(3).property = 'thermal_conductivity'; pv_crit(3).weight = 0.15; pv_crit(3).goal = 'max';
pv_crit(4).property = 'cost';                 pv_crit(4).weight = 0.15; pv_crit(4).goal = 'min';

T_pv_ranked = matsel.rank(pv_crit, 'TopN', 10);
fprintf('\nPressure vessel ranking:\n');
disp(T_pv_ranked);

% Step 3: Cost estimate for the top candidate
top_mat = T_pv_ranked.Name{1};
pv_cost = matsel.cost_estimate('component', 'Material', top_mat, ...
    'Volume', 0.005, 'ManufacturingFactor', 2.0);
fprintf('\nTop candidate: %s\n', pv_cost.material_name);
fprintf('  Vessel volume: 5 L, mass: %.2f kg\n', pv_cost.mass_kg);
fprintf('  Manufacturing factor: %.1f (welding + forming)\n', pv_cost.manufacturing_factor);
fprintf('  Total estimated cost: $%.2f\n', pv_cost.total_cost);

% Step 4: Compare top 3 candidates side by side
top3 = T_pv_ranked.Name(1:min(3, height(T_pv_ranked)));
T_compare = matdb.compare(top3);
fprintf('\nTop 3 comparison:\n');
disp(T_compare);

% Visualize the candidates on an Ashby chart
figure('Name', 'Pressure Vessel Selection', 'NumberTitle', 'off', ...
    'Position', [100 100 900 600]);
matsel.ashby('density', 'yield_strength', 'Categories', {'Metal', 'Composite'});

% TODO: Repeat the analysis for a heat exchanger application:
%   - Maximize thermal conductivity (weight 0.5)
%   - Minimize cost (weight 0.3)
%   - Density < 5000 kg/m^3 (weight 0.2)
%
% Step 1: Filter
% T_hx = matsel.filter('density', [0 5000], 'thermal_conductivity', [50 Inf]);
% fprintf('\nHeat exchanger candidates (%d found):\n', height(T_hx));
% disp(T_hx);
%
% Step 2: Rank
% hx_crit(1).property = 'thermal_conductivity'; hx_crit(1).weight = 0.5; hx_crit(1).goal = 'max';
% hx_crit(2).property = 'cost';                 hx_crit(2).weight = 0.3; hx_crit(2).goal = 'min';
% hx_crit(3).property = 'density';              hx_crit(3).weight = 0.2; hx_crit(3).goal = 'min';
% T_hx_ranked = matsel.rank(hx_crit, 'TopN', 5);
% disp(T_hx_ranked);
%
% Step 3: Cost estimate for top candidate
% hx_cost = matsel.cost_estimate('component', 'Material', T_hx_ranked.Name{1}, ...
%     'Volume', 0.002, 'ManufacturingFactor', 1.5);
% fprintf('Heat exchanger cost: $%.2f\n', hx_cost.total_cost);

% QUESTION: How would you handle properties not in the database
% (e.g., fatigue life, corrosion resistance)?
% EXPECTED: Use the database for initial screening and ranking with
% available properties. Then consult specialized handbooks, standards
% (e.g., ASTM, ASME), or experimental data for fatigue and corrosion.
% These properties are often environment-specific and cannot be
% captured in a single number. Document assumptions and limitations.

%% Grading Rubric (Instructor Reference)
% Part 1: Ashby charts (15 pts)
%   - Thermal conductivity vs cost chart created (5 pts)
%   - Material families identified correctly (5 pts)
%   - Log-log scale justification explained (5 pts)
%
% Part 2: Filtering and performance indices (20 pts)
%   - Top 5 specific strength materials found (5 pts)
%   - E^(1/3)/rho index calculated correctly (5 pts)
%   - Winning material identified with reasoning (5 pts)
%   - Performance index concept understood (5 pts)
%
% Part 3: Multi-criteria ranking (25 pts)
%   - Bicycle frame criteria defined with justified weights (10 pts)
%   - Ranking completed and top material identified (5 pts)
%   - Sensitivity to weight changes discussed (5 pts)
%   - Trade-off between strength, weight, cost understood (5 pts)
%
% Part 4: Cost estimation and units (20 pts)
%   - Cost per unit strength calculated for 3 materials (10 pts)
%   - Unit conversions correct (5 pts)
%   - Raw vs total cost distinction understood (5 pts)
%
% Part 5: Design case study (20 pts)
%   - Heat exchanger analysis completed (10 pts)
%   - Top candidate justified with data (5 pts)
%   - Limitations of database approach discussed (5 pts)
