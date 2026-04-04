%% MatSciTools Demo: Material Database
% This demo shows how to use the matdb module to browse, search,
% and compare engineering materials.

%% Setup
% Add the project root to MATLAB path
addpath(fileparts(fileparts(mfilename('fullpath'))));

%% 1. List all materials
fprintf('=== All Materials ===\n');
all_materials = matdb.list();
disp(all_materials);

%% 2. Filter by category
fprintf('\n=== Metals Only ===\n');
metals = matdb.list('Metal');
disp(metals);

%% 3. Get a specific material
fprintf('\n=== AISI 1045 Steel Properties ===\n');
steel = matdb.get('AISI 1045 Steel');
disp(steel);

%% 4. Search by constraints
fprintf('\n=== Lightweight + Strong Materials (density < 3000, yield > 200 MPa) ===\n');
results = matdb.search('density', [0 3000], 'yield_strength', [200 Inf]);
for i = 1:numel(results)
    fprintf('  %-25s  rho=%.0f kg/m3  sy=%.0f MPa\n', ...
        results(i).name, results(i).density, results(i).yield_strength);
end

%% 5. Compare materials
fprintf('\n=== Material Comparison ===\n');
T = matdb.compare({'Al 6061-T6', 'Ti-6Al-4V', 'CFRP (Carbon/Epoxy)'});
disp(T);

%% 6. Check units
fprintf('\n=== Property Units ===\n');
u = matdb.units();
fields = fieldnames(u);
for i = 1:numel(fields)
    fprintf('  %-25s %s\n', fields{i}, u.(fields{i}));
end

fprintf('\nDemo complete!\n');
