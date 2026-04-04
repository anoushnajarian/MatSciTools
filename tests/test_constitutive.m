classdef test_constitutive < matlab.unittest.TestCase
%TEST_CONSTITUTIVE Unit tests for constitutive_models in the mechtest module

    properties
        SteelStrain
        SteelStress
        Results
    end

    methods (TestMethodSetup)
        function generateSampleData(testCase)
            [testCase.SteelStrain, testCase.SteelStress] = mechtest.generate_sample('steel', 'Noise', 0);
            testCase.Results = mechtest.constitutive_models(testCase.SteelStrain, testCase.SteelStress);
        end
    end

    methods (Test)

        function testReturnsStruct(testCase)
            testCase.verifyClass(testCase.Results, 'struct');
            testCase.verifyTrue(isfield(testCase.Results, 'hollomon'));
            testCase.verifyTrue(isfield(testCase.Results, 'ludwik'));
            testCase.verifyTrue(isfield(testCase.Results, 'voce'));
            testCase.verifyTrue(isfield(testCase.Results, 'swift'));
            testCase.verifyTrue(isfield(testCase.Results, 'true_strain'));
            testCase.verifyTrue(isfield(testCase.Results, 'true_stress'));
            testCase.verifyTrue(isfield(testCase.Results, 'plastic_idx'));
            testCase.verifyTrue(isfield(testCase.Results, 'best_model'));
        end

        function testHollomonParams(testCase)
            h = testCase.Results.hollomon;
            testCase.verifyGreaterThan(h.K, 0);
            testCase.verifyGreaterThan(h.n, 0);
            testCase.verifyLessThan(h.n, 1);
            testCase.verifyGreaterThan(h.R2, 0.8);
        end

        function testLudwikParams(testCase)
            l = testCase.Results.ludwik;
            testCase.verifyGreaterThan(l.sigma0, 0);
            testCase.verifyGreaterThan(l.K, 0);
            testCase.verifyGreaterThan(l.n, 0);
            testCase.verifyGreaterThan(l.R2, 0.8);
        end

        function testVoceParams(testCase)
            v = testCase.Results.voce;
            testCase.verifyGreaterThan(v.sigma_s, 0);
            testCase.verifyGreaterThan(v.sigma0, 0);
            testCase.verifyGreaterThan(v.theta, 0);
            testCase.verifyGreaterThan(v.R2, 0.8);
        end

        function testSwiftParams(testCase)
            s = testCase.Results.swift;
            testCase.verifyGreaterThan(s.K, 0);
            testCase.verifyGreaterThan(s.n, 0);
            testCase.verifyGreaterThan(s.R2, 0.8);
        end

        function testBestModel(testCase)
            validModels = {'hollomon', 'ludwik', 'voce', 'swift'};
            testCase.verifyTrue(ismember(testCase.Results.best_model, validModels));
        end

        function testPredictedLength(testCase)
            testCase.verifyEqual(numel(testCase.Results.hollomon.predicted), ...
                numel(testCase.Results.true_strain));
        end

        function testSelectiveModels(testCase)
            r = mechtest.constitutive_models(testCase.SteelStrain, testCase.SteelStress, ...
                'Models', {'hollomon', 'voce'});
            testCase.verifyTrue(isfield(r, 'hollomon'));
            testCase.verifyTrue(isfield(r, 'voce'));
            testCase.verifyFalse(isfield(r, 'ludwik'));
            testCase.verifyFalse(isfield(r, 'swift'));
        end

        function testAluminumFits(testCase)
            [s, st] = mechtest.generate_sample('aluminum', 'Noise', 0);
            r = mechtest.constitutive_models(s, st);
            testCase.verifyGreaterThan(r.hollomon.R2, 0.7);
            testCase.verifyGreaterThan(r.ludwik.R2, 0.7);
            testCase.verifyGreaterThan(r.voce.R2, 0.7);
            testCase.verifyGreaterThan(r.swift.R2, 0.7);
        end

    end
end
