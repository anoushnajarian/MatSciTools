function results = run_all_tests()
%RUN_ALL_TESTS Run all MatSciTools unit tests
%   RESULTS = RUN_ALL_TESTS() runs the full test suite and returns results.
%
%   Example:
%     results = run_all_tests();

    % Add project root to path
    project_root = fileparts(fileparts(mfilename('fullpath')));
    addpath(project_root);

    fprintf('\n  MatSciTools Test Suite\n');
    fprintf('  =====================\n\n');

    import matlab.unittest.TestSuite;
    import matlab.unittest.TestRunner;

    suite = TestSuite.fromFolder(fileparts(mfilename('fullpath')));
    runner = TestRunner.withTextOutput;
    results = runner.run(suite);

    fprintf('\n  Summary:\n');
    fprintf('    Total:  %d\n', numel(results));
    fprintf('    Passed: %d\n', sum([results.Passed]));
    fprintf('    Failed: %d\n', sum([results.Failed]));
    fprintf('\n');
end
