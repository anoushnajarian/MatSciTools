%% Phase Diagrams and the Lever Rule
%  MatSciTools Educational Lab
%  -------------------------------------------------------
%  Prerequisites: Run setup() first
%  Time: ~90 minutes (full lab) or ~15-20 min per section
%  -------------------------------------------------------
%  This lab introduces binary phase diagrams, the Gibbs
%  phase rule, the lever rule for phase fraction calculation,
%  eutectic reactions, and engineering applications of
%  phase equilibria using the MatSciTools phase diagram toolkit.
%
%  Background reading:
%    Callister & Rethwisch, "Materials Science and Engineering", Ch. 9-10
%    Porter & Easterling, "Phase Transformations in Metals and Alloys", Ch. 1

%% Part 1: Introduction to Phase Diagrams (~15 min)
% A phase diagram is a map that shows which phases are stable at a
% given temperature and composition under thermodynamic equilibrium.
%
% Key concepts:
%   Component - a chemically distinct species (e.g., Cu, Ni)
%   Phase     - a physically homogeneous portion (e.g., liquid, alpha-solid)
%   Gibbs Phase Rule:  F = C - P + 2
%     F = degrees of freedom, C = components, P = phases
%     At constant pressure (1 atm):  F = C - P + 1
%
% For a single-component system (C=1): one phase gives F=2 (T and P can
% vary independently); two phases gives F=1 (e.g., along a phase boundary).
%
% For a binary system (C=2): one phase gives F=3 (T, P, composition);
% at constant pressure, F=2 in single-phase regions and F=1 in two-phase.

% List all available phase diagram systems
sys = phasediag.systems();
disp('Available binary phase diagram systems:');
disp(sys);

% Plot the Cu-Ni isomorphous diagram
phasediag.plot('Cu-Ni');

% The Cu-Ni system shows complete solid solubility (isomorphous).
% Three regions are visible:
%   - Liquid (above the liquidus curve)
%   - Solid (below the solidus curve)
%   - Two-phase L+S (between liquidus and solidus)

% QUESTION: How many degrees of freedom exist in the two-phase
% region of a binary system at constant pressure?
% EXPECTED: F = C - P + 1 = 2 - 2 + 1 = 1 (one degree of freedom:
% if you fix T, the compositions of liquid and solid are determined;
% if you fix composition, T is determined)

%% Part 2: Isomorphous Systems — Cu-Ni (~20 min)
% In an isomorphous system, the two components are completely miscible
% in both liquid and solid states. This requires similar:
%   - Atomic radii (within ~15%)
%   - Crystal structures (both FCC for Cu and Ni)
%   - Electronegativities
%   - Valences
% (These are the Hume-Rothery rules for solid solubility.)
%
% The liquidus curve separates the liquid region from the two-phase
% region. The solidus curve separates the two-phase region from the
% solid region. During cooling, solidification begins at the liquidus
% and ends at the solidus.

% Get raw phase diagram data
[T_grid, x_grid, phase_map] = phasediag.binary('Cu-Ni');
fprintf('Cu-Ni diagram: %d temperature points, %d composition points\n', ...
    numel(T_grid), numel(x_grid));

% Plot with a tie line and composition marker
phasediag.plot('Cu-Ni', 'ShowTieLine', 1523, 'Composition', 0.4);

% Apply the lever rule at several temperatures during cooling
% for overall composition x0 = 0.4 (40 mol% Ni)
x0 = 0.4;
temps_K = [1600, 1523, 1450, 1400, 1300];

fprintf('\nCooling path for Cu-%.0f%%Ni (x0 = %.2f):\n', x0*100, x0);
fprintf('  %-8s %-12s %-10s %-10s %-10s %-10s\n', ...
    'T (K)', 'T (C)', 'Phase', 'f_liquid', 'x_liquid', 'x_solid');
fprintf('  %s\n', repmat('-', 1, 65));

for i = 1:numel(temps_K)
    r = phasediag.lever('Cu-Ni', temps_K(i), x0);
    fprintf('  %-8.0f %-12.0f %-10s %-10.3f %-10.3f %-10.3f\n', ...
        temps_K(i), temps_K(i)-273.15, r.phase, r.f_liquid, ...
        r.x_liquid, r.x_solid);
end

