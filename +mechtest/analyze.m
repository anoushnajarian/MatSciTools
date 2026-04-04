function results = analyze(strain, stress, varargin)
%MECHTEST.ANALYZE Analyze stress-strain curve data from a tensile test
%   RESULTS = MECHTEST.ANALYZE(STRAIN, STRESS) extracts key mechanical properties.
%   STRAIN and STRESS are numeric vectors (engineering strain in mm/mm, stress in MPa).
%
%   RESULTS = MECHTEST.ANALYZE(STRAIN, STRESS, 'OffsetStrain', val) sets the offset
%   for yield strength determination (default: 0.002 = 0.2%).
%
%   Returns a struct with:
%     youngs_modulus    - Elastic modulus (GPa), from linear region
%     yield_strength    - 0.2% offset yield strength (MPa)
%     uts               - Ultimate tensile strength (MPa)
%     elongation        - Elongation at break (%)
%     toughness         - Area under stress-strain curve (MJ/m^3)
%     resilience        - Area under elastic region (MJ/m^3)
%     strain_at_uts     - Strain at UTS
%     fracture_stress   - Stress at fracture (MPa)
%     n_points          - Number of data points
%
%   Example:
%     strain = linspace(0, 0.25, 500);
%     stress = my_test_data;
%     results = mechtest.analyze(strain, stress);

    p = inputParser;
    addRequired(p, 'strain', @isnumeric);
    addRequired(p, 'stress', @isnumeric);
    addParameter(p, 'OffsetStrain', 0.002, @isnumeric);
    parse(p, strain, stress, varargin{:});
    offset_strain = p.Results.OffsetStrain;

    strain = strain(:);
    stress = stress(:);

    if numel(strain) ~= numel(stress)
        error('mechtest:SizeMismatch', 'Strain and stress vectors must have the same length.');
    end

    results = struct();
    results.n_points = numel(strain);

    % 1. Elastic Modulus - use secant slopes to find the steepest (elastic) region
    % Compute point-to-point slopes and take the maximum as the elastic modulus,
    % which is robust even when only a few points fall in the elastic region.
    ds = diff(stress);
    de = diff(strain);
    slopes = ds ./ max(de, eps);

    % The elastic modulus is the maximum slope (steepest part of the curve)
    % Use the median of the top slopes to reduce noise sensitivity
    [sorted_slopes, ~] = sort(slopes, 'descend');
    n_top = max(1, min(5, round(0.1 * numel(sorted_slopes))));
    E_mpa = median(sorted_slopes(1:n_top));
    results.youngs_modulus = E_mpa / 1000; % Convert to GPa

    % 2. Yield Strength - 0.2% offset method
    offset_line = E_mpa * (strain - offset_strain);
    diff_curve = stress - offset_line;

    % Find where offset line intersects stress-strain curve
    sign_changes = diff(sign(diff_curve));
    cross_idx = find(sign_changes ~= 0 & strain(1:end-1) > offset_strain, 1, 'first');

    if ~isempty(cross_idx)
        % Linear interpolation for precise crossing
        frac = diff_curve(cross_idx) / (diff_curve(cross_idx) - diff_curve(cross_idx+1));
        results.yield_strength = stress(cross_idx) + frac * (stress(cross_idx+1) - stress(cross_idx));
    else
        % Fallback: use stress at offset_strain
        [~, near_idx] = min(abs(strain - offset_strain));
        results.yield_strength = stress(near_idx);
    end

    % 3. UTS
    [results.uts, uts_idx] = max(stress);
    results.strain_at_uts = strain(uts_idx);

    % 4. Elongation at break
    results.elongation = strain(end) * 100; % Convert to percentage

    % 5. Fracture stress
    results.fracture_stress = stress(end);

    % 6. Toughness - area under entire curve (trapezoidal integration)
    results.toughness = trapz(strain, stress); % MPa (= MJ/m^3)

    % 7. Resilience - area under elastic region
    yield_strain = results.yield_strength / E_mpa;
    elastic_idx = strain <= yield_strain;
    if sum(elastic_idx) >= 2
        results.resilience = trapz(strain(elastic_idx), stress(elastic_idx));
    else
        results.resilience = 0.5 * results.yield_strength * yield_strain;
    end
end
