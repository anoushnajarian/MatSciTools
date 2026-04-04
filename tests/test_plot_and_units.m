classdef test_plot_and_units < matlab.unittest.TestCase
%TEST_PLOT_AND_UNITS Tests for plot_styles and convert_units

    methods (Test)

        %% ===== Plot Styles =====

        function testPlotStylesReturnsStruct(testCase)
            s = matsel.plot_styles();
            testCase.verifyClass(s, 'struct');
            testCase.verifyTrue(isfield(s, 'colors'));
            testCase.verifyTrue(isfield(s, 'categories'));
            testCase.verifyTrue(isfield(s, 'markers'));
            testCase.verifyTrue(isfield(s, 'apply'));
            testCase.verifyTrue(isfield(s, 'journal'));
            testCase.verifyTrue(isfield(s, 'export'));
        end

        function testColorsAre8x3(testCase)
            s = matsel.plot_styles();
            testCase.verifySize(s.colors, [8 3]);
            testCase.verifyGreaterThanOrEqual(s.colors, 0);
            testCase.verifyLessThanOrEqual(s.colors, 1);
        end

        function testCategoryColors(testCase)
            s = matsel.plot_styles();
            testCase.verifyTrue(isfield(s.categories, 'Metal'));
            testCase.verifyTrue(isfield(s.categories, 'Ceramic'));
            testCase.verifyTrue(isfield(s.categories, 'Polymer'));
            testCase.verifyTrue(isfield(s.categories, 'Composite'));
            testCase.verifySize(s.categories.Metal, [1 3]);
        end

        function testApplyToAxes(testCase)
            fig = figure('Visible', 'off');
            ax = axes(fig);
            plot(ax, 1:5, rand(1,5));
            s = matsel.plot_styles();
            s.apply(ax);
            testCase.verifyEqual(ax.FontName, 'Arial');
            testCase.verifyTrue(strcmp(ax.Box, 'on'));
            delete(fig);
        end

        function testJournalStyle(testCase)
            fig = figure('Visible', 'off');
            ax = axes(fig);
            plot(ax, 1:5, rand(1,5));
            s = matsel.plot_styles();
            s.journal(fig);
            testCase.verifyEqual(fig.Color, [1 1 1]);
            testCase.verifyEqual(ax.FontName, 'Arial');
            testCase.verifyEqual(ax.FontSize, 10);
            delete(fig);
        end

        function testExportPNG(testCase)
            fig = figure('Visible', 'off');
            plot(1:5, rand(1,5));
            s = matsel.plot_styles();
            filepath = fullfile(tempdir, 'test_export.png');
            s.export(fig, filepath);
            testCase.verifyTrue(exist(filepath, 'file') > 0);
            delete(fig);
            delete(filepath);
        end

        function testExportPreset(testCase)
            fig = figure('Visible', 'off');
            plot(1:5, rand(1,5));
            s = matsel.plot_styles();
            filepath = fullfile(tempdir, 'test_export_journal.png');
            s.export(fig, filepath, 'Preset', 'journal_single');
            testCase.verifyTrue(exist(filepath, 'file') > 0);
            delete(fig);
            delete(filepath);
        end

        %% ===== Unit Converter =====

        function testStressMPaToGPa(testCase)
            result = matsel.convert_units(1000, 'MPa', 'GPa');
            testCase.verifyEqual(result, 1, 'AbsTol', 1e-10);
        end

        function testStressMPaToKsi(testCase)
            result = matsel.convert_units(200, 'MPa', 'ksi');
            testCase.verifyEqual(result, 29.0075, 'AbsTol', 0.01);
        end

        function testStressPsiToMPa(testCase)
            result = matsel.convert_units(14500, 'psi', 'MPa');
            testCase.verifyEqual(result, 99.974, 'AbsTol', 0.1);
        end

        function testTemperatureCToK(testCase)
            result = matsel.convert_units(0, 'C', 'K');
            testCase.verifyEqual(result, 273.15, 'AbsTol', 1e-10);
        end

        function testTemperatureCToF(testCase)
            result = matsel.convert_units(100, 'C', 'F');
            testCase.verifyEqual(result, 212, 'AbsTol', 1e-10);
        end

        function testTemperatureFToC(testCase)
            result = matsel.convert_units(32, 'F', 'C');
            testCase.verifyEqual(result, 0, 'AbsTol', 1e-10);
        end

        function testLengthMmToIn(testCase)
            result = matsel.convert_units(25.4, 'mm', 'in');
            testCase.verifyEqual(result, 1, 'AbsTol', 1e-10);
        end

        function testLengthAngstromToNm(testCase)
            result = matsel.convert_units(10, 'A', 'nm');
            testCase.verifyEqual(result, 1, 'AbsTol', 1e-10);
        end

        function testDensityKgm3ToGcm3(testCase)
            result = matsel.convert_units(7850, 'kg/m3', 'g/cm3');
            testCase.verifyEqual(result, 7.85, 'AbsTol', 0.001);
        end

        function testEnergyEvToJ(testCase)
            result = matsel.convert_units(1, 'eV', 'J');
            testCase.verifyEqual(result, 1.602176634e-19, 'RelTol', 1e-6);
        end

        function testAngleDegToRad(testCase)
            result = matsel.convert_units(180, 'deg', 'rad');
            testCase.verifyEqual(result, pi, 'AbsTol', 1e-10);
        end

        function testIdentityConversion(testCase)
            result = matsel.convert_units(42, 'MPa', 'MPa');
            testCase.verifyEqual(result, 42, 'AbsTol', 1e-10);
        end

        function testVectorInput(testCase)
            result = matsel.convert_units([100 200 300], 'MPa', 'GPa');
            testCase.verifyEqual(result, [0.1 0.2 0.3], 'AbsTol', 1e-10);
        end

        function testUnknownUnitError(testCase)
            testCase.verifyError(@() matsel.convert_units(1, 'foo', 'bar'), ...
                'matsel:UnknownUnit');
        end

    end
end
