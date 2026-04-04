function stats_report(stats, varargin)
%MECHTEST.STATS_REPORT Print a formatted statistical report
%   MECHTEST.STATS_REPORT(STATS) prints the statistical analysis to the command window.
%   STATS is the output from MECHTEST.STATISTICS.
%
%   Example:
%     stats = mechtest.statistics(results_array);
%     mechtest.stats_report(stats, 'TestName', 'Batch 2024-03');

    p = inputParser;
    addRequired(p, 'stats', @isstruct);
    addParameter(p, 'TestName', 'Multi-Specimen Analysis', @(x) ischar(x)||isstring(x));
    parse(p, stats, varargin{:});

    fprintf('\n');
    fprintf('  ================================================================\n');
    fprintf('  Statistical Analysis Report: %s\n', p.Results.TestName);
    fprintf('  ================================================================\n');
    fprintf('  Specimens: %d\n', stats.youngs_modulus.n);
    fprintf('  ----------------------------------------------------------------\n');
    fprintf('  %-22s %10s %10s %10s %8s\n', 'Property', 'Mean', 'Std Dev', '95% CI', 'CV(%)');
    fprintf('  ----------------------------------------------------------------\n');

    props = {'youngs_modulus', 'yield_strength', 'uts', 'elongation', 'toughness', 'resilience'};
    labels = {'Elastic Modulus (GPa)', 'Yield Strength (MPa)', 'UTS (MPa)', ...
              'Elongation (%)', 'Toughness (MJ/m^3)', 'Resilience (MJ/m^3)'};

    for i = 1:numel(props)
        s = stats.(props{i});
        ci_str = sprintf('[%.1f,%.1f]', s.ci_low, s.ci_high);
        fprintf('  %-22s %10.2f %10.2f %14s %7.1f\n', ...
                labels{i}, s.mean, s.std, ci_str, s.cv);
    end

    fprintf('  ================================================================\n\n');
end
