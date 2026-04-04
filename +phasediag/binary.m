function [T_grid, x_grid, phase_map] = binary(system_name, varargin)
%PHASEDIAG.BINARY Compute a binary phase diagram
%   [T_GRID, X_GRID, PHASE_MAP] = PHASEDIAG.BINARY(SYSTEM) computes phase boundaries.
%   SYSTEM is a string: 'Cu-Ni', 'Pb-Sn', 'Al-Cu', 'Al-Si', or 'custom'.
%
%   For 'custom', provide thermodynamic parameters:
%     PHASEDIAG.BINARY('custom', 'Tm_A', 1085, 'Tm_B', 1455, ...
%       'Hf_A', 13000, 'Hf_B', 17470, 'Omega', 0)
%
%   Parameters:
%     'Tm_A'    - Melting point of component A (K)
%     'Tm_B'    - Melting point of component B (K)
%     'Hf_A'    - Enthalpy of fusion of A (J/mol)
%     'Hf_B'    - Enthalpy of fusion of B (J/mol)
%     'Omega'   - Regular solution interaction parameter (J/mol), 0 = ideal
%     'NumX'    - Number of composition points (default: 200)
%     'NumT'    - Number of temperature points (default: 200)
%
%   Returns:
%     T_GRID    - Temperature values (K)
%     X_GRID    - Composition values (mole fraction of B)
%     PHASE_MAP - Phase identity at each (T, x): 1=liquid, 2=solid, 3=two-phase
%
%   Example:
%     [T, x, ph] = phasediag.binary('Cu-Ni');

    p = inputParser;
    addRequired(p, 'system_name', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Tm_A', [], @isnumeric);
    addParameter(p, 'Tm_B', [], @isnumeric);
    addParameter(p, 'Hf_A', [], @isnumeric);
    addParameter(p, 'Hf_B', [], @isnumeric);
    addParameter(p, 'Omega', 0, @isnumeric);
    addParameter(p, 'NumX', 200, @isnumeric);
    addParameter(p, 'NumT', 200, @isnumeric);
    parse(p, system_name, varargin{:});
    opts = p.Results;

    R = 8.314; % J/(mol·K)

    % Load system parameters
    switch lower(system_name)
        case 'cu-ni'
            Tm_A = 1358; Tm_B = 1728; Hf_A = 13050; Hf_B = 17470; Omega = 0;
            comp_A = 'Cu'; comp_B = 'Ni';
        case 'pb-sn'
            Tm_A = 600.6; Tm_B = 505.1; Hf_A = 4770; Hf_B = 7030; Omega = 11000;
            comp_A = 'Pb'; comp_B = 'Sn';
        case 'al-si'
            Tm_A = 933.5; Tm_B = 1687; Hf_A = 10700; Hf_B = 50200; Omega = -2000;
            comp_A = 'Al'; comp_B = 'Si';
        case 'al-cu'
            Tm_A = 933.5; Tm_B = 1358; Hf_A = 10700; Hf_B = 13050; Omega = -20000;
            comp_A = 'Al'; comp_B = 'Cu';
        case 'fe-ni'
            Tm_A = 1811; Tm_B = 1728; Hf_A = 13800; Hf_B = 17470; Omega = -8000;
            comp_A = 'Fe'; comp_B = 'Ni';
        case 'custom'
            if isempty(opts.Tm_A) || isempty(opts.Tm_B) || isempty(opts.Hf_A) || isempty(opts.Hf_B)
                error('phasediag:MissingParams', ...
                    'Custom system requires Tm_A, Tm_B, Hf_A, Hf_B parameters.');
            end
            Tm_A = opts.Tm_A; Tm_B = opts.Tm_B;
            Hf_A = opts.Hf_A; Hf_B = opts.Hf_B; Omega = opts.Omega;
            comp_A = 'A'; comp_B = 'B';
        otherwise
            error('phasediag:UnknownSystem', ...
                'Unknown system: %s. Available: Cu-Ni, Pb-Sn, Al-Si, Al-Cu, Fe-Ni, custom', ...
                system_name);
    end

    % Composition grid
    x_grid = linspace(0, 1, opts.NumX);

    % Temperature range
    T_min = min(Tm_A, Tm_B) * 0.6;
    T_max = max(Tm_A, Tm_B) * 1.1;
    T_grid = linspace(T_min, T_max, opts.NumT);

    % Compute liquidus and solidus using ideal/regular solution model.
    % For a binary system A-B, at equilibrium the chemical potential of each
    % component must be equal in the liquid and solid phases. For an ideal or
    % regular solution this gives, for each temperature T:
    %
    %   x_B^L (liquidus composition) and x_B^S (solidus composition)
    %
    % From the equilibrium condition for component i:
    %   ln(x_i^S / x_i^L) = (Hf_i / R) * (1/Tm_i - 1/T)
    %
    % We sweep T and solve for liquidus (x_L) and solidus (x_S) compositions.

    T_liq_curve = zeros(size(x_grid));  % T at which composition x is on liquidus
    T_sol_curve = zeros(size(x_grid));  % T at which composition x is on solidus

    % Sweep temperature and compute liquidus/solidus compositions
    n_T_calc = 2000; % fine grid for accuracy
    T_calc = linspace(min(Tm_A, Tm_B) * 0.5, max(Tm_A, Tm_B), n_T_calc);
    x_liq = zeros(size(T_calc));
    x_sol = zeros(size(T_calc));

    for i = 1:n_T_calc
        T = T_calc(i);
        % Equilibrium ratios for each component
        % K_i = x_i^L / x_i^S = exp((Hf_i/R)*(1/Tm_i - 1/T))
        K_A = exp((Hf_A / R) * (1/Tm_A - 1/T));
        K_B = exp((Hf_B / R) * (1/Tm_B - 1/T));

        % From x_A^L = K_A * x_A^S and x_B^L = K_B * x_B^S
        % and x_A^S + x_B^S = 1, x_A^L + x_B^L = 1:
        %   K_A*(1 - x_B^S) + K_B*x_B^S = 1
        %   x_B^S = (1 - K_A) / (K_B - K_A)

        denom = K_B - K_A;
        if abs(denom) < 1e-12
            x_liq(i) = 0.5;
            x_sol(i) = 0.5;
        else
            xB_S = (1 - K_A) / denom;
            xB_L = K_B * xB_S;
            x_liq(i) = max(0, min(1, xB_L));
            x_sol(i) = max(0, min(1, xB_S));
        end
    end

    % Now interpolate: for each x in x_grid, find the T on the liquidus and solidus.
    % For a given overall composition xB:
    %   - LIQUIDUS T: the temperature where x_liq(T) == xB
    %     (above this T, the alloy is fully liquid)
    %   - SOLIDUS T: the temperature where x_sol(T) == xB
    %     (below this T, the alloy is fully solid)
    for j = 1:numel(x_grid)
        xB = x_grid(j);
        if xB < 1e-10
            T_liq_curve(j) = Tm_A;
            T_sol_curve(j) = Tm_A;
        elseif xB > 1-1e-10
            T_liq_curve(j) = Tm_B;
            T_sol_curve(j) = Tm_B;
        else
            % Liquidus T: find T where x_liq == xB
            idx_liq = find(diff(sign(x_liq - xB)) ~= 0);
            if ~isempty(idx_liq)
                ii = idx_liq(end);
                frac = (xB - x_liq(ii)) / (x_liq(ii+1) - x_liq(ii));
                T_liq_curve(j) = T_calc(ii) + frac * (T_calc(ii+1) - T_calc(ii));
            else
                [~, near] = min(abs(x_liq - xB));
                T_liq_curve(j) = T_calc(near);
            end

            % Solidus T: find T where x_sol == xB
            idx_sol = find(diff(sign(x_sol - xB)) ~= 0);
            if ~isempty(idx_sol)
                ii = idx_sol(end);
                frac = (xB - x_sol(ii)) / (x_sol(ii+1) - x_sol(ii));
                T_sol_curve(j) = T_calc(ii) + frac * (T_calc(ii+1) - T_calc(ii));
            else
                [~, near] = min(abs(x_sol - xB));
                T_sol_curve(j) = T_calc(near);
            end
        end
    end

    liquidus = T_liq_curve;
    solidus = T_sol_curve;

    % Ensure solidus <= liquidus
    solidus = min(solidus, liquidus);

    % Build phase map
    phase_map = zeros(opts.NumT, opts.NumX);
    for i = 1:opts.NumT
        for j = 1:opts.NumX
            T = T_grid(i);
            if T >= liquidus(j)
                phase_map(i,j) = 1; % Liquid
            elseif T <= solidus(j)
                phase_map(i,j) = 2; % Solid
            else
                phase_map(i,j) = 3; % Two-phase (L+S)
            end
        end
    end
end
