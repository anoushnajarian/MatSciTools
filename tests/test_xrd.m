classdef test_xrd < matlab.unittest.TestCase
%TEST_XRD Unit tests for the XRD analysis module

    methods (Test)

        function testGeneratePattern(testCase)
            [tt, int, meta] = xrd.generate_pattern('Material', 'fcc_al');
            testCase.verifyEqual(numel(tt), numel(int));
            testCase.verifyGreaterThan(numel(tt), 0);
            testCase.verifyTrue(all(int >= 0));
            testCase.verifyTrue(isfield(meta, 'peak_positions'));
        end

        function testGeneratePatternBCC(testCase)
            [tt, int, meta] = xrd.generate_pattern('Material', 'bcc_fe');
            testCase.verifyEqual(numel(tt), numel(int));
            testCase.verifyGreaterThan(numel(tt), 0);
            testCase.verifyTrue(all(int >= 0));
            testCase.verifyTrue(isfield(meta, 'peak_positions'));
        end

        function testSubtractBackground(testCase)
            [tt, int] = xrd.generate_pattern('Material', 'fcc_al');
            [~, corrected] = xrd.subtract_background(tt, int);
            testCase.verifyEqual(max(corrected), max(int), 'AbsTol', max(int) * 0.3);
            testCase.verifyLessThanOrEqual(min(corrected), max(int) * 0.05);
        end

        function testFindPeaks(testCase)
            [tt, int] = xrd.generate_pattern('Material', 'fcc_al');
            [~, corrected] = xrd.subtract_background(tt, int);
            peaks = xrd.find_peaks(tt, corrected);
            testCase.verifyGreaterThanOrEqual(peaks.count, 3);
            testCase.verifyTrue(all(peaks.positions >= 20));
            testCase.verifyTrue(all(peaks.positions <= 90));
        end

        function testFitPeaks(testCase)
            [tt, int] = xrd.generate_pattern('Material', 'fcc_al');
            [~, corrected] = xrd.subtract_background(tt, int);
            peaks = xrd.find_peaks(tt, corrected);
            fits = xrd.fit_peaks(tt, corrected, peaks.positions);
            testCase.verifyClass(fits, 'cell');
            testCase.verifyGreaterThan(numel(fits), 0);
            hasGoodFit = false;
            for k = 1:numel(fits)
                testCase.verifyTrue(isfield(fits{k}, 'center'));
                testCase.verifyTrue(isfield(fits{k}, 'fwhm'));
                testCase.verifyTrue(isfield(fits{k}, 'height'));
                testCase.verifyTrue(isfield(fits{k}, 'R2'));
                if fits{k}.R2 > 0.5
                    hasGoodFit = true;
                end
            end
            testCase.verifyTrue(hasGoodFit);
        end

        function testFitPeaksGaussian(testCase)
            [tt, int] = xrd.generate_pattern('Material', 'fcc_al');
            [~, corrected] = xrd.subtract_background(tt, int);
            peaks = xrd.find_peaks(tt, corrected);
            fits = xrd.fit_peaks(tt, corrected, peaks.positions, 'Profile', 'gaussian');
            testCase.verifyClass(fits, 'cell');
            testCase.verifyGreaterThan(numel(fits), 0);
        end

        function testBragg(testCase)
            d = xrd.bragg(44.7);
            testCase.verifyEqual(d, 2.026, 'AbsTol', 0.05);
        end

        function testCrystalliteSizeScherrer(testCase)
            result = xrd.crystallite_size(0.5, 44.7);
            testCase.verifyGreaterThan(result.crystallite_size_nm, 0);
        end

        function testCrystalliteSizeWH(testCase)
            result = xrd.crystallite_size([0.3; 0.35; 0.4], [38.5; 44.7; 65.1], ...
                'Method', 'williamson_hall');
            testCase.verifyGreaterThan(result.crystallite_size_nm, 0);
            testCase.verifyTrue(isfield(result, 'microstrain'));
        end

        function testDualPhasePattern(testCase)
            [tt, int] = xrd.generate_pattern('Material', 'dual_phase');
            [~, corrected] = xrd.subtract_background(tt, int);
            peaks = xrd.find_peaks(tt, corrected);
            testCase.verifyGreaterThanOrEqual(peaks.count, 4);
        end

        %% New material patterns
        function testGeneratePatternHCPTi(testCase)
            [tt, int, meta] = xrd.generate_pattern('Material', 'hcp_ti');
            testCase.verifyEqual(numel(tt), numel(int));
            testCase.verifyTrue(all(int >= 0));
            testCase.verifyGreaterThanOrEqual(numel(meta.peak_positions), 5);
        end

        function testGeneratePatternFCCCu(testCase)
            [tt, int, meta] = xrd.generate_pattern('Material', 'fcc_cu');
            testCase.verifyEqual(numel(tt), numel(int));
            testCase.verifyTrue(all(int >= 0));
            testCase.verifyEqual(numel(meta.peak_positions), 4);
        end

        function testGeneratePatternFCCNi(testCase)
            [tt, int, meta] = xrd.generate_pattern('Material', 'fcc_ni');
            testCase.verifyEqual(numel(tt), numel(int));
            testCase.verifyTrue(all(int >= 0));
            testCase.verifyEqual(numel(meta.peak_positions), 3);
        end

        function testGeneratePatternBCCCr(testCase)
            [tt, int, meta] = xrd.generate_pattern('Material', 'bcc_cr');
            testCase.verifyEqual(numel(tt), numel(int));
            testCase.verifyTrue(all(int >= 0));
            testCase.verifyEqual(numel(meta.peak_positions), 3);
        end

        function testGeneratePatternDiamondSi(testCase)
            [tt, int, meta] = xrd.generate_pattern('Material', 'diamond_si');
            testCase.verifyEqual(numel(tt), numel(int));
            testCase.verifyTrue(all(int >= 0));
            testCase.verifyEqual(numel(meta.peak_positions), 5);
            testCase.verifyEqual(meta.peak_hkl{1}, '111');
        end

        function testGeneratePatternWurtziteZnO(testCase)
            [tt, int, meta] = xrd.generate_pattern('Material', 'wurtzite_zno');
            testCase.verifyEqual(numel(tt), numel(int));
            testCase.verifyTrue(all(int >= 0));
            testCase.verifyEqual(numel(meta.peak_positions), 7);
        end

        function testGeneratePatternRocksaltNaCl(testCase)
            [tt, int, meta] = xrd.generate_pattern('Material', 'rocksalt_nacl');
            testCase.verifyEqual(numel(tt), numel(int));
            testCase.verifyTrue(all(int >= 0));
            testCase.verifyEqual(numel(meta.peak_positions), 5);
            testCase.verifyEqual(meta.peak_hkl{1}, '200');
        end

        function testGeneratePatternInvalidMaterial(testCase)
            testCase.verifyError( ...
                @() xrd.generate_pattern('Material', 'unobtanium'), ...
                'xrd:UnknownMaterial');
        end

        %% Profile fitting quality — use strict peak finding to test only real peaks
        function testFitPeaksLorentzian(testCase)
            [tt, int] = xrd.generate_pattern('Material', 'fcc_al');
            [~, corrected] = xrd.subtract_background(tt, int);
            peaks = xrd.find_peaks(tt, corrected, ...
                'MinHeight', 0.15, 'MinProminence', 0.10, 'MinDistance', 2.0);
            fits = xrd.fit_peaks(tt, corrected, peaks.positions, 'Profile', 'lorentzian');
            for k = 1:numel(fits)
                testCase.verifyGreaterThan(fits{k}.center, 20);
                testCase.verifyLessThan(fits{k}.center, 90);
                testCase.verifyLessThan(fits{k}.fwhm, 5);
            end
        end

        function testFitPeaksGaussianQuality(testCase)
            [tt, int] = xrd.generate_pattern('Material', 'fcc_al');
            [~, corrected] = xrd.subtract_background(tt, int);
            peaks = xrd.find_peaks(tt, corrected, ...
                'MinHeight', 0.15, 'MinProminence', 0.10, 'MinDistance', 2.0);
            fits = xrd.fit_peaks(tt, corrected, peaks.positions, 'Profile', 'gaussian');
            for k = 1:numel(fits)
                testCase.verifyGreaterThan(fits{k}.center, 20);
                testCase.verifyLessThan(fits{k}.center, 90);
                testCase.verifyLessThan(fits{k}.fwhm, 5);
            end
        end

        function testFitPeaksPseudoVoigtQuality(testCase)
            [tt, int] = xrd.generate_pattern('Material', 'fcc_al');
            [~, corrected] = xrd.subtract_background(tt, int);
            peaks = xrd.find_peaks(tt, corrected, ...
                'MinHeight', 0.15, 'MinProminence', 0.10, 'MinDistance', 2.0);
            fits = xrd.fit_peaks(tt, corrected, peaks.positions, 'Profile', 'pseudo_voigt');
            for k = 1:numel(fits)
                testCase.verifyGreaterThan(fits{k}.center, 20);
                testCase.verifyLessThan(fits{k}.center, 90);
                testCase.verifyLessThan(fits{k}.fwhm, 5);
            end
        end

        %% Peak finding with tuned sensitivity
        function testFindPeaksSensitivity(testCase)
            [tt, int] = xrd.generate_pattern('Material', 'fcc_al');
            [~, corrected] = xrd.subtract_background(tt, int);
            peaks = xrd.find_peaks(tt, corrected, ...
                'MinHeight', 0.15, 'MinProminence', 0.10, 'MinDistance', 2.0);
            testCase.verifyEqual(peaks.count, 4);
        end

        function testWilliamsonHallPlotReturnsStruct(testCase)
            result = xrd.williamson_hall_plot([0.3; 0.35; 0.4], ...
                [38.5; 44.7; 65.1], 'ShowPlot', false);
            testCase.verifyTrue(isfield(result, 'crystallite_size_nm'));
            testCase.verifyTrue(isfield(result, 'microstrain'));
            testCase.verifyTrue(isfield(result, 'R2'));
            testCase.verifyTrue(isfield(result, 'x'));
            testCase.verifyTrue(isfield(result, 'y'));
            testCase.verifyTrue(isfield(result, 'y_fit'));
            testCase.verifyGreaterThan(result.crystallite_size_nm, 0);
        end

        function testWilliamsonHallPlotWithInstrBroadening(testCase)
            result = xrd.williamson_hall_plot([0.5; 0.55; 0.6; 0.7], ...
                [38.5; 44.7; 65.1; 78.2], ...
                'InstrBroadening', 0.1, 'ShowPlot', false);
            testCase.verifyGreaterThan(result.crystallite_size_nm, 0);
            testCase.verifyTrue(isfinite(result.microstrain));
        end

        function testCrystalliteSizeInstrBroadening(testCase)
            res_no = xrd.crystallite_size(0.5, 44.7);
            res_yes = xrd.crystallite_size(0.5, 44.7, 'InstrBroadening', 0.1);
            testCase.verifyGreaterThan(res_yes.crystallite_size_nm(1), ...
                res_no.crystallite_size_nm(1));
        end

    end
end
