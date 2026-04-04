classdef test_matsel < matlab.unittest.TestCase
%TEST_MATSEL Unit tests for the material selection module

    methods (Test)
        function testFilterReturnsTable(testCase)
            T = matsel.filter('density', [0 3000]);
            testCase.verifyClass(T, 'table');
            testCase.verifyGreaterThan(height(T), 0);
        end

        function testFilterAppliesConstraints(testCase)
            T = matsel.filter('density', [0 3000], 'yield_strength', [200 Inf]);
            testCase.verifyTrue(all(T.Density <= 3000));
            testCase.verifyTrue(all(T.YieldStrength >= 200));
        end

        function testFilterNoResults(testCase)
            T = matsel.filter('density', [0 1]);
            testCase.verifyEqual(height(T), 0);
        end

        function testIndexReturnsTable(testCase)
            T = matsel.index('youngs_modulus', 'density');
            testCase.verifyClass(T, 'table');
            testCase.verifyGreaterThan(height(T), 0);
        end

        function testIndexSortedDescending(testCase)
            T = matsel.index('youngs_modulus', 'density');
            pi_vals = T.PerformanceIndex;
            testCase.verifyTrue(issorted(pi_vals, 'descend'));
        end

        function testIndexWithPower(testCase)
            T = matsel.index('youngs_modulus', 'density', 'Power', [0.5, 1]);
            testCase.verifyGreaterThan(height(T), 0);
        end

        function testIndexTopN(testCase)
            T = matsel.index('youngs_modulus', 'density', 'TopN', 5);
            testCase.verifyLessThanOrEqual(height(T), 5);
        end

        function testIndexCategoryFilter(testCase)
            T = matsel.index('youngs_modulus', 'density', 'Categories', {'Metal'});
            testCase.verifyTrue(all(strcmp(T.Category, 'Metal')));
        end

        function testRankReturnsTable(testCase)
            criteria(1).property = 'yield_strength';
            criteria(1).weight = 0.5;
            criteria(1).goal = 'max';
            criteria(2).property = 'density';
            criteria(2).weight = 0.5;
            criteria(2).goal = 'min';
            T = matsel.rank(criteria);
            testCase.verifyClass(T, 'table');
            testCase.verifyGreaterThan(height(T), 0);
        end

        function testRankSortedDescending(testCase)
            criteria(1).property = 'yield_strength';
            criteria(1).weight = 0.5;
            criteria(1).goal = 'max';
            criteria(2).property = 'cost';
            criteria(2).weight = 0.5;
            criteria(2).goal = 'min';
            T = matsel.rank(criteria);
            scores = T.Score;
            testCase.verifyTrue(issorted(scores, 'descend'));
        end

        function testRankInvalidWeights(testCase)
            criteria(1).property = 'yield_strength';
            criteria(1).weight = 0.3;
            criteria(1).goal = 'max';
            criteria(2).property = 'density';
            criteria(2).weight = 0.3;
            criteria(2).goal = 'min';
            testCase.verifyError(@() matsel.rank(criteria), 'matsel:InvalidWeights');
        end

        function testRankTopN(testCase)
            criteria(1).property = 'yield_strength';
            criteria(1).weight = 1.0;
            criteria(1).goal = 'max';
            T = matsel.rank(criteria, 'TopN', 5);
            testCase.verifyLessThanOrEqual(height(T), 5);
        end
    end
end
