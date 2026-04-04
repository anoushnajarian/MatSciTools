function checks = astm_e8(strain, stress, results, varargin)
%STANDARDS.ASTM_E8 Check compliance with ASTM E8 tensile testing standard
%   CHECKS = STANDARDS.ASTM_E8(STRAIN, STRESS, RESULTS) evaluates tensile test
%   data against ASTM E8 requirements and best practices.
%
%   STRAIN is the engineering strain vector (mm/mm).
%   STRESS is the engineering stress vector (MPa).
%   RESULTS is a struct from MECHTEST.ANALYZE with fields: youngs_modulus,
%   yield_strength, uts, elongation, fracture_stress, toughness, resilience,
%   strain_at_uts, n_points.
%
%   Optional Parameters:
%     'GaugeLength'    - Gauge length in mm (default: 50)
%     'SpecimenType'   - 'flat' or 'round' (default: 'flat')
%
%   Returns a struct with compliance check results. Each check is a struct
%   with .pass (logical) and .message (char). An OverallPass field (logical)
%   indicates whether all checks passed.
%
%   If called with no output arguments, prints a formatted compliance report.
%
%   Example:
%     [strain, stress] = mechtest.generate_sample('steel');
%     results = mechtest.analyze(strain, stress);
%     checks = standards.astm_e8(strain, stress, results);

    p = inputParser;
    addRequired(p, 'strain', @isnumeric);
    addRequired(p, 'stress', @isnumeric);
    addRequired(p, 'results', @isstruct);
    addParameter(p, 'GaugeLength', 50, @isnumeric);
    addParameter(p, 'SpecimenType', 'flat', @(x) ismember(x, {'flat', 'round'}));
    parse(p, strain, stress, results, varargin{:});

    strain = strain(:);
    stress = stress(:);

    checks = struct();

    % 1. SufficientDataPoints: n_points >= 100
    n = results.n_points;
    checks.SufficientDataPoints.pass = n >= 100;
    if checks.SufficientDataPoints.pass
        checks.SufficientDataPoints.message = sprintf('PASS: %d data points (>= 100 recommended minimum).', n);
    else
        checks.SufficientDataPoints.message = sprintf('FAIL: %d data points (< 100 recommended minimum).', n);
    end

    % 2. StrainRange: max(strain) > 0.01
    max_strain = max(strain);
    checks.StrainRange.pass = max_strain > 0.01;
    if checks.StrainRange.pass
        checks.StrainRange.message = sprintf('PASS: Maximum strain %.4f (> 0.01 required).', max_strain);
    else
        checks.StrainRange.message = sprintf('FAIL: Maximum strain %.4f (<= 0.01, insufficient deformation).', max_strain);
    end

    % 3. ElasticRegion: at least 20 data points below 50% of yield strength
    elastic_threshold = 0.5 * results.yield_strength;
    n_elastic = sum(stress < elastic_threshold);
    checks.ElasticRegion.pass = n_elastic >= 20;
    if checks.ElasticRegion.pass
        checks.ElasticRegion.message = sprintf('PASS: %d points below 50%% yield (>= 20 required).', n_elastic);
    else
        checks.ElasticRegion.message = sprintf('FAIL: %d points below 50%% yield (< 20, inadequate for modulus).', n_elastic);
    end

    % 4. MonotonicLoading: first 80% of elastic points are monotonically non-decreasing
    elastic_idx = find(stress < results.yield_strength);
    if numel(elastic_idx) >= 2
        n_check = max(2, round(0.8 * numel(elastic_idx)));
        elastic_stress = stress(elastic_idx(1:n_check));
        diffs = diff(elastic_stress);
        n_decreasing = sum(diffs < 0);
        fraction_monotonic = 1 - n_decreasing / numel(diffs);
        checks.MonotonicLoading.pass = fraction_monotonic >= 0.8;
        if checks.MonotonicLoading.pass
            checks.MonotonicLoading.message = sprintf('PASS: %.1f%% of elastic region is monotonically non-decreasing.', fraction_monotonic * 100);
        else
            checks.MonotonicLoading.message = sprintf('FAIL: Only %.1f%% of elastic region is monotonic (< 80%%).', fraction_monotonic * 100);
        end
    else
        checks.MonotonicLoading.pass = false;
        checks.MonotonicLoading.message = 'FAIL: Insufficient elastic region data for monotonicity check.';
    end

    % 5. YieldLocation: yield occurs after at least 5 data points and before last 5
    yield_idx = find(stress >= results.yield_strength, 1, 'first');
    if isempty(yield_idx)
        yield_idx = numel(stress);
    end
    checks.YieldLocation.pass = yield_idx > 5 && yield_idx <= (numel(stress) - 5);
    if checks.YieldLocation.pass
        checks.YieldLocation.message = sprintf('PASS: Yield at index %d (not at extremes of %d points).', yield_idx, numel(stress));
    else
        checks.YieldLocation.message = sprintf('FAIL: Yield at index %d of %d points (too close to data boundary).', yield_idx, numel(stress));
    end

    % 6. UTSvsYS: UTS >= yield_strength
    checks.UTSvsYS.pass = results.uts >= results.yield_strength;
    if checks.UTSvsYS.pass
        checks.UTSvsYS.message = sprintf('PASS: UTS (%.1f MPa) >= yield strength (%.1f MPa).', results.uts, results.yield_strength);
    else
        checks.UTSvsYS.message = sprintf('FAIL: UTS (%.1f MPa) < yield strength (%.1f MPa).', results.uts, results.yield_strength);
    end

    % 7. ReasonableModulus: youngs_modulus between 0.001 and 1000 GPa
    E = results.youngs_modulus;
    checks.ReasonableModulus.pass = E >= 0.001 && E <= 1000;
    if checks.ReasonableModulus.pass
        checks.ReasonableModulus.message = sprintf('PASS: Modulus %.2f GPa is within reasonable range [0.001, 1000].', E);
    else
        checks.ReasonableModulus.message = sprintf('FAIL: Modulus %.2f GPa is outside reasonable range [0.001, 1000].', E);
    end

    % 8. PositiveElongation: elongation > 0
    checks.PositiveElongation.pass = results.elongation > 0;
    if checks.PositiveElongation.pass
        checks.PositiveElongation.message = sprintf('PASS: Elongation %.2f%% > 0.', results.elongation);
    else
        checks.PositiveElongation.message = sprintf('FAIL: Elongation %.2f%% <= 0.', results.elongation);
    end

    % OverallPass
    check_names = fieldnames(checks);
    all_pass = true;
    for i = 1:numel(check_names)
        all_pass = all_pass && checks.(check_names{i}).pass;
    end
    checks.OverallPass = all_pass;

    % Print formatted report if no output arguments
    if nargout == 0
        print_report(checks, p.Results);
        clear checks;
    end
end

function print_report(checks, opts)
    fprintf('\n');
    fprintf('===================================================\n');
    fprintf('  ASTM E8 Tensile Testing Compliance Report\n');
    fprintf('===================================================\n');
    fprintf('  Specimen Type : %s\n', opts.SpecimenType);
    fprintf('  Gauge Length  : %.1f mm\n', opts.GaugeLength);
    fprintf('---------------------------------------------------\n');

    check_names = fieldnames(checks);
    n_pass = 0;
    n_total = 0;
    for i = 1:numel(check_names)
        name = check_names{i};
        if strcmp(name, 'OverallPass')
            continue;
        end
        n_total = n_total + 1;
        c = checks.(name);
        if c.pass
            status = 'PASS';
            n_pass = n_pass + 1;
        else
            status = 'FAIL';
        end
        fprintf('  [%s] %-25s %s\n', status, name, c.message(7:end));
    end

    fprintf('---------------------------------------------------\n');
    if checks.OverallPass
        fprintf('  OVERALL: PASS (%d/%d checks passed)\n', n_pass, n_total);
    else
        fprintf('  OVERALL: FAIL (%d/%d checks passed)\n', n_pass, n_total);
    end
    fprintf('===================================================\n\n');
end
