classdef test_mechtest_phase2 < matlab.unittest.TestCase
%TEST_MECHTEST_PHASE2 Unit tests for Phase 2 mechtest additions

    methods (Test)
        function testTrueStressStrainConversion(testCase)
            [strain, stress] = mechtest.generate_sample('steel', 'Noise', 0);
            [ts, tt] = mechtest.true_stress_strain(strain, stress);
            testCase.verifyEqual(numel(ts), numel(strain));
            testCase.verifyEqual(numel(tt), numel(stress));
        end

        function testTrueStrainFormula(testCase)
            eng_strain = [0; 0.01; 0.05; 0.1; 0.2];
            eng_stress = [0; 200; 400; 500; 480];
            [ts, tt] = mechtest.true_stress_strain(eng_strain, eng_stress);
            % Verify formula: true_strain = ln(1+eng_strain)
            testCase.verifyEqual(ts, log(1 + eng_strain), 'AbsTol', 1e-10);
            % Verify formula: true_stress = eng_stress * (1+eng_strain)
            testCase.verifyEqual(tt, eng_stress .* (1 + eng_strain), 'AbsTol', 1e-10);
        end

        function testTrueStressAlwaysGreater(testCase)
            eng_strain = linspace(0, 0.2, 100)';
            eng_stress = 200000 * eng_strain;
            eng_stress(eng_stress > 400) = 400;
            [~, tt] = mechtest.true_stress_strain(eng_strain, eng_stress);
            % True stress >= engineering stress (since 1+strain >= 1)
            testCase.verifyTrue(all(tt >= eng_stress - 1e-10));
        end

        function testTrueStressStrainSizeMismatch(testCase)
            testCase.verifyError(@() mechtest.true_stress_strain([1 2 3], [1 2]), ...
                'mechtest:SizeMismatch');
        end

        function testStatisticsBasic(testCase)
            for i = 1:5
                [s, st] = mechtest.generate_sample('steel');
                results(i) = mechtest.analyze(s, st); %#ok<AGROW>
            end
            stats = mechtest.statistics(results);
            testCase.verifyClass(stats, 'struct');
            testCase.verifyTrue(isfield(stats, 'youngs_modulus'));
            testCase.verifyTrue(isfield(stats, 'uts'));
        end

        function testStatisticsFields(testCase)
            for i = 1:3
                [s, st] = mechtest.generate_sample('aluminum');
                results(i) = mechtest.analyze(s, st); %#ok<AGROW>
            end
            stats = mechtest.statistics(results);
            testCase.verifyTrue(isfield(stats.uts, 'mean'));
            testCase.verifyTrue(isfield(stats.uts, 'std'));
            testCase.verifyTrue(isfield(stats.uts, 'ci_low'));
            testCase.verifyTrue(isfield(stats.uts, 'ci_high'));
            testCase.verifyTrue(isfield(stats.uts, 'cv'));
            testCase.verifyEqual(stats.uts.n, 3);
        end

        function testStatisticsCIContainsMean(testCase)
            for i = 1:5
                [s, st] = mechtest.generate_sample('steel');
                results(i) = mechtest.analyze(s, st); %#ok<AGROW>
            end
            stats = mechtest.statistics(results);
            testCase.verifyGreaterThanOrEqual(stats.uts.mean, stats.uts.ci_low);
            testCase.verifyLessThanOrEqual(stats.uts.mean, stats.uts.ci_high);
        end

        function testStatisticsInsufficientData(testCase)
            [s, st] = mechtest.generate_sample('steel');
            results = mechtest.analyze(s, st);
            testCase.verifyError(@() mechtest.statistics(results), 'mechtest:InsufficientData');
        end

        function testStatsReportRuns(testCase)
            for i = 1:3
                [s, st] = mechtest.generate_sample('steel');
                results(i) = mechtest.analyze(s, st); %#ok<AGROW>
            end
            stats = mechtest.statistics(results);
            mechtest.stats_report(stats, 'TestName', 'Test Batch');
            testCase.verifyTrue(true);
        end

        function testExpandedDatabase(testCase)
            T = matdb.list();
            testCase.verifyGreaterThanOrEqual(height(T), 50);
        end
    end
end
