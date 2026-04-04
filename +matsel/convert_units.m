function result = convert_units(value, from_unit, to_unit, varargin)
%MATSEL.CONVERT_UNITS Convert between common MSE units
%   RESULT = MATSEL.CONVERT_UNITS(VALUE, FROM_UNIT, TO_UNIT) converts VALUE
%   from FROM_UNIT to TO_UNIT.
%
%   RESULT = MATSEL.CONVERT_UNITS(VALUE, FROM_UNIT, TO_UNIT, 'Type', TYPE)
%   specifies the quantity type explicitly when unit names are ambiguous.
%
%   Supported unit types and conversions:
%
%   Stress: Pa, kPa, MPa, GPa, psi, ksi
%     matsel.convert_units(200, 'MPa', 'ksi')         % => 29.01
%
%   Temperature: C, K, F
%     matsel.convert_units(1000, 'C', 'K')             % => 1273.15
%
%   Length: m, cm, mm, um, nm, in, ft, A (angstrom)
%     matsel.convert_units(10, 'mm', 'in')             % => 0.3937
%
%   Density: kg/m3, g/cm3, lb/in3, lb/ft3
%     matsel.convert_units(7850, 'kg/m3', 'g/cm3')     % => 7.85
%
%   Energy: J, kJ, MJ, cal, kcal, eV, BTU
%     matsel.convert_units(1, 'eV', 'J')               % => 1.602e-19
%
%   Angle: deg, rad
%     matsel.convert_units(90, 'deg', 'rad')           % => 1.5708
%
%   Example:
%     % Convert yield strength from MPa to ksi
%     ys_ksi = matsel.convert_units(276, 'MPa', 'ksi');
%
%     % Convert melting point from Celsius to Fahrenheit
%     T_F = matsel.convert_units(660, 'C', 'F');
%
%     % Convert density
%     rho = matsel.convert_units(2700, 'kg/m3', 'lb/ft3');

    p = inputParser;
    addRequired(p, 'value', @isnumeric);
    addRequired(p, 'from_unit', @(x) ischar(x)||isstring(x));
    addRequired(p, 'to_unit', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Type', '', @(x) ischar(x)||isstring(x));
    parse(p, value, from_unit, to_unit, varargin{:});

    from = char(from_unit);
    to = char(to_unit);
    qtype = char(p.Results.Type);

    % Auto-detect quantity type if not specified
    if isempty(qtype)
        qtype = detect_type(from, to);
    end

    switch lower(qtype)
        case 'stress'
            result = convert_stress(value, from, to);
        case 'temperature'
            result = convert_temperature(value, from, to);
        case 'length'
            result = convert_length(value, from, to);
        case 'density'
            result = convert_density(value, from, to);
        case 'energy'
            result = convert_energy(value, from, to);
        case 'angle'
            result = convert_angle(value, from, to);
        otherwise
            error('matsel:UnknownUnit', ...
                'Cannot determine quantity type for units "%s" and "%s". Use the ''Type'' parameter.', from, to);
    end
end

function qtype = detect_type(from, to)
%DETECT_TYPE Identify the quantity type from unit names
    stress_units = {'Pa', 'kPa', 'MPa', 'GPa', 'psi', 'ksi'};
    temp_units = {'C', 'K', 'F'};
    length_units = {'m', 'cm', 'mm', 'um', 'nm', 'in', 'ft', 'A'};
    density_units = {'kg/m3', 'g/cm3', 'lb/in3', 'lb/ft3'};
    energy_units = {'J', 'kJ', 'MJ', 'cal', 'kcal', 'eV', 'BTU'};
    angle_units = {'deg', 'rad'};

    if any(strcmp(from, stress_units)) && any(strcmp(to, stress_units))
        qtype = 'stress';
    elseif any(strcmp(from, temp_units)) && any(strcmp(to, temp_units))
        qtype = 'temperature';
    elseif any(strcmp(from, length_units)) && any(strcmp(to, length_units))
        qtype = 'length';
    elseif any(strcmp(from, density_units)) && any(strcmp(to, density_units))
        qtype = 'density';
    elseif any(strcmp(from, energy_units)) && any(strcmp(to, energy_units))
        qtype = 'energy';
    elseif any(strcmp(from, angle_units)) && any(strcmp(to, angle_units))
        qtype = 'angle';
    else
        qtype = '';
    end
end

function result = convert_stress(value, from, to)
    % Base unit: Pa
    toPa = struct('Pa',1, 'kPa',1e3, 'MPa',1e6, 'GPa',1e9, ...
                  'psi',6894.757, 'ksi',6894757);
    if ~isfield(toPa, from) || ~isfield(toPa, to)
        error('matsel:UnknownUnit', 'Unknown stress unit "%s" or "%s".', from, to);
    end
    result = value * toPa.(from) / toPa.(to);
end

function result = convert_temperature(value, from, to)
    % Convert through Kelvin
    switch from
        case 'C', kelvin = value + 273.15;
        case 'K', kelvin = value;
        case 'F', kelvin = (value - 32) * 5/9 + 273.15;
        otherwise, error('matsel:UnknownUnit', 'Unknown temperature unit "%s".', from);
    end
    switch to
        case 'C', result = kelvin - 273.15;
        case 'K', result = kelvin;
        case 'F', result = (kelvin - 273.15) * 9/5 + 32;
        otherwise, error('matsel:UnknownUnit', 'Unknown temperature unit "%s".', to);
    end
end

function result = convert_length(value, from, to)
    % Base unit: meters. 'A' = Angstrom (1e-10 m)
    toM = struct('m',1, 'cm',1e-2, 'mm',1e-3, 'um',1e-6, ...
                 'nm',1e-9, 'A',1e-10, 'in',0.0254, 'ft',0.3048);
    if ~isfield(toM, from) || ~isfield(toM, to)
        error('matsel:UnknownUnit', 'Unknown length unit "%s" or "%s".', from, to);
    end
    result = value * toM.(from) / toM.(to);
end

function result = convert_density(value, from, to)
    % Base unit: kg/m3
    from = strrep(from, '³', '3');
    to = strrep(to, '³', '3');
    unitNames = {'kg/m3', 'g/cm3', 'lb/in3', 'lb/ft3'};
    factors   = [1,       1000,    27679.9,  16.0185];
    fromFactor = NaN; toFactor = NaN;
    for i = 1:numel(unitNames)
        if strcmp(from, unitNames{i}), fromFactor = factors(i); end
        if strcmp(to, unitNames{i}), toFactor = factors(i); end
    end
    if isnan(fromFactor) || isnan(toFactor)
        error('matsel:UnknownUnit', 'Unknown density unit "%s" or "%s".', from, to);
    end
    result = value * fromFactor / toFactor;
end

function result = convert_energy(value, from, to)
    % Base unit: Joules
    toJ = struct('J',1, 'kJ',1e3, 'MJ',1e6, 'cal',4.184, ...
                 'kcal',4184, 'eV',1.602176634e-19, 'BTU',1055.06);
    if ~isfield(toJ, from) || ~isfield(toJ, to)
        error('matsel:UnknownUnit', 'Unknown energy unit "%s" or "%s".', from, to);
    end
    result = value * toJ.(from) / toJ.(to);
end

function result = convert_angle(value, from, to)
    switch from
        case 'deg', rad = value * pi / 180;
        case 'rad', rad = value;
        otherwise, error('matsel:UnknownUnit', 'Unknown angle unit "%s".', from);
    end
    switch to
        case 'deg', result = rad * 180 / pi;
        case 'rad', result = rad;
        otherwise, error('matsel:UnknownUnit', 'Unknown angle unit "%s".', to);
    end
end
