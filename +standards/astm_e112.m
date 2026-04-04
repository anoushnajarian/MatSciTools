function checks = astm_e112(grainsize_results, varargin)
%STANDARDS.ASTM_E112 Check compliance with ASTM E112 grain size standard
%   CHECKS = STANDARDS.ASTM_E112(GRAINSIZE_RESULTS) evaluates grain size
%   measurement data against ASTM E112 requirements.
%
%   GRAINSIZE_RESULTS is a struct from MICROSTRUCTURE.GRAINSIZE with fields:
%   mean_intercept, std_intercept, grain_count, astm_grain_number, num_lines,
%   pixel_size.
%
%   Optional Parameters:
%     'MinFields'           - Minimum fields of view (default: 1)
%     'ImageMagnification'  - Image magnification (default: 100)
%
%   Returns a struct with compliance check results. Each check is a struct
%   with .pass (logical) and .message (char). An OverallPass field (logical)
%   indicates whether all checks passed.
%
%   If called with no output arguments, prints a formatted compliance report.
%
%   Example:
%     [img, ~] = microstructure.generate_synthetic('Type', 'grains');
%     gs = microstructure.grainsize(img, 'PixelSize', 0.5, 'NumLines', 20);
%     checks = standards.astm_e112(gs);

    p = inputParser;
    addRequired(p, 'grainsize_results', @isstruct);
    addParameter(p, 'MinFields', 1, @isnumeric);
    addParameter(p, 'ImageMagnification', 100, @isnumeric);
    parse(p, grainsize_results, varargin{:});

    gs = grainsize_results;
    checks = struct();

    % 1. SufficientTestLines: num_lines >= 10
    checks.SufficientTestLines.pass = gs.num_lines >= 10;
    if checks.SufficientTestLines.pass
        checks.SufficientTestLines.message = sprintf('PASS: %d test lines (>= 10 recommended).', gs.num_lines);
    else
        checks.SufficientTestLines.message = sprintf('FAIL: %d test lines (< 10 recommended).', gs.num_lines);
    end

    % 2. SufficientIntercepts: grain_count >= 50
    checks.SufficientIntercepts.pass = gs.grain_count >= 50;
    if checks.SufficientIntercepts.pass
        checks.SufficientIntercepts.message = sprintf('PASS: %d intercepts (>= 50 minimum per E112).', gs.grain_count);
    else
        checks.SufficientIntercepts.message = sprintf('FAIL: %d intercepts (< 50 minimum per E112).', gs.grain_count);
    end

    % 3. ValidGrainNumber: astm_grain_number between -3 and 15
    G = gs.astm_grain_number;
    checks.ValidGrainNumber.pass = ~isnan(G) && G >= -3 && G <= 15;
    if checks.ValidGrainNumber.pass
        checks.ValidGrainNumber.message = sprintf('PASS: ASTM grain number G = %.1f (within [-3, 15]).', G);
    elseif isnan(G)
        checks.ValidGrainNumber.message = 'FAIL: ASTM grain number is NaN (could not be computed).';
    else
        checks.ValidGrainNumber.message = sprintf('FAIL: ASTM grain number G = %.1f (outside valid range [-3, 15]).', G);
    end

    % 4. ReasonableVariation: CV < 0.5
    if gs.mean_intercept > 0
        cv = gs.std_intercept / gs.mean_intercept;
    else
        cv = Inf;
    end
    checks.ReasonableVariation.pass = cv < 0.5;
    if checks.ReasonableVariation.pass
        checks.ReasonableVariation.message = sprintf('PASS: Coefficient of variation %.2f (< 0.50 threshold).', cv);
    else
        checks.ReasonableVariation.message = sprintf('FAIL: Coefficient of variation %.2f (>= 0.50, inconsistent microstructure).', cv);
    end

    % 5. PixelSizeSet: pixel_size > 0 and not default (1)
    ps = gs.pixel_size;
    explicitly_set = ps > 0 && ps ~= 1;
    checks.PixelSizeSet.pass = explicitly_set;
    if explicitly_set
        checks.PixelSizeSet.message = sprintf('PASS: Pixel size %.4f um (explicitly set).', ps);
    elseif ps == 1
        checks.PixelSizeSet.message = 'WARN: Pixel size is 1 um (default value; confirm calibration).';
    else
        checks.PixelSizeSet.message = sprintf('FAIL: Pixel size %.4f um is invalid (<= 0).', ps);
    end

    % 6. MeanInterceptPositive: mean_intercept > 0
    checks.MeanInterceptPositive.pass = ~isnan(gs.mean_intercept) && gs.mean_intercept > 0;
    if checks.MeanInterceptPositive.pass
        checks.MeanInterceptPositive.message = sprintf('PASS: Mean intercept %.2f um > 0.', gs.mean_intercept);
    else
        checks.MeanInterceptPositive.message = 'FAIL: Mean intercept is not positive (no valid measurements).';
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
    fprintf('  ASTM E112 Grain Size Compliance Report\n');
    fprintf('===================================================\n');
    fprintf('  Min Fields        : %d\n', opts.MinFields);
    fprintf('  Magnification     : %dx\n', opts.ImageMagnification);
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
            if strncmp(c.message, 'WARN', 4)
                status = 'WARN';
            else
                status = 'FAIL';
            end
        end
        % Strip prefix from message for display
        msg = c.message;
        colon_idx = strfind(msg, ': ');
        if ~isempty(colon_idx)
            msg = msg(colon_idx(1)+2:end);
        end
        fprintf('  [%s] %-25s %s\n', status, name, msg);
    end

    fprintf('---------------------------------------------------\n');
    if checks.OverallPass
        fprintf('  OVERALL: PASS (%d/%d checks passed)\n', n_pass, n_total);
    else
        fprintf('  OVERALL: FAIL (%d/%d checks passed)\n', n_pass, n_total);
    end
    fprintf('===================================================\n\n');
end