% TODO: Track liquid and solid compositions during cooling from
% 1600 K to 1200 K in steps of 50 K for x0 = 0.3 (30 mol% Ni).
% Plot f_liquid vs temperature.
%
% x0_todo = 0.3;
% T_range = 1600:-50:1200;
% f_liq = zeros(size(T_range));
% for i = 1:numel(T_range)
%     r = phasediag.lever('Cu-Ni', T_range(i), x0_todo);
%     f_liq(i) = r.f_liquid;
% end
% figure('Name', 'Solidification Path', 'NumberTitle', 'off', ...
%     'Position', [100 100 700 450]);
% plot(T_range - 273.15, f_liq * 100, 'bo-', 'LineWidth', 1.5);
% xlabel('Temperature (°C)'); ylabel('Liquid Fraction (%)');
% title(sprintf('Solidification of Cu-%.0f%%Ni', x0_todo*100));
% grid on;

% QUESTION: What is "coring" and why does it occur during
% non-equilibrium solidification?
% EXPECTED: During real (non-equilibrium) cooling, solid diffusion is
% too slow to maintain uniform composition. The first solid to form
% is Ni-rich; later solid is Ni-poor. The result is a compositional
% gradient from core to rim of each grain — this is "coring."

%% Part 3: Eutectic Systems — Pb-Sn (~20 min)
% In a eutectic system, the components have limited solid solubility.
% A eutectic reaction occurs at a specific temperature and composition:
%   Liquid -> alpha + beta (simultaneous solidification of two phases)
%
% The eutectic point is the lowest melting point in the system.
% At the eutectic composition, the alloy melts/freezes at a single
% temperature (zero degrees of freedom: F = 2 - 3 + 1 = 0).
%
% Hypoeutectic = composition left of eutectic (less B)
% Hypereutectic = composition right of eutectic (more B)

% Plot the Pb-Sn phase diagram
phasediag.plot('Pb-Sn');

% The Pb-Sn system is the classic solder alloy system.
% The eutectic point is near 183°C (456 K) at ~61.9 wt% Sn.

% Lever rule at the eutectic temperature for eutectic composition
T_eutectic_K = 456;  % ~183°C
x_eutectic = 0.619;  % approximate eutectic composition (mole fraction Sn)

r_eut = phasediag.lever('Pb-Sn', T_eutectic_K, x_eutectic);
fprintf('\nAt eutectic point (T=%.0f K = %.0f°C, x=%.3f):\n', ...
    T_eutectic_K, T_eutectic_K - 273.15, x_eutectic);
fprintf('  Phase: %s, f_liquid = %.3f\n', r_eut.phase, r_eut.f_liquid);

% Lever rule for a hypoeutectic composition (30% Sn)
x_hypo = 0.30;
T_test_K = 473;  % 200°C, in the two-phase region

r_hypo = phasediag.lever('Pb-Sn', T_test_K, x_hypo);
fprintf('\nHypoeutectic Pb-%.0f%%Sn at %.0f°C:\n', x_hypo*100, T_test_K-273.15);
fprintf('  Phase: %s\n', r_hypo.phase);
fprintf('  f_liquid = %.3f, f_solid = %.3f\n', r_hypo.f_liquid, r_hypo.f_solid);
fprintf('  x_liquid = %.3f, x_solid = %.3f\n', r_hypo.x_liquid, r_hypo.x_solid);

% Compare behavior at several temperatures for hypoeutectic alloy
fprintf('\nCooling Pb-%.0f%%Sn through two-phase region:\n', x_hypo*100);
T_scan = 550:-25:425;
fprintf('  %-8s %-10s %-10s %-10s\n', 'T (K)', 'Phase', 'f_liquid', 'f_solid');
fprintf('  %s\n', repmat('-', 1, 42));
for i = 1:numel(T_scan)
    r = phasediag.lever('Pb-Sn', T_scan(i), x_hypo);
    fprintf('  %-8.0f %-10s %-10.3f %-10.3f\n', ...
        T_scan(i), r.phase, r.f_liquid, r.f_solid);
end

% TODO: Find the eutectic temperature and composition by testing
% the lever rule at multiple points. The eutectic is where f_liquid
% drops from 1.0 to 0.0 at a single temperature for the eutectic
% composition. Try compositions from 0.5 to 0.7 in steps of 0.02,
% and for each, find the temperature where the alloy transitions
% from liquid to two-phase.
%
% x_test = 0.50:0.02:0.70;
% T_liquidus_est = zeros(size(x_test));
% for i = 1:numel(x_test)
%     for T = 500:-1:400
%         r = phasediag.lever('Pb-Sn', T, x_test(i));
%         if ~strcmp(r.phase, 'liquid')
%             T_liquidus_est(i) = T;
%             break;
%         end
%     end
% end
% [T_eut_est, idx] = min(T_liquidus_est);
% fprintf('Estimated eutectic: T = %.0f K (%.0f°C), x = %.2f\n', ...
%     T_eut_est, T_eut_est - 273.15, x_test(idx));

