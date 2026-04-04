%% MatSciTools Demo: Phase Diagrams
% This demo shows how to use the phasediag module to compute and visualize
% binary phase diagrams and apply the lever rule.

%% Setup
addpath(fileparts(fileparts(mfilename('fullpath'))));

%% 1. List available systems
fprintf('=== Available Phase Diagram Systems ===\n');
info = phasediag.systems();
disp(info);

%% 2. Plot Cu-Ni isomorphous system
fprintf('\n=== Cu-Ni Phase Diagram ===\n');
phasediag.plot('Cu-Ni');

%% 3. Lever rule calculation
fprintf('\n=== Lever Rule: Cu-Ni at T=1500K, x_Ni=0.4 ===\n');
r = phasediag.lever('Cu-Ni', 1500, 0.4);
fprintf('  Phase state: %s\n', r.phase);
fprintf('  Liquid fraction: %.1f%%\n', r.f_liquid * 100);
fprintf('  Solid fraction:  %.1f%%\n', r.f_solid * 100);
if ~isnan(r.x_liquid)
    fprintf('  Liquid composition: x_Ni = %.3f\n', r.x_liquid);
end
if ~isnan(r.x_solid)
    fprintf('  Solid composition:  x_Ni = %.3f\n', r.x_solid);
end

%% 4. Plot with tie line and composition marker
phasediag.plot('Cu-Ni', 'ShowTieLine', 1500, 'Composition', 0.4);

%% 5. Plot other systems
fprintf('\n=== Pb-Sn Phase Diagram ===\n');
phasediag.plot('Pb-Sn');

fprintf('\n=== Fe-Ni Phase Diagram ===\n');
phasediag.plot('Fe-Ni');

%% 6. Another system: Al-Si
fprintf('\n=== Al-Si Phase Diagram ===\n');
phasediag.plot('Al-Si');

fprintf('\nDemo complete!\n');
