classdef test_classify < matlab.unittest.TestCase
%TEST_CLASSIFY Unit tests for intelligence.classify_microstructure

    methods (Test)
        function testClassifyGrains(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains');
            result = intelligence.classify_microstructure(img);
            testCase.verifyEqual(result.prediction, 'grains');
        end

        function testClassifyPorous(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'porous', 'Porosity', 0.1);
            result = intelligence.classify_microstructure(img);
            testCase.verifyEqual(result.prediction, 'porous');
        end

        function testClassifyDualPhase(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'dual_phase');
            result = intelligence.classify_microstructure(img);
            testCase.verifyEqual(result.prediction, 'dual_phase');
        end

        function testReturnsStruct(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains');
            result = intelligence.classify_microstructure(img);
            testCase.verifyClass(result, 'struct');
            testCase.verifyTrue(isfield(result, 'prediction'));
            testCase.verifyTrue(isfield(result, 'confidence'));
            testCase.verifyTrue(isfield(result, 'scores'));
            testCase.verifyTrue(isfield(result, 'probabilities'));
            testCase.verifyTrue(isfield(result, 'features'));
        end

        function testConfidenceRange(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains');
            result = intelligence.classify_microstructure(img);
            testCase.verifyGreaterThanOrEqual(result.confidence, 0);
            testCase.verifyLessThanOrEqual(result.confidence, 1);
        end

        function testBatchClassification(testCase)
            [img1, ~] = microstructure.generate_synthetic('Type', 'grains');
            [img2, ~] = microstructure.generate_synthetic('Type', 'porous', 'Porosity', 0.1);
            [img3, ~] = microstructure.generate_synthetic('Type', 'dual_phase');
            results = intelligence.classify_microstructure({img1, img2, img3});
            testCase.verifyEqual(numel(results.predictions), 3);
            testCase.verifyEqual(numel(results.confidences), 3);
            testCase.verifyEqual(numel(results.individual), 3);
        end

        function testFeaturesExist(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains');
            result = intelligence.classify_microstructure(img);
            f = result.features;
            testCase.verifyTrue(isfield(f, 'mean_intensity'));
            testCase.verifyTrue(isfield(f, 'std_intensity'));
            testCase.verifyTrue(isfield(f, 'skewness'));
            testCase.verifyTrue(isfield(f, 'kurtosis'));
            testCase.verifyTrue(isfield(f, 'edge_density'));
            testCase.verifyTrue(isfield(f, 'dark_region_count'));
            testCase.verifyTrue(isfield(f, 'bimodality'));
            testCase.verifyTrue(isfield(f, 'contrast'));
        end
    end
end
