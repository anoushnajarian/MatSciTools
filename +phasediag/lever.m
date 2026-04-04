function result = lever(system_name, T, x0, varargin)
%PHASEDIAG.LEVER Apply the lever rule to determine phase fractions
%   RESULT = PHASEDIAG.LEVER(SYSTEM, T, X0) calculates the fraction of each phase
%   at temperature T (K) and overall composition X0 (mole fraction of B).
%
%   Returns a struct with:
%     phase       - 'liquid', 'solid', or 'two-phase'
%     f_liquid    - Fraction of liquid phase
%     f_solid     - Fraction of solid phase
%     x_liquid    - Composition of liquid (mole fraction B)
%     x_solid     - Composition of solid (mole fraction B)
%     temperature - Temperature in K
%     composition - Overall composition
%
%   Example:
%     r = phasediag.lever('Cu-Ni', 1500, 0.4);
%     fprintf('Liquid fraction: %.1f%%\n', r.f_liquid*100);

    [T_grid, x_grid, phase_map] = phasediag.binary(system_name);

    % Find the temperature index
    [~, T_idx] = min(abs(T_grid - T));

    % Find the composition index
    [~, x_idx] = min(abs(x_grid - x0));

    phase_at_point = phase_map(T_idx, x_idx);

    result = struct();
    result.temperature = T;
    result.composition = x0;

    if phase_at_point == 1
        result.phase = 'liquid';
        result.f_liquid = 1;
        result.f_solid = 0;
        result.x_liquid = x0;
        result.x_solid = NaN;
    elseif phase_at_point == 2
        result.phase = 'solid';
        result.f_liquid = 0;
        result.f_solid = 1;
        result.x_liquid = NaN;
        result.x_solid = x0;
    else
        result.phase = 'two-phase';

        % Find liquidus and solidus compositions at this temperature
        row = phase_map(T_idx, :);

        % Liquidus: boundary between liquid and two-phase
        liq_indices = find(row == 1);
        twophase_indices = find(row == 3);

        if ~isempty(liq_indices) && ~isempty(twophase_indices)
            % Liquidus composition: rightmost liquid or leftmost liquid boundary
            if x0 < 0.5
                x_liq_idx = max(liq_indices(liq_indices < x_idx));
                if isempty(x_liq_idx)
                    x_liq_idx = min(liq_indices);
                end
            else
                x_liq_idx = min(liq_indices(liq_indices > x_idx));
                if isempty(x_liq_idx)
                    x_liq_idx = max(liq_indices);
                end
            end
            result.x_liquid = x_grid(x_liq_idx);
        else
            result.x_liquid = x0;
        end

        sol_indices = find(row == 2);
        if ~isempty(sol_indices)
            if x0 < 0.5
                x_sol_idx = min(sol_indices(sol_indices > x_idx));
                if isempty(x_sol_idx)
                    x_sol_idx = max(sol_indices);
                end
            else
                x_sol_idx = max(sol_indices(sol_indices < x_idx));
                if isempty(x_sol_idx)
                    x_sol_idx = min(sol_indices);
                end
            end
            result.x_solid = x_grid(x_sol_idx);
        else
            result.x_solid = x0;
        end

        % Lever rule: f_liquid = (x_solid - x0) / (x_solid - x_liquid)
        denom = result.x_solid - result.x_liquid;
        if abs(denom) > 1e-10
            result.f_liquid = (result.x_solid - x0) / denom;
            result.f_solid = (x0 - result.x_liquid) / denom;
        else
            result.f_liquid = 0.5;
            result.f_solid = 0.5;
        end

        result.f_liquid = max(0, min(1, result.f_liquid));
        result.f_solid = max(0, min(1, result.f_solid));
    end
end
