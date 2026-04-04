classdef test_new_features < matlab.unittest.TestCase
%TEST_NEW_FEATURES Unit tests for cost estimation, report generation, and batch processing

    methods (Test)

        %% ===== Cost Estimation: Component Mode =====

        function testComponentCostBasic(testCase)
            r = matsel.cost_estimate('component', 'Material', 'AISI 1045', 'Volume', 0.001);
            testCase.verifyClass(r, 'struct');
            testCase.verifyTrue(isfield(r, 'material_name'));
            testCase.verifyTrue(isfield(r, 'density'));
            testCase.verifyTrue(isfield(r, 'cost_per_kg'));
            testCase.verifyTrue(isfield(r, 'mass_kg'));
            testCase.verifyTrue(isfield(r, 'raw_cost'));
            testCase.verifyTrue(isfield(r, 'manufacturing_factor'));
            testCase.verifyTrue(isfield(r, 'total_cost'));
            testCase.verifyEqual(r.mass_kg, r.density * 0.001, 'AbsTol', 1e-6);
            testCase.verifyEqual(r.raw_cost, r.mass_kg * r.cost_per_kg, 'AbsTol', 1e-6);
            testCase.verifyEqual(r.total_cost, r.raw_cost * r.manufacturing_factor, 'AbsTol', 1e-6);
        end

        function testComponentCostWithManufacturing(testCase)
            r = matsel.cost_estimate('component', 'Material', 'AISI 1045', ...
                'Volume', 0.001, 'ManufacturingFactor', 2.5);
            testCase.verifyEqual(r.manufacturing_factor, 2.5);
            testCase.verifyEqual(r.total_cost, r.raw_cost * 2.5, 'AbsTol', 1e-6);
        end

        function testComponentCostInvalidMaterial(testCase)
            testCase.verifyError(@() matsel.cost_estimate('component', ...
                'Material', 'Unobtanium_XYZ', 'Volume', 0.001), ...
                'matdb:NotFound');
        end

        %% ===== Cost Estimation: Ranking Mode =====

        function testRankingBasic(testCase)
            T = matsel.cost_estimate('ranking', 'PerformanceIndex', 'yield_strength ./ cost');
            testCase.verifyClass(T, 'table');
            testCase.verifyGreaterThanOrEqual(height(T), 5);
            testCase.verifyTrue(ismember('Name', T.Properties.VariableNames));
            testCase.verifyTrue(ismember('PerformanceIndex', T.Properties.VariableNames));
            pi_vals = T.PerformanceIndex;
            testCase.verifyTrue(issorted(pi_vals, 'descend'));
        end

        function testRankingWithCategory(testCase)
            T = matsel.cost_estimate('ranking', 'PerformanceIndex', ...
                'yield_strength ./ cost', 'Category', 'Metal');
            testCase.verifyGreaterThan(height(T), 0);
        end

        function testRankingTopN(testCase)
            T = matsel.cost_estimate('ranking', 'PerformanceIndex', ...
                'yield_strength ./ cost', 'TopN', 5);
            testCase.verifyEqual(height(T), 5);
        end

        %% ===== Cost Estimation: Substitute Mode =====

        function testSubstituteBasic(testCase)
            T = matsel.cost_estimate('substitute', 'Current', 'Ti-6Al-4V');
            testCase.verifyClass(T, 'table');
            testCase.verifyGreaterThan(height(T), 0);
            testCase.verifyTrue(all(T.Cost < 25));
        end

        function testSubstituteWithConstraints(testCase)
            T = matsel.cost_estimate('substitute', 'Current', 'Ti-6Al-4V', ...
                'MinYield', 500);
            testCase.verifyGreaterThan(height(T), 0);
            testCase.verifyTrue(all(T.YieldStrength >= 500));
        end

        %% ===== Report Generation: Mechtest =====

        function testMechtestReportTxt(testCase)
            [strain, stress] = mechtest.generate_sample('steel');
            results = mechtest.analyze(strain, stress);
            txtFile = [tempname, '.txt'];
            testCase.addTeardown(@() delete(txtFile));
            mechtest.generate_report(results, txtFile, 'Format', 'txt');
            testCase.verifyTrue(isfile(txtFile));
            contents = fileread(txtFile);
            testCase.verifySubstring(contents, 'Elastic Modulus');
        end

        function testMechtestReportHtml(testCase)
            [strain, stress] = mechtest.generate_sample('steel');
            results = mechtest.analyze(strain, stress);
            htmlFile = [tempname, '.html'];
            testCase.addTeardown(@() delete(htmlFile));
            mechtest.generate_report(results, htmlFile, 'Format', 'html');
            testCase.verifyTrue(isfile(htmlFile));
            contents = fileread(htmlFile);
            testCase.verifySubstring(contents, '<html>');
            testCase.verifySubstring(contents, 'Elastic Modulus');
        end

        %% ===== Report Generation: Microstructure =====

        function testMicroReportTxt(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains');
            gs = microstructure.grainsize(img);
            pr = microstructure.porosity(img);
            rs.grainsize = gs;
            rs.porosity = pr;
            txtFile = [tempname, '.txt'];
            testCase.addTeardown(@() delete(txtFile));
            microstructure.generate_report(rs, txtFile, 'Format', 'txt');
            testCase.verifyTrue(isfile(txtFile));
            contents = fileread(txtFile);
            testCase.verifySubstring(contents, 'Grain Size');
            testCase.verifySubstring(contents, 'Porosity');
        end

        function testMicroReportHtml(testCase)
            [img, ~] = microstructure.generate_synthetic('Type', 'grains');
            gs = microstructure.grainsize(img);
            pr = microstructure.porosity(img);
            rs.grainsize = gs;
            rs.porosity = pr;
            htmlFile = [tempname, '.html'];
            testCase.addTeardown(@() delete(htmlFile));
            microstructure.generate_report(rs, htmlFile, 'Format', 'html');
            testCase.verifyTrue(isfile(htmlFile));
            contents = fileread(htmlFile);
            testCase.verifySubstring(contents, '<html>');
            testCase.verifySubstring(contents, 'Grain Size');
            testCase.verifySubstring(contents, 'Porosity');
        end

        %% ===== Batch Processing =====

        function testBatchBasic(testCase)
            images = cell(1, 3);
            for k = 1:3
                [images{k}, ~] = microstructure.generate_synthetic('Type', 'grains', 'Noise', k * 0.01);
            end
            results = microstructure.batch_process(images, 'ShowProgress', false);
            testCase.verifyEqual(results.n_images, 3);
            testCase.verifyEqual(numel(results.individual), 3);
            testCase.verifyTrue(isfield(results.summary, 'mean_grain_size'));
            testCase.verifyTrue(isfield(results.summary, 'mean_porosity'));
        end

        function testBatchSummaryStats(testCase)
            images = cell(1, 3);
            for k = 1:3
                [images{k}, ~] = microstructure.generate_synthetic('Type', 'grains', 'Noise', k * 0.01);
            end
            results = microstructure.batch_process(images, 'ShowProgress', false);
            testCase.verifyGreaterThan(results.summary.mean_grain_size, 0);
            testCase.verifyGreaterThanOrEqual(results.summary.mean_porosity, 0);
            all_grain_sizes = zeros(1, 3);
            for k = 1:3
                all_grain_sizes(k) = results.individual{k}.grainsize.mean_intercept;
            end
            testCase.verifyEqual(numel(all_grain_sizes), 3);
        end

        function testBatchWithPhaseFraction(testCase)
            images = cell(1, 2);
            for k = 1:2
                [images{k}, ~] = microstructure.generate_synthetic('Type', 'dual_phase', 'Noise', k * 0.01);
            end
            results = microstructure.batch_process(images, 'ShowProgress', false, ...
                'Analyses', {'grainsize', 'porosity', 'phase_fraction'});
            testCase.verifyTrue(isfield(results.summary, 'mean_fractions'));
        end

        function testBatchErrorHandling(testCase)
            [img1, ~] = microstructure.generate_synthetic('Type', 'grains');
            [img2, ~] = microstructure.generate_synthetic('Type', 'grains', 'Noise', 0.02);
            images = {img1, 'nonexistent_file.png', img2};
            results = microstructure.batch_process(images, 'ShowProgress', false);
            testCase.verifyEqual(results.n_images, 3);
            testCase.verifyTrue(isfield(results.individual{2}, 'error'));
        end
    end
end
