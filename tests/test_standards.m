classdef test_standards < matlab.unittest.TestCase
%TEST_STANDARDS Unit tests for the standards compliance module

    methods (Test)

        %% ===== ASTM E8 =====

        function testASTME8Passes(testCase)
            % Use polymer (lower modulus = more elastic points in uniform sampling)
            [strain, stress] = mechtest.generate_sample('polymer', 'NumPoints', 500, 'Noise', 0);
            results = mechtest.analyze(strain, stress);
            checks = standards.astm_e8(strain, stress, results);
            testCase.verifyTrue(checks.SufficientDataPoints.pass);
            testCase.verifyTrue(checks.StrainRange.pass);
            testCase.verifyTrue(checks.UTSvsYS.pass);
            testCase.verifyTrue(checks.ReasonableModulus.pass);
            testCase.verifyTrue(checks.PositiveElongation.pass);
        end

        function testASTME8Fields(testCase)
            [strain, stress] = mechtest.generate_sample('steel', 'NumPoints', 500, 'Noise', 0);
            results = mechtest.analyze(strain, stress);
            checks = standards.astm_e8(strain, stress, results);
            testCase.verifyTrue(isfield(checks, 'SufficientDataPoints'));
            testCase.verifyTrue(isfield(checks, 'StrainRange'));
            testCase.verifyTrue(isfield(checks, 'ElasticRegion'));
            testCase.verifyTrue(isfield(checks, 'YieldLocation'));
            testCase.verifyTrue(isfield(checks, 'UTSvsYS'));
            testCase.verifyTrue(isfield(checks, 'ReasonableModulus'));
            testCase.verifyTrue(isfield(checks, 'PositiveElongation'));
            testCase.verifyTrue(isfield(checks, 'OverallPass'));
        end

        function testASTME8FailsLowPoints(testCase)
            [strain, stress] = mechtest.generate_sample('steel', 'NumPoints', 20, 'Noise', 0);
            results = mechtest.analyze(strain, stress);
            checks = standards.astm_e8(strain, stress, results);
            testCase.verifyFalse(checks.SufficientDataPoints.pass);
        end

        function testASTME8EachCheckHasPassAndMessage(testCase)
            [strain, stress] = mechtest.generate_sample('steel', 'NumPoints', 500, 'Noise', 0);
            results = mechtest.analyze(strain, stress);
            checks = standards.astm_e8(strain, stress, results);
            fieldNames = fieldnames(checks);
            for k = 1:numel(fieldNames)
                fn = fieldNames{k};
                if strcmp(fn, 'OverallPass')
                    continue;
                end
                testCase.verifyTrue(isfield(checks.(fn), 'pass'), ...
                    sprintf('Field %s missing .pass', fn));
                testCase.verifyTrue(isfield(checks.(fn), 'message'), ...
                    sprintf('Field %s missing .message', fn));
            end
        end

        %% ===== ASTM E112 =====

        function testASTME112Passes(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 40);
            gs = microstructure.grainsize(img, 'PixelSize', 0.5, 'NumLines', 20);
            checks = standards.astm_e112(gs);
            testCase.verifyTrue(checks.SufficientTestLines.pass);
            testCase.verifyTrue(checks.MeanInterceptPositive.pass);
        end

        function testASTME112Fields(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 40);
            gs = microstructure.grainsize(img, 'PixelSize', 0.5, 'NumLines', 20);
            checks = standards.astm_e112(gs);
            testCase.verifyTrue(isfield(checks, 'SufficientTestLines'));
            testCase.verifyTrue(isfield(checks, 'SufficientIntercepts'));
            testCase.verifyTrue(isfield(checks, 'ValidGrainNumber'));
            testCase.verifyTrue(isfield(checks, 'ReasonableVariation'));
            testCase.verifyTrue(isfield(checks, 'PixelSizeSet'));
            testCase.verifyTrue(isfield(checks, 'MeanInterceptPositive'));
            testCase.verifyTrue(isfield(checks, 'OverallPass'));
        end

        function testASTME112FailsLowLines(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 40);
            gs = microstructure.grainsize(img, 'PixelSize', 0.5, 'NumLines', 3);
            checks = standards.astm_e112(gs);
            testCase.verifyFalse(checks.SufficientTestLines.pass);
        end

    end
end
