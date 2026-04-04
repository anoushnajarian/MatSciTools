classdef test_ml_advanced < matlab.unittest.TestCase
%TEST_ML_ADVANCED Unit tests for anomaly_detection, feature_importance, and cluster_materials

    methods (Test)

        %% ===== Anomaly Detection =====

        function testAnomalyDetectionBasic(testCase)
            result = intelligence.anomaly_detection();
            testCase.verifyClass(result, 'struct');
            testCase.verifyTrue(isfield(result, 'materials'));
            testCase.verifyTrue(isfield(result, 'distances'));
            testCase.verifyTrue(isfield(result, 'is_anomaly'));
            testCase.verifyTrue(isfield(result, 'threshold'));
            testCase.verifyTrue(isfield(result, 'anomalies'));
            testCase.verifyTrue(isfield(result, 'rankings'));
        end

        function testAnomalyDetectionSingleMaterial(testCase)
            result = intelligence.anomaly_detection('Material', 'PTFE');
            testCase.verifyClass(result, 'struct');
            testCase.verifyTrue(isfield(result, 'score'));
            testCase.verifyTrue(isfield(result, 'is_anomaly'));
        end

        function testAnomalyDetectionThreshold(testCase)
            result = intelligence.anomaly_detection('Threshold', 100);
            testCase.verifyEqual(result.n_anomalies, 0);
        end

        function testAnomalyDetectionCategoryFilter(testCase)
            result = intelligence.anomaly_detection('Categories', {'Metal'});
            testCase.verifyClass(result, 'struct');
            testCase.verifyTrue(isfield(result, 'rankings'));
        end

        %% ===== Feature Importance =====

        function testFeatureImportanceCorrelation(testCase)
            result = intelligence.feature_importance('yield_strength', 'Method', 'correlation');
            testCase.verifyClass(result, 'struct');
            testCase.verifyTrue(isfield(result, 'ranking'));
            testCase.verifyClass(result.ranking, 'table');
        end

        function testFeatureImportanceRegression(testCase)
            result = intelligence.feature_importance('yield_strength', 'Method', 'regression');
            testCase.verifyClass(result, 'struct');
            testCase.verifyTrue(isfield(result, 'baseline_rmse'));
            testCase.verifyGreaterThan(result.baseline_rmse, 0);
        end

        function testFeatureImportanceBoth(testCase)
            result = intelligence.feature_importance('yield_strength', 'Method', 'both');
            testCase.verifyTrue(isfield(result, 'ranking'));
            testCase.verifyTrue(ismember('CombinedScore', result.ranking.Properties.VariableNames));
        end

        function testFeatureImportanceCustomProps(testCase)
            props = {'density', 'youngs_modulus', 'elongation'};
            result = intelligence.feature_importance('yield_strength', ...
                'Properties', props, 'Method', 'correlation');
            testCase.verifyEqual(height(result.ranking), numel(props));
        end

        function testFeatureImportanceTargetExcluded(testCase)
            result = intelligence.feature_importance('yield_strength', 'Method', 'correlation');
            features = result.features;
            testCase.verifyFalse(any(strcmpi(features, 'yield_strength')));
        end

        %% ===== Cluster Materials =====

        function testClusterBasic(testCase)
            result = intelligence.cluster_materials('K', 4);
            testCase.verifyClass(result, 'struct');
            n = numel(result.labels);
            testCase.verifyEqual(n, numel(result.materials));
            testCase.verifyTrue(all(result.labels >= 1 & result.labels <= 4));
        end

        function testClusterSilhouette(testCase)
            result = intelligence.cluster_materials('K', 4);
            testCase.verifyGreaterThanOrEqual(result.silhouette, -1);
            testCase.verifyLessThanOrEqual(result.silhouette, 1);
        end

        function testClusterTable(testCase)
            result = intelligence.cluster_materials('K', 4);
            testCase.verifyClass(result.cluster_table, 'table');
            testCase.verifyTrue(ismember('Cluster', result.cluster_table.Properties.VariableNames));
            testCase.verifyTrue(ismember('Name', result.cluster_table.Properties.VariableNames));
        end

        function testClusterSummary(testCase)
            result = intelligence.cluster_materials('K', 4);
            testCase.verifyEqual(numel(result.cluster_summary), 4);
            for i = 1:4
                testCase.verifyTrue(isfield(result.cluster_summary{i}, 'size'));
            end
        end

        function testClusterCustomK(testCase)
            result = intelligence.cluster_materials('K', 3);
            testCase.verifyEqual(result.n_clusters, 3);
        end

        function testClusterProperties(testCase)
            result = intelligence.cluster_materials('K', 3, ...
                'Properties', {'density', 'youngs_modulus'});
            testCase.verifyClass(result, 'struct');
            testCase.verifyEqual(result.n_clusters, 3);
        end

    end
end