% QUESTION: Solder (Pb-Sn near eutectic) melts at a single temperature.
% Why is this useful for electronics manufacturing?
% EXPECTED: A eutectic alloy has a sharp melting point with no pasty
% (mushy) range. This means it solidifies instantly and cleanly,
% producing reliable solder joints without a weak, partially-solid state.

%% Part 4: Comparing Binary Systems (~20 min)
% Different binary systems exhibit different phase diagram types
% depending on the thermodynamic interactions between components.
%
% Isomorphous (complete solid solubility): Cu-Ni, Fe-Ni
%   - Similar atomic radii, crystal structure, electronegativity
%   - Smooth liquidus/solidus curves, no eutectic
%
% Eutectic (limited solid solubility): Pb-Sn, Al-Si, Al-Cu
%   - Significant size/structure mismatch
%   - Eutectic point where liquid -> two solid phases

% Plot all five systems side-by-side
all_systems = {'Cu-Ni', 'Pb-Sn', 'Al-Si', 'Al-Cu', 'Fe-Ni'};

figure('Name', 'Binary Systems Comparison', 'NumberTitle', 'off', ...
    'Position', [50 50 1200 800]);
for i = 1:numel(all_systems)
    [T_g, x_g, ph_map] = phasediag.binary(all_systems{i});

    % Find liquidus and solidus for plotting
    liquidus_T = zeros(size(x_g));
    solidus_T = zeros(size(x_g));
    for j = 1:numel(x_g)
        col = ph_map(:, j);
        liq_idx = find(col == 1, 1, 'last');
        if isempty(liq_idx); liquidus_T(j) = T_g(1); else; liquidus_T(j) = T_g(liq_idx); end
        sol_idx = find(col == 2, 1, 'last');
        if isempty(sol_idx); solidus_T(j) = T_g(1); else; solidus_T(j) = T_g(sol_idx); end
    end

    subplot(2, 3, i);
    plot(x_g * 100, liquidus_T - 273.15, 'r-', 'LineWidth', 1.5);
    hold on;
    plot(x_g * 100, solidus_T - 273.15, 'b-', 'LineWidth', 1.5);
    hold off;
    xlabel('Composition (mol% B)'); ylabel('T (°C)');
    title(all_systems{i}); grid on;
    xlim([0 100]);
end

% Print system info
sys_info = phasediag.systems();
disp(sys_info);

% TODO: For each system, determine if composition x = 0.3 at
% T = 0.7 * T_liquidus (of that composition) is liquid, solid,
% or two-phase. Use phasediag.lever() and report results.
%
% x_check = 0.3;
% for i = 1:numel(all_systems)
%     [T_g, x_g, ph_map] = phasediag.binary(all_systems{i});
%     % Find liquidus T at x = 0.3
%     [~, x_idx] = min(abs(x_g - x_check));
%     col = ph_map(:, x_idx);
%     liq_idx = find(col == 1, 1, 'last');
%     T_liq = T_g(liq_idx);
%     T_test = 0.7 * T_liq;
%     r = phasediag.lever(all_systems{i}, T_test, x_check);
%     fprintf('%s at x=%.1f, T=%.0f K (0.7*T_liq): %s\n', ...
%         all_systems{i}, x_check, T_test, r.phase);
% end

% QUESTION: Why do Cu-Ni and Fe-Ni form isomorphous systems while
% Pb-Sn does not?
% EXPECTED: Cu and Ni (and Fe and Ni) satisfy the Hume-Rothery rules
% for complete solid solubility: similar atomic radii (within 15%),
% same crystal structure (FCC), similar electronegativities, and
% similar valences. Pb and Sn differ in crystal structure (FCC vs
% tetragonal) and atomic radius, so solid solubility is limited.

