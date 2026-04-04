function materials = list(category)
%MATDB.LIST List available materials in the database
%   MATERIALS = MATDB.LIST() returns a table of all materials.
%   MATERIALS = MATDB.LIST(CATEGORY) filters by category ('Metal', 'Ceramic', 'Polymer', 'Composite').
%
%   Example:
%     all = matdb.list();
%     metals = matdb.list('Metal');

    db = load_database();

    if nargin > 0 && ~isempty(category)
        validatestring(category, {'Metal', 'Ceramic', 'Polymer', 'Composite'});
        mask = strcmpi({db.category}, category);
        db = db(mask);
    end

    names = {db.name}';
    categories = {db.category}';
    subcategories = {db.subcategory}';
    densities = [db.density]';
    E = [db.youngs_modulus]';
    ys = [db.yield_strength]';
    uts_vals = [db.uts]';

    materials = table(names, categories, subcategories, densities, E, ys, uts_vals, ...
        'VariableNames', {'Name', 'Category', 'Subcategory', 'Density_kg_m3', ...
        'YoungsModulus_GPa', 'YieldStrength_MPa', 'UTS_MPa'});
end
