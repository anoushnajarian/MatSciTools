function u = units()
%MATDB.UNITS Return a struct describing the units of each material property
%   U = MATDB.UNITS() returns a struct mapping property names to unit strings.
%
%   Example:
%     u = matdb.units();
%     fprintf('Density unit: %s\n', u.density);

    u.density = 'kg/m^3';
    u.youngs_modulus = 'GPa';
    u.yield_strength = 'MPa';
    u.uts = 'MPa';
    u.elongation = '%';
    u.hardness = 'HV';
    u.thermal_conductivity = 'W/(m*K)';
    u.thermal_expansion = 'um/(m*K)';
    u.melting_point = 'deg C';
    u.poissons_ratio = '-';
    u.cost = '$/kg';
    u.specific_heat = 'J/(kg*K)';
end