%% Part 5: Engineering Applications (~15 min)
% Phase diagrams guide real engineering decisions. One important
% example is age-hardening (precipitation hardening) in Al-Cu alloys.
%
% The Al-Cu system shows limited solid solubility of Cu in Al.
% At high temperature (~540°C), Al can dissolve ~5.6 wt% Cu in the
% alpha phase. At room temperature, the solubility is < 0.5%.
%
% Age-hardening process:
%   1. Solution treatment: heat to ~540°C to dissolve Cu in alpha
%   2. Quench: rapidly cool to trap Cu in supersaturated solid solution
%   3. Age: hold at ~150-200°C to form fine precipitates (theta'/theta'')
%   The precipitates impede dislocation motion -> increased strength.

% Plot the Al-Cu diagram
phasediag.plot('Al-Cu');

% Lever rule at solution treatment temperature (~810 K = 537°C)
T_solution_K = 810;
x_Cu = 0.04;  % 4 mol% Cu
r_sol = phasediag.lever('Al-Cu', T_solution_K, x_Cu);
fprintf('\nSolution Treatment (Al-4%%Cu at %.0f°C):\n', T_solution_K - 273.15);
fprintf('  Phase: %s\n', r_sol.phase);
fprintf('  f_solid = %.3f\n', r_sol.f_solid);

% Lever rule at aging temperature (~450 K = 177°C)
T_aging_K = 450;
r_age = phasediag.lever('Al-Cu', T_aging_K, x_Cu);
fprintf('\nAging Temperature (Al-4%%Cu at %.0f°C):\n', T_aging_K - 273.15);
fprintf('  Phase: %s\n', r_age.phase);
fprintf('  f_solid = %.3f, f_liquid = %.3f\n', r_age.f_solid, r_age.f_liquid);

% At the solution temperature, all Cu is dissolved in alpha.
% At the aging temperature, the equilibrium state is alpha + theta,
% but the quench prevents this. During aging, fine precipitates
% nucleate and grow, strengthening the alloy.

% TODO: Use matdb.get() to compare properties of Al 2024-T3
% (an Al-Cu age-hardened alloy) with pure Al.
%
% al_pure = matdb.get('Al 1100');
% al_2024 = matdb.get('Al 2024-T3');
% fprintf('\nProperty Comparison:\n');
% fprintf('  %-20s %-15s %-15s\n', 'Property', 'Al 1100', 'Al 2024-T3');
% fprintf('  %-20s %-15.0f %-15.0f\n', 'UTS (MPa)', al_pure.uts, al_2024.uts);
% fprintf('  %-20s %-15.0f %-15.0f\n', 'Yield (MPa)', al_pure.yield_strength, al_2024.yield_strength);
% fprintf('  %-20s %-15.1f %-15.1f\n', 'Density (kg/m3)', al_pure.density, al_2024.density);
% fprintf('  %-20s %-15.0f %-15.0f\n', 'E (GPa)', al_pure.youngs_modulus, al_2024.youngs_modulus);

% QUESTION: Why must the alloy be quenched from the solution treatment
% temperature before aging? What happens if it is slowly cooled instead?
% EXPECTED: Quenching traps the Cu atoms in a supersaturated solid
% solution. If cooled slowly, Cu would diffuse and form coarse
% equilibrium theta precipitates at grain boundaries, which do not
% effectively strengthen the material. Fine, coherent precipitates
% (GP zones, theta'', theta') only form during controlled aging of
% the supersaturated solution.

%% Grading Rubric (Instructor Reference)
% Part 1: Introduction (15 pts)
%   - Gibbs phase rule stated and applied correctly (10 pts)
%   - Phase regions identified on Cu-Ni diagram (5 pts)
%
% Part 2: Isomorphous systems (20 pts)
%   - f_liquid vs T plot completed for x0=0.3 (10 pts)
%   - Coring mechanism explained correctly (5 pts)
%   - Tie line / lever rule applied at multiple T (5 pts)
%
% Part 3: Eutectic systems (25 pts)
%   - Eutectic T and composition estimated correctly (10 pts)
%   - Hypoeutectic cooling path analyzed (5 pts)
%   - Solder application question answered (5 pts)
%   - Clean labeled Pb-Sn diagram (5 pts)
%
% Part 4: System comparison (20 pts)
%   - All five systems plotted side-by-side (5 pts)
%   - Phase state at x=0.3, T=0.7*T_liq determined (10 pts)
%   - Hume-Rothery rules explanation correct (5 pts)
%
% Part 5: Engineering applications (20 pts)
%   - Lever rule at solution vs aging T correct (5 pts)
%   - matdb property comparison completed (5 pts)
%   - Quenching rationale explained (5 pts)
%   - Precipitate hardening mechanism understood (5 pts)
