classdef test_intelligence < matlab.unittest.TestCase
%TEST_INTELLIGENCE Unit tests for the intelligence module

    methods (Test)
        function testPredictByName(testCase)
            pred = intelligence.predict_properties('Al 6061-T6');
            testCase.verifyClass(pred, 'struct');
            testCase.verifyTrue(isfield(pred, 'density'));
            testCase.verifyTrue(isfield(pred, 'yield_strength'));
            testCase.verifyTrue(isfield(pred, 'nearest_materials'));
        end

        function testPredictByStruct(testCase)
            comp.density = 2700;
            comp.youngs_modulus = 69;
            pred = intelligence.predict_properties(comp);
            testCase.verifyGreaterThan(pred.density, 0);
        end

        function testPredictKNeighbors(testCase)
            pred = intelligence.predict_properties('AISI 1045 Steel', 'K', 5);
            testCase.verifyEqual(pred.k, 5);
            testCase.verifyEqual(numel(pred.nearest_materials), 5);
        end

        function testPredictHasConfidence(testCase)
            pred = intelligence.predict_properties('Ti-6Al-4V');
            testCase.verifyTrue(isfield(pred, 'density_confidence'));
        end

        function testRecommendReturnsTable(testCase)
            req.constraints.density = [0 5000];
            req.constraints.yield_strength = [200 Inf];
            req.objectives(1) = struct('property','yield_strength','goal','max','weight',0.6);
            req.objectives(2) = struct('property','cost','goal','min','weight',0.4);
            T = intelligence.recommend(req);
            testCase.verifyClass(T, 'table');
            testCase.verifyGreaterThan(height(T), 0);
        end

        function testRecommendTopN(testCase)
            req.constraints.density = [0 Inf];
            req.objectives(1) = struct('property','yield_strength','goal','max','weight',1.0);
            T = intelligence.recommend(req, 'TopN', 3);
            testCase.verifyLessThanOrEqual(height(T), 3);
        end

        function testRecommendNoMatch(testCase)
            req.constraints.density = [0 1]; % nothing this light
            req.objectives(1) = struct('property','yield_strength','goal','max','weight',1.0);
            T = intelligence.recommend(req);
            testCase.verifyEqual(height(T), 0);
        end

        function testSurrogateModelBasic(testCase)
            model = intelligence.surrogate_model({'density'}, 'youngs_modulus', 'Validate', false);
            testCase.verifyClass(model, 'struct');
            testCase.verifyTrue(isfield(model, 'r_squared'));
            testCase.verifyTrue(isfield(model, 'predict'));
        end

        function testSurrogateModelPredict(testCase)
            model = intelligence.surrogate_model({'density'}, 'youngs_modulus', 'Validate', false);
            y = model.predict(2700); % aluminum-like density
            testCase.verifyGreaterThan(y, 0);
            testCase.verifyTrue(isfinite(y));
        end

        function testSurrogateModelMultiInput(testCase)
            model = intelligence.surrogate_model({'density', 'youngs_modulus'}, 'yield_strength');
            testCase.verifyGreaterThan(model.n_samples, 10);
            y = model.predict([2700, 70]);
            testCase.verifyTrue(isfinite(y));
        end

        function testSurrogateModelCV(testCase)
            model = intelligence.surrogate_model({'density'}, 'yield_strength');
            testCase.verifyTrue(isfinite(model.cv_rmse));
            testCase.verifyGreaterThan(model.cv_rmse, 0);
        end

        function testSurrogateModelCategoryFilter(testCase)
            model = intelligence.surrogate_model({'density'}, 'youngs_modulus', ...
                'Categories', {'Metal'}, 'Validate', false);
            testCase.verifyGreaterThan(model.n_samples, 5);
        end

    end
end
