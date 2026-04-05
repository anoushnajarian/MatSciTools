classdef test_microstructure < matlab.unittest.TestCase
%TEST_MICROSTRUCTURE Unit tests for the microstructure analysis module

    methods (Test)
        function testGenerateSyntheticGrains(testCase)
            [img, meta] = microstructure.generate_synthetic('Type', 'grains');
            testCase.verifySize(img, [256, 256]);
            testCase.verifyEqual(meta.type, 'grains');
            testCase.verifyEqual(meta.num_grains, 30);
        end

        function testGenerateSyntheticPorous(testCase)
            [img, meta] = microstructure.generate_synthetic('Type', 'porous');
            testCase.verifySize(img, [256, 256]);
            testCase.verifyEqual(meta.type, 'porous');
            testCase.verifyGreaterThan(meta.num_pores, 0);
        end

        function testPorousNumGrainsControlsPores(testCase)
            [~, meta10] = microstructure.generate_synthetic('Type', 'porous', 'NumGrains', 10);
            [~, meta50] = microstructure.generate_synthetic('Type', 'porous', 'NumGrains', 50);
            testCase.verifyEqual(meta10.num_pores, 10);
            testCase.verifyEqual(meta50.num_pores, 50);
        end

        function testPorousVariesBetweenCalls(testCase)
            [img1, ~] = microstructure.generate_synthetic('Type', 'porous', 'NumGrains', 20);
            [img2, ~] = microstructure.generate_synthetic('Type', 'porous', 'NumGrains', 20);
            testCase.verifyFalse(isequal(img1, img2));
        end

        function testGrainsVariesBetweenCalls(testCase)
            [img1, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 20);
            [img2, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 20);
            testCase.verifyFalse(isequal(img1, img2));
        end

        function testGenerateSyntheticDualPhase(testCase)
            [img, meta] = microstructure.generate_synthetic('Type', 'dual_phase');
            testCase.verifySize(img, [256, 256]);
            testCase.verifyEqual(numel(meta.phase_fraction), 2);
        end

        function testGenerateSyntheticCustomSize(testCase)
            [img, ~] = microstructure.generate_synthetic('Size', [128, 128]);
            testCase.verifySize(img, [128, 128]);
        end

        function testGenerateSyntheticInvalidType(testCase)
            testCase.verifyError(@() microstructure.generate_synthetic('Type', 'unobtanium'), ...
                'microstructure:UnknownType');
        end

        function testGrainsizeReturnsStruct(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 20);
            results = microstructure.grainsize(img);
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'mean_intercept'));
            testCase.verifyTrue(isfield(results, 'astm_grain_number'));
        end

        function testGrainsizePositiveValues(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains');
            results = microstructure.grainsize(img, 'PixelSize', 0.5);
            if results.grain_count > 0
                testCase.verifyGreaterThan(results.mean_intercept, 0);
                testCase.verifyTrue(isfinite(results.astm_grain_number));
            end
        end

        function testGrainsizePixelSize(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains');
            r1 = microstructure.grainsize(img, 'PixelSize', 1);
            r2 = microstructure.grainsize(img, 'PixelSize', 2);
            if r1.grain_count > 0 && r2.grain_count > 0
                testCase.verifyGreaterThan(r2.mean_intercept, r1.mean_intercept * 1.5);
            end
        end

        function testPorosityReturnsStruct(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'porous', 'Porosity', 0.1);
            results = microstructure.porosity(img);
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'porosity_percent'));
            testCase.verifyTrue(isfield(results, 'num_pores'));
        end

        function testPorosityRange(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'porous', 'Porosity', 0.1);
            results = microstructure.porosity(img);
            testCase.verifyGreaterThanOrEqual(results.porosity_percent, 0);
            testCase.verifyLessThanOrEqual(results.porosity_percent, 100);
        end

        function testPorosityImageArea(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'porous', 'Size', [100, 100]);
            results = microstructure.porosity(img);
            testCase.verifyEqual(results.image_area, 10000);
        end

        function testPhaseFractionTwoPhase(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'dual_phase');
            results = microstructure.phase_fraction(img, 'NumPhases', 2);
            testCase.verifyEqual(results.num_phases, 2);
            testCase.verifyEqual(sum(results.fractions), 1, 'AbsTol', 0.01);
        end

        function testPhaseFractionThreePhase(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains');
            results = microstructure.phase_fraction(img, 'NumPhases', 3);
            testCase.verifyEqual(results.num_phases, 3);
            testCase.verifyEqual(numel(results.fractions), 3);
            testCase.verifyEqual(sum(results.fractions), 1, 'AbsTol', 0.01);
        end

        function testReportGrainsize(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains');
            results = microstructure.grainsize(img);
            microstructure.report(results, 'grainsize', 'SampleName', 'Test');
            testCase.verifyTrue(true);
        end

        function testReportPorosity(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'porous');
            results = microstructure.porosity(img);
            microstructure.report(results, 'porosity');
            testCase.verifyTrue(true);
        end

        function testCircularInterceptReturnsStruct(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 30);
            results = microstructure.circular_intercept(img, 'PixelSize', 0.5);
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'mean_intercept'));
            testCase.verifyTrue(isfield(results, 'astm_grain_number'));
            testCase.verifyTrue(isfield(results, 'circle_results'));
        end

        function testCircularInterceptPositiveValues(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 30);
            results = microstructure.circular_intercept(img, 'PixelSize', 0.5);
            if results.grain_count > 0
                testCase.verifyGreaterThan(results.mean_intercept, 0);
                testCase.verifyTrue(isfinite(results.astm_grain_number));
            end
        end

        function testCircularInterceptNumCircles(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 30);
            r3 = microstructure.circular_intercept(img, 'NumCircles', 3);
            r5 = microstructure.circular_intercept(img, 'NumCircles', 5);
            testCase.verifyEqual(r3.num_circles, 3);
            testCase.verifyEqual(r5.num_circles, 5);
            testCase.verifyEqual(numel(r5.circle_results), 5);
        end

        function testCircularInterceptPixelSize(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 30);
            r1 = microstructure.circular_intercept(img, 'PixelSize', 1);
            r2 = microstructure.circular_intercept(img, 'PixelSize', 2);
            if r1.grain_count > 0 && r2.grain_count > 0
                testCase.verifyGreaterThan(r2.mean_intercept, r1.mean_intercept * 1.5);
            end
        end
    end
end
