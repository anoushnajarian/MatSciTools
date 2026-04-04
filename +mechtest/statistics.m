function stats = statistics(results_array, varargin)
%MECHTEST.STATISTICS Compute statistics across multiple specimen test results
%   STATS = MECHTEST.STATISTICS(RESULTS_ARRAY) computes mean, std, min, max,
%   and coefficient of variation for key mechanical properties across specimens.
%
%   RESULTS_ARRAY is a struct array where each element is the output of
%   MECHTEST.ANALYZE for one specimen.
%
%   Optional Parameters:
%     'Confidence' - Confidence level for interval (default: 0.95)
%
%   Returns a struct with fields for each property (youngs_modulus, yield_strength,
%   uts, elongation, toughness, resilience), each containing:
%     mean, std, min, max, cv (coefficient of variation), ci_low, ci_high, n
%
%   Example:
%     for i = 1:5
%         [s, st] = mechtest.generate_sample('steel');
%         results(i) = mechtest.analyze(s, st);
%     end
%     stats = mechtest.statistics(results);
%     fprintf('UTS: %.1f +/- %.1f MPa\n', stats.uts.mean, stats.uts.std);

    p = inputParser;
    addRequired(p, 'results_array', @isstruct);
    addParameter(p, 'Confidence', 0.95, @isnumeric);
    parse(p, results_array, varargin{:});
    conf = p.Results.Confidence;

    n = numel(results_array);
    if n < 2
        error('mechtest:InsufficientData', 'At least 2 specimens required for statistical analysis.');
    end

    props = {'youngs_modulus', 'yield_strength', 'uts', 'elongation', 'toughness', 'resilience'};

    stats = struct();

    for i = 1:numel(props)
        prop = props{i};
        vals = [results_array.(prop)];

        s = struct();
        s.n = n;
        s.mean = mean(vals);
        s.std = std(vals);
        s.min = min(vals);
        s.max = max(vals);

        if s.mean ~= 0
            s.cv = s.std / abs(s.mean) * 100; % percent
        else
            s.cv = 0;
        end

        % Confidence interval using t-distribution
        % t critical value approximation for common confidence levels
        alpha = 1 - conf;
        if n <= 30
            % Simple t-distribution approximation
            % For n-1 degrees of freedom
            nu = n - 1;
            % Use a lookup for common cases, otherwise approximate
            if abs(conf - 0.95) < 0.001
                t_vals = [12.706, 4.303, 3.182, 2.776, 2.571, 2.447, 2.365, 2.306, 2.262, 2.228, ...
                          2.201, 2.179, 2.160, 2.145, 2.131, 2.120, 2.110, 2.101, 2.093, 2.086, ...
                          2.080, 2.074, 2.069, 2.064, 2.060, 2.056, 2.052, 2.048, 2.045];
                t_crit = t_vals(min(nu, 29));
            elseif abs(conf - 0.99) < 0.001
                t_vals = [63.657, 9.925, 5.841, 4.604, 4.032, 3.707, 3.499, 3.355, 3.250, 3.169, ...
                          3.106, 3.055, 3.012, 2.977, 2.947, 2.921, 2.898, 2.878, 2.861, 2.845, ...
                          2.831, 2.819, 2.807, 2.797, 2.787, 2.779, 2.771, 2.763, 2.756];
                t_crit = t_vals(min(nu, 29));
            else
                % Approximate using normal distribution for other levels
                t_crit = -norminv_approx(alpha/2);
            end
        else
            t_crit = -norminv_approx(alpha/2);
        end

        margin = t_crit * s.std / sqrt(n);
        s.ci_low = s.mean - margin;
        s.ci_high = s.mean + margin;

        stats.(prop) = s;
    end
end

function z = norminv_approx(p)
%NORMINV_APPROX Approximate inverse normal CDF (Abramowitz & Stegun)
    t = sqrt(-2 * log(p));
    c0 = 2.515517; c1 = 0.802853; c2 = 0.010328;
    d1 = 1.432788; d2 = 0.189269; d3 = 0.001308;
    z = -(t - (c0 + c1*t + c2*t^2) / (1 + d1*t + d2*t^2 + d3*t^3));
end
