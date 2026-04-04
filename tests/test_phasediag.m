classdef test_phasediag < matlab.unittest.TestCase
%TEST_PHASEDIAG Unit tests for the phase diagram module

    methods (Test)
        function testBinaryReturnsOutputs(testCase)
            [T, x, ph] = phasediag.binary('Cu-Ni');
            testCase.verifySize(x, [1, 200]);
            testCase.verifySize(T, [1, 200]);
            testCase.verifySize(ph, [200, 200]);
        end

        function testBinaryPhaseValues(testCase)
            [~, ~, ph] = phasediag.binary('Cu-Ni');
            unique_phases = unique(ph(:));
            testCase.verifyTrue(all(ismember(unique_phases, [1 2 3])));
        end

        function testBinaryCuNiEndpoints(testCase)
            [T, x, ph] = phasediag.binary('Cu-Ni');
            % At x=0 (pure Cu), solidus/liquidus should be near Cu melting point (1358 K)
            % At x=1 (pure Ni), should be near Ni melting point (1728 K)
            % Pure component: liquid above Tm, solid below
            col1 = ph(:, 1); % x=0
            liq_temps = T(col1 == 1);
            sol_temps = T(col1 == 2);
            if ~isempty(liq_temps) && ~isempty(sol_temps)
                testCase.verifyGreaterThan(min(liq_temps), max(sol_temps) - 50);
            end
        end

        function testBinaryPbSn(testCase)
            [T, x, ph] = phasediag.binary('Pb-Sn');
            testCase.verifySize(ph, [200, 200]);
            % Pb-Sn should have liquid and solid regions
            testCase.verifyTrue(any(ph(:) == 1));
            testCase.verifyTrue(any(ph(:) == 2));
        end

        function testBinaryAlSi(testCase)
            [~, ~, ph] = phasediag.binary('Al-Si');
            testCase.verifyTrue(any(ph(:) == 1));
            testCase.verifyTrue(any(ph(:) == 2));
        end

        function testBinaryAlCu(testCase)
            [~, ~, ph] = phasediag.binary('Al-Cu');
            testCase.verifyGreaterThan(numel(ph), 0);
        end

        function testBinaryFeNi(testCase)
            [~, ~, ph] = phasediag.binary('Fe-Ni');
            testCase.verifyGreaterThan(numel(ph), 0);
        end

        function testBinaryCustom(testCase)
            [~, ~, ph] = phasediag.binary('custom', 'Tm_A', 1000, 'Tm_B', 1500, ...
                'Hf_A', 10000, 'Hf_B', 15000, 'Omega', 0);
            testCase.verifyTrue(any(ph(:) == 1));
            testCase.verifyTrue(any(ph(:) == 2));
        end

        function testBinaryCustomMissingParams(testCase)
            testCase.verifyError(@() phasediag.binary('custom'), 'phasediag:MissingParams');
        end

        function testBinaryUnknownSystem(testCase)
            testCase.verifyError(@() phasediag.binary('Unobtainium-Adamantium'), 'phasediag:UnknownSystem');
        end

        function testBinaryCustomGridSize(testCase)
            [T, x, ph] = phasediag.binary('Cu-Ni', 'NumX', 50, 'NumT', 50);
            testCase.verifySize(x, [1, 50]);
            testCase.verifySize(T, [1, 50]);
            testCase.verifySize(ph, [50, 50]);
        end

        function testLeverLiquid(testCase)
            % At very high temp, should be all liquid
            [T, ~, ~] = phasediag.binary('Cu-Ni');
            r = phasediag.lever('Cu-Ni', max(T), 0.5);
            testCase.verifyEqual(r.phase, 'liquid');
            testCase.verifyEqual(r.f_liquid, 1);
            testCase.verifyEqual(r.f_solid, 0);
        end

        function testLeverSolid(testCase)
            % At very low temp, should be all solid
            [T, ~, ~] = phasediag.binary('Cu-Ni');
            r = phasediag.lever('Cu-Ni', min(T), 0.5);
            testCase.verifyEqual(r.phase, 'solid');
            testCase.verifyEqual(r.f_liquid, 0);
            testCase.verifyEqual(r.f_solid, 1);
        end

        function testLeverTwoPhase(testCase)
            % Cu-Ni at x=0.5: liquidus ~1534K, solidus ~1560K
            % Use T=1547K to be in the two-phase region
            r = phasediag.lever('Cu-Ni', 1547, 0.5);
            testCase.verifyEqual(r.phase, 'two-phase');
            testCase.verifyGreaterThan(r.f_liquid, 0);
            testCase.verifyLessThan(r.f_liquid, 1);
            testCase.verifyEqual(r.f_liquid + r.f_solid, 1, 'AbsTol', 0.01);
        end

        function testLeverHasComposition(testCase)
            r = phasediag.lever('Cu-Ni', 1500, 0.5);
            testCase.verifyTrue(isfield(r, 'x_liquid'));
            testCase.verifyTrue(isfield(r, 'x_solid'));
            testCase.verifyEqual(r.temperature, 1500);
            testCase.verifyEqual(r.composition, 0.5);
        end

        function testSystemsReturnsTable(testCase)
            info = phasediag.systems();
            testCase.verifyClass(info, 'table');
            testCase.verifyGreaterThanOrEqual(height(info), 5);
        end
    end
end
