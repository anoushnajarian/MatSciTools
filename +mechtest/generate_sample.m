function [strain, stress] = generate_sample(material_type, varargin)
%MECHTEST.GENERATE_SAMPLE Generate synthetic stress-strain data for testing
%   [STRAIN, STRESS] = MECHTEST.GENERATE_SAMPLE(TYPE) generates data for demonstration.
%   TYPE can be a preset ('steel', 'aluminum', 'polymer', 'ceramic', 'rubber')
%   or any material name from the database (e.g., 'Ti-6Al-4V', 'Al 6061-T6').
%
%   Optional Parameters:
%     'NumPoints' - Number of data points (default: 500)
%     'Noise'     - Noise level as fraction of stress (default: 0.005)
%
%   Example:
%     [strain, stress] = mechtest.generate_sample('steel');
%     [strain, stress] = mechtest.generate_sample('Ti-6Al-4V');
%     results = mechtest.analyze(strain, stress);
%     mechtest.plot(strain, stress, results);

    p = inputParser;
    addRequired(p, 'material_type', @(x) ischar(x)||isstring(x));
    addParameter(p, 'NumPoints', 500, @isnumeric);
    addParameter(p, 'Noise', 0.005, @isnumeric);
    parse(p, material_type, varargin{:});

    n = p.Results.NumPoints;
    noise_level = p.Results.Noise;

    % Try preset types first, then fall back to database lookup
    switch lower(material_type)
        case 'steel'
            E = 200000;  % MPa
            sy = 350;    % MPa
            su = 500;    % MPa
            ef = 0.25;   % fracture strain
            eu = 0.15;   % strain at UTS
        case 'aluminum'
            E = 70000;
            sy = 275;
            su = 310;
            ef = 0.12;
            eu = 0.06;
        case 'polymer'
            E = 2500;
            sy = 50;
            su = 65;
            ef = 0.40;
            eu = 0.10;
        case 'ceramic'
            E = 300000;
            sy = 2000;
            su = 300;
            ef = 0.001;
            eu = 0.001;
        case 'rubber'
            E = 5;
            sy = 5;
            su = 20;
            ef = 5.0;
            eu = 4.0;
        otherwise
            % Look up from material database
            try
                mat = matdb.get(material_type);
            catch
                error('mechtest:UnknownType', ...
                    'Unknown material type: %s. Use a preset (steel, aluminum, polymer, ceramic, rubber) or a database material name.', ...
                    material_type);
            end
            E  = mat.youngs_modulus * 1000; % GPa -> MPa
            sy = mat.yield_strength;        % MPa
            su = mat.uts;                   % MPa
            ef = mat.elongation / 100;      % % -> fraction
            % Estimate strain at UTS as ~60% of fracture strain for ductile,
            % or ~90% for brittle materials
            if ef < 0.01
                eu = ef * 0.9;
            else
                eu = ef * 0.6;
            end
    end

    strain = linspace(0, ef, n)';
    ey = sy / E; % yield strain

    stress = zeros(n, 1);
    for i = 1:n
        e = strain(i);
        if e <= ey
            % Elastic region
            stress(i) = E * e;
        elseif e <= eu
            % Plastic hardening (power law)
            plastic_strain = e - ey;
            total_plastic = eu - ey;
            stress(i) = sy + (su - sy) * (plastic_strain / total_plastic)^0.5;
        else
            % Necking/softening
            past_uts = (e - eu) / (ef - eu);
            fracture_stress = su * 0.6;
            stress(i) = su - (su - fracture_stress) * past_uts^1.5;
        end
    end

    % Add noise
    if noise_level > 0
        rng(42); % reproducible
        stress = stress + noise_level * max(stress) * randn(n, 1);
        stress = max(stress, 0);
    end
end
