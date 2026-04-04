classdef test_materials_project < matlab.unittest.TestCase
%TEST_MATERIALS_PROJECT Unit tests for matdb.materials_project (demo mode only)

    methods (Test)
        function testDemoReturnsStruct(testCase)
            results = matdb.materials_project('demo');
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'count'));
            testCase.verifyTrue(isfield(results, 'data'));
            testCase.verifyTrue(isfield(results, 'table'));
        end

        function testDemoFormula(testCase)
            results = matdb.materials_project('demo', 'Formula', 'Al');
            testCase.verifyGreaterThan(results.count, 0);
            testCase.verifyTrue(ismember('material_id', results.table.Properties.VariableNames));
        end

        function testDemoElements(testCase)
            results = matdb.materials_project('demo', 'Elements', 'Fe,O');
            testCase.verifyGreaterThan(results.count, 0);
        end

        function testEmptyKeyErrors(testCase)
            testCase.verifyError(@() matdb.materials_project(''), 'matdb:NoAPIKey');
        end

        function testDemoDataHasProperties(testCase)
            results = matdb.materials_project('demo');
            testCase.verifyTrue(isfield(results.data, 'material_id'));
            testCase.verifyTrue(isfield(results.data, 'formula_pretty'));
            testCase.verifyTrue(isfield(results.data, 'density'));
        end
    end
end
