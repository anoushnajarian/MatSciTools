function report(results, varargin)
%MECHTEST.REPORT Print a formatted report of mechanical test results
%   MECHTEST.REPORT(RESULTS) prints results to the command window.
%   RESULTS is the output from MECHTEST.ANALYZE.
%
%   MECHTEST.REPORT(RESULTS, 'SampleName', 'My Sample') adds a sample name.
%
%   Example:
%     results = mechtest.analyze(strain, stress);
%     mechtest.report(results, 'SampleName', 'AISI 1045 Specimen 1');

    p = inputParser;
    addRequired(p, 'results', @isstruct);
    addParameter(p, 'SampleName', 'Unknown', @(x) ischar(x)||isstring(x));
    parse(p, results, varargin{:});

    fprintf('\n');
    fprintf('  ============================================\n');
    fprintf('  Mechanical Test Report\n');
    fprintf('  ============================================\n');
    fprintf('  Sample: %s\n', p.Results.SampleName);
    fprintf('  Data Points: %d\n', results.n_points);
    fprintf('  --------------------------------------------\n');
    fprintf('  Elastic Modulus:      %8.1f GPa\n', results.youngs_modulus);
    fprintf('  Yield Strength:       %8.1f MPa\n', results.yield_strength);
    fprintf('  Ultimate Strength:    %8.1f MPa\n', results.uts);
    fprintf('  Elongation at Break:  %8.1f %%\n', results.elongation);
    fprintf('  Fracture Stress:      %8.1f MPa\n', results.fracture_stress);
    fprintf('  Toughness:            %8.2f MJ/m^3\n', results.toughness);
    fprintf('  Resilience:           %8.4f MJ/m^3\n', results.resilience);
    fprintf('  Strain at UTS:        %8.4f mm/mm\n', results.strain_at_uts);
    fprintf('  ============================================\n\n');
end
