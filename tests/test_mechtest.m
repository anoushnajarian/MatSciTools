classdef test_mechtest < matlab.unittest.TestCase
%TEST_MECHTEST Unit tests for the mechanical testing module

    properties
        SteelStrain
        SteelStress
    end

    methods (TestMethodSetup)
        function generateSampleData(testCase)
            [testCase.SteelStrain, testCase.SteelStress] = mechtest.generate_sample('steel', 'Noise', 0);
        end
    end

    methods (Test)
        function testGenerateSampleSteel(testCase)
            [s, st] = mechtest.generate_sample('steel');
            testCase.verifyEqual(numel(s), 500);
            testCase.verifyEqual(numel(st), 500);
            testCase.verifyTrue(all(st >= 0));
        end

        function testGenerateSampleAluminum(testCase)
            [s, st] = mechtest.generate_sample('aluminum');
            testCase.verifyGreaterThan(numel(s), 0);
        end

        function testGenerateSamplePolymer(testCase)
            [s, st] = mechtest.generate_sample('polymer');
            testCase.verifyGreaterThan(numel(s), 0);
        end

        function testGenerateSampleCustomPoints(testCase)
            [s, ~] = mechtest.generate_sample('steel', 'NumPoints', 100);
            testCase.verifyEqual(numel(s), 100);
        end

        function testGenerateSampleInvalidType(testCase)
            testCase.verifyError(@() mechtest.generate_sample('unobtanium'), 'mechtest:UnknownType');
        end

        function testAnalyzeReturnsStruct(testCase)
            results = mechtest.analyze(testCase.SteelStrain, testCase.SteelStress);
            testCase.verifyClass(results, 'struct');
        end

        function testAnalyzeModulusReasonable(testCase)
            results = mechtest.analyze(testCase.SteelStrain, testCase.SteelStress);
            % Steel E should be near 200 GPa
            testCase.verifyGreaterThan(results.youngs_modulus, 150);
            testCase.verifyLessThan(results.youngs_modulus, 250);
        end

        function testAnalyzeYieldStrength(testCase)
            results = mechtest.analyze(testCase.SteelStrain, testCase.SteelStress);
            % Steel yield ~350 MPa
            testCase.verifyGreaterThan(results.yield_strength, 250);
            testCase.verifyLessThan(results.yield_strength, 500);
        end

        function testAnalyzeUTS(testCase)
            results = mechtest.analyze(testCase.SteelStrain, testCase.SteelStress);
            % Steel UTS ~500 MPa
            testCase.verifyGreaterThan(results.uts, 400);
            testCase.verifyLessThan(results.uts, 600);
            testCase.verifyGreaterThanOrEqual(results.uts, results.yield_strength);
        end

        function testAnalyzeElongation(testCase)
            results = mechtest.analyze(testCase.SteelStrain, testCase.SteelStress);
            testCase.verifyGreaterThan(results.elongation, 0);
        end

        function testAnalyzeToughness(testCase)
            results = mechtest.analyze(testCase.SteelStrain, testCase.SteelStress);
            testCase.verifyGreaterThan(results.toughness, 0);
        end

        function testAnalyzeResilience(testCase)
            results = mechtest.analyze(testCase.SteelStrain, testCase.SteelStress);
            testCase.verifyGreaterThan(results.resilience, 0);
            testCase.verifyLessThan(results.resilience, results.toughness);
        end

        function testAnalyzeSizeMismatch(testCase)
            testCase.verifyError(@() mechtest.analyze([1 2 3], [1 2]), 'mechtest:SizeMismatch');
        end

        function testAnalyzeAluminum(testCase)
            [s, st] = mechtest.generate_sample('aluminum', 'Noise', 0);
            results = mechtest.analyze(s, st);
            testCase.verifyGreaterThan(results.youngs_modulus, 50);
            testCase.verifyLessThan(results.youngs_modulus, 100);
        end

        function testReportRuns(testCase)
            results = mechtest.analyze(testCase.SteelStrain, testCase.SteelStress);
            mechtest.report(results, 'SampleName', 'Test Steel');
            % If we got here without error, the test passes
            testCase.verifyTrue(true);
        end

        function testNPointsField(testCase)
            results = mechtest.analyze(testCase.SteelStrain, testCase.SteelStress);
            testCase.verifyEqual(results.n_points, 500);
        end

        function testGenerateFromDatabase(testCase)
            [s, st] = mechtest.generate_sample('Ti-6Al-4V');
            testCase.verifyEqual(numel(s), 500);
            testCase.verifyTrue(all(st >= 0));
            results = mechtest.analyze(s, st);
            testCase.verifyGreaterThan(results.youngs_modulus, 50);
        end

        function testGenerateFromDatabaseAlAlloy(testCase)
            [s, st] = mechtest.generate_sample('Al 6061-T6');
            testCase.verifyEqual(numel(s), 500);
            results = mechtest.analyze(s, st);
            testCase.verifyGreaterThan(results.yield_strength, 100);
        end

        function testGenerateUnknownErrors(testCase)
            testCase.verifyError( ...
                @() mechtest.generate_sample('unobtanium_999'), ...
                'mechtest:UnknownType');
        end
    end
end
