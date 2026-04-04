classdef MatSciApp < handle
%MATSCIAPP Material Science Engineering Toolkit - GUI Application
%   Launch with: app = gui.MatSciApp();
%
%   Provides a tabbed interface for:
%   - Material Database browsing and search
%   - Material Selection with Ashby charts
%   - Mechanical Testing analysis
%   - Phase Diagram computation

    properties (Access = public)
        UIFigure            matlab.ui.Figure
        TabGroup            matlab.ui.container.TabGroup

        % Database tab
        DbTab               matlab.ui.container.Tab
        DbTable             matlab.ui.control.Table
        DbCategoryDropdown  matlab.ui.control.DropDown
        DbSearchField       matlab.ui.control.EditField
        DbSearchButton      matlab.ui.control.Button
        DbDetailsArea       matlab.ui.control.TextArea

        % Selection tab
        SelTab              matlab.ui.container.Tab
        SelPropXDropdown    matlab.ui.control.DropDown
        SelPropYDropdown    matlab.ui.control.DropDown
        SelPlotButton       matlab.ui.control.Button
        SelAxes             matlab.ui.control.UIAxes

        % Mechtest tab
        MechTab             matlab.ui.container.Tab
        MechMaterialDrop    matlab.ui.control.DropDown
        MechGenerateButton  matlab.ui.control.Button
        MechAnalyzeButton   matlab.ui.control.Button
        MechAxes            matlab.ui.control.UIAxes
        MechResultsArea     matlab.ui.control.TextArea

        % Export button (Selection tab)
        SelExportButton         matlab.ui.control.Button

        % Cost estimation (Selection tab)
        SelCostMaterialField    matlab.ui.control.EditField
        SelCostVolumeField      matlab.ui.control.NumericEditField
        SelCostButton           matlab.ui.control.Button
        SelCostLabel            matlab.ui.control.Label

        % Export buttons
        MechExportButton        matlab.ui.control.Button
        MechFitModelsButton matlab.ui.control.Button

        % Phase diagram tab
        PhaseTab            matlab.ui.container.Tab
        PhaseSystemDrop     matlab.ui.control.DropDown
        PhasePlotButton     matlab.ui.control.Button
        PhaseAxes           matlab.ui.control.UIAxes
        PhaseTempField      matlab.ui.control.NumericEditField
        PhaseCompField      matlab.ui.control.NumericEditField
        PhaseLeverButton    matlab.ui.control.Button
        PhaseLeverArea      matlab.ui.control.TextArea

        % Intelligence tab
        IntelTab            matlab.ui.container.Tab
        IntelMaterialField  matlab.ui.control.EditField
        IntelPredictButton  matlab.ui.control.Button
        IntelResultsArea    matlab.ui.control.TextArea
        IntelRecDensMax     matlab.ui.control.NumericEditField
        IntelRecYSMin       matlab.ui.control.NumericEditField
        IntelRecButton      matlab.ui.control.Button
        IntelRecTable       matlab.ui.control.Table
        IntelSurrogateBtn   matlab.ui.control.Button
        IntelSurrogateArea  matlab.ui.control.TextArea
        IntelAnomalyBtn     matlab.ui.control.Button
        IntelImportanceBtn  matlab.ui.control.Button
        IntelClusterBtn     matlab.ui.control.Button
        % Microstructure tab
        MicroTab            matlab.ui.container.Tab
        MicroTypeDrop       matlab.ui.control.DropDown
        MicroGrainsSpin     matlab.ui.control.NumericEditField
        MicroGenButton      matlab.ui.control.Button
        MicroAxesImg        matlab.ui.control.UIAxes
        MicroAnalyzeButton  matlab.ui.control.Button
        MicroResultsArea    matlab.ui.control.TextArea
        MicroBatchButton    matlab.ui.control.Button
        MicroClassifyButton matlab.ui.control.Button

        % XRD tab
        XrdTab              matlab.ui.container.Tab
        XrdMaterialDrop     matlab.ui.control.DropDown
        XrdGenButton        matlab.ui.control.Button
        XrdAnalyzeButton    matlab.ui.control.Button
        XrdAxes             matlab.ui.control.UIAxes
        XrdResultsArea      matlab.ui.control.TextArea
        XrdProfileDrop      matlab.ui.control.DropDown
        XrdSensitivitySpin  matlab.ui.control.NumericEditField
        XrdExportButton     matlab.ui.control.Button
        CurrentTwoTheta     double
        CurrentIntensity    double

        % Internal data
        CurrentStrain       double
        CurrentStress       double
        CurrentMicroImage
    end

    methods (Access = public)
        function app = MatSciApp()
            createComponents(app);
            app.UIFigure.Visible = 'on';
        end

        function delete(app)
            delete(app.UIFigure);
        end
    end

    methods (Access = private)
        function createComponents(app)
            % Main figure
            app.UIFigure = uifigure('Name', 'MatSciTools v0.10', ...
                'Position', [100 100 1000 700], 'Resize', 'on');

            % Tab group
            app.TabGroup = uitabgroup(app.UIFigure, ...
                'Position', [10 10 980 680]);

            createDatabaseTab(app);
            createSelectionTab(app);
            createMechtestTab(app);
            createPhaseTab(app);
            createMicrostructureTab(app);
            createXRDTab(app);
            createIntelligenceTab(app);

            % Load initial data
            refreshDatabase(app);
        end

        %% ---- DATABASE TAB ----
        function createDatabaseTab(app)
            app.DbTab = uitab(app.TabGroup, 'Title', 'Material Database');

            uilabel(app.DbTab, 'Text', 'Category:', ...
                'Position', [20 620 60 22]);
            app.DbCategoryDropdown = uidropdown(app.DbTab, ...
                'Items', {'All', 'Metal', 'Ceramic', 'Polymer', 'Composite'}, ...
                'Position', [85 620 120 22], ...
                'ValueChangedFcn', @(~,~) refreshDatabase(app));

            uilabel(app.DbTab, 'Text', 'Search:', ...
                'Position', [230 620 50 22]);
            app.DbSearchField = uieditfield(app.DbTab, ...
                'Position', [285 620 150 22]);
            app.DbSearchButton = uibutton(app.DbTab, ...
                'Text', 'Search', 'Position', [445 620 60 22], ...
                'ButtonPushedFcn', @(~,~) searchMaterial(app));

            app.DbTable = uitable(app.DbTab, ...
                'Position', [20 200 940 400], ...
                'CellSelectionCallback', @(~,evt) materialSelected(app, evt));

            uilabel(app.DbTab, 'Text', 'Material Details:', ...
                'Position', [20 170 120 22], 'FontWeight', 'bold');
            app.DbDetailsArea = uitextarea(app.DbTab, ...
                'Position', [20 10 940 155], 'Editable', 'off');
        end

        function refreshDatabase(app)
            selectedCat = app.DbCategoryDropdown.Value;
            if strcmp(selectedCat, 'All')
                T = matdb.list();
            else
                T = matdb.list(selectedCat);
            end
            app.DbTable.Data = T;
            app.DbTable.ColumnName = T.Properties.VariableNames;
        end

        function searchMaterial(app)
            query = app.DbSearchField.Value;
            if isempty(query)
                refreshDatabase(app);
                return;
            end
            try
                mat = matdb.get(query);
                app.DbDetailsArea.Value = formatMaterialDetails(app, mat);
            catch
                app.DbDetailsArea.Value = sprintf('Material "%s" not found.', query);
            end
        end

        function materialSelected(app, evt)
            if isempty(evt.Indices), return; end
            row = evt.Indices(1);
            tbl = app.DbTable.Data;
            name = tbl.Name{row};
            try
                mat = matdb.get(name);
                app.DbDetailsArea.Value = formatMaterialDetails(app, mat);
            catch
            end
        end

        function details = formatMaterialDetails(~, mat)
            details = sprintf(['Name: %s\nCategory: %s (%s)\n' ...
                'Density: %.0f kg/m³\nYoung''s Modulus: %.1f GPa\n' ...
                'Yield Strength: %.0f MPa\nUTS: %.0f MPa\n' ...
                'Elongation: %.1f%%\nHardness: %.0f HV\n' ...
                'Thermal Conductivity: %.1f W/(m·K)\n' ...
                'Melting Point: %.0f °C\nCost: $%.1f/kg'], ...
                mat.name, mat.category, mat.subcategory, ...
                mat.density, mat.youngs_modulus, mat.yield_strength, ...
                mat.uts, mat.elongation, mat.hardness, ...
                mat.thermal_conductivity, mat.melting_point, mat.cost);
        end

        %% ---- SELECTION TAB ----
        function createSelectionTab(app)
            app.SelTab = uitab(app.TabGroup, 'Title', 'Material Selection');

            props = {'density', 'youngs_modulus', 'yield_strength', 'uts', ...
                'elongation', 'hardness', 'thermal_conductivity', ...
                'thermal_expansion', 'melting_point', 'cost', 'specific_heat'};

            uilabel(app.SelTab, 'Text', 'X-Axis Property:', ...
                'Position', [20 620 100 22]);
            app.SelPropXDropdown = uidropdown(app.SelTab, ...
                'Items', props, 'Value', 'density', ...
                'Position', [125 620 160 22]);

            uilabel(app.SelTab, 'Text', 'Y-Axis Property:', ...
                'Position', [310 620 100 22]);
            app.SelPropYDropdown = uidropdown(app.SelTab, ...
                'Items', props, 'Value', 'youngs_modulus', ...
                'Position', [415 620 160 22]);

            app.SelPlotButton = uibutton(app.SelTab, ...
                'Text', 'Generate Ashby Chart', 'Position', [600 620 150 22], ...
                'ButtonPushedFcn', @(~,~) plotAshby(app));

            app.SelExportButton = uibutton(app.SelTab, ...
                'Text', 'Export Plot...', 'Position', [760 620 90 22], ...
                'ButtonPushedFcn', @(~,~) exportPlot(app));

            app.SelAxes = uiaxes(app.SelTab, ...
                'Position', [50 70 880 540]);

            % Cost estimation section
            uilabel(app.SelTab, 'Text', 'COST ESTIMATION', ...
                'Position', [20 30 150 22], 'FontWeight', 'bold');

            uilabel(app.SelTab, 'Text', 'Material:', ...
                'Position', [170 30 55 22]);
            app.SelCostMaterialField = uieditfield(app.SelTab, ...
                'Position', [230 30 150 22], 'Value', 'AISI 1045');

            uilabel(app.SelTab, 'Text', 'Vol (m³):', ...
                'Position', [395 30 55 22]);
            app.SelCostVolumeField = uieditfield(app.SelTab, 'numeric', ...
                'Position', [455 30 70 22], 'Value', 0.001);

            app.SelCostButton = uibutton(app.SelTab, ...
                'Text', 'Estimate Cost', 'Position', [540 30 100 22], ...
                'ButtonPushedFcn', @(~,~) estimateCost(app));

            app.SelCostLabel = uilabel(app.SelTab, ...
                'Text', '', 'Position', [650 30 300 22]);
        end

        function plotAshby(app)
            px = app.SelPropXDropdown.Value;
            py = app.SelPropYDropdown.Value;

            cla(app.SelAxes);
            hold(app.SelAxes, 'on');

            styles = matsel.plot_styles();
            colorMap = styles.categories;
            markerMap = styles.markers;
            categories = {'Metal', 'Ceramic', 'Polymer', 'Composite'};

            u = matdb.units();
            allMats = matdb.search('density', [-Inf Inf]);

            for ci = 1:4
                catName = categories{ci};
                catMats = allMats(strcmpi({allMats.category}, catName));
                if isempty(catMats), continue; end
                x_vals = [catMats.(px)];
                y_vals = [catMats.(py)];
                names = {catMats.name};
                sc = scatter(app.SelAxes, x_vals, y_vals, 60, colorMap.(catName), 'filled', ...
                    'Marker', markerMap.(catName), 'DisplayName', catName);
                sc.DataTipTemplate.DataTipRows(1).Label = sprintf('%s (%s)', strrep(px,'_',' '), u.(px));
                sc.DataTipTemplate.DataTipRows(2).Label = sprintf('%s (%s)', strrep(py,'_',' '), u.(py));
                row = dataTipTextRow('Material', names);
                sc.DataTipTemplate.DataTipRows(end+1) = row;
            end

            set(app.SelAxes, 'XScale', 'log', 'YScale', 'log');
            xlabel(app.SelAxes, sprintf('%s (%s)', strrep(px,'_',' '), u.(px)));
            ylabel(app.SelAxes, sprintf('%s (%s)', strrep(py,'_',' '), u.(py)));
            title(app.SelAxes, 'Ashby Material Property Chart');
            legend(app.SelAxes, 'Location', 'best');
            styles.apply(app.SelAxes);
            hold(app.SelAxes, 'off');
        end

        function exportPlot(app)
            [file, path] = uiputfile( ...
                {'*.png','PNG (300 DPI)'; ...
                 '*.pdf','PDF (vector)'; ...
                 '*.tif','TIFF (300 DPI)'; ...
                 '*.eps','EPS (vector)'; ...
                 '*.svg','SVG (vector)'}, ...
                'Export Figure');
            if isequal(file, 0), return; end
            filepath = fullfile(path, file);
            try
                px = app.SelPropXDropdown.Value;
                py = app.SelPropYDropdown.Value;
                styles = matsel.plot_styles();

                % Re-render into a classic figure (copyobj from UIAxes is unreliable)
                fig = figure('Visible', 'off', 'Color', 'w');
                ax = axes(fig);
                hold(ax, 'on');

                categories = {'Metal', 'Ceramic', 'Polymer', 'Composite'};
                u = matdb.units();
                allMats = matdb.search('density', [-Inf Inf]);

                for ci = 1:4
                    catName = categories{ci};
                    catMats = allMats(strcmpi({allMats.category}, catName));
                    if isempty(catMats), continue; end
                    scatter(ax, [catMats.(px)], [catMats.(py)], 60, ...
                        styles.categories.(catName), 'filled', ...
                        'Marker', styles.markers.(catName), ...
                        'DisplayName', catName);
                end

                set(ax, 'XScale', 'log', 'YScale', 'log');
                xlabel(ax, sprintf('%s (%s)', strrep(px,'_',' '), u.(px)));
                ylabel(ax, sprintf('%s (%s)', strrep(py,'_',' '), u.(py)));
                title(ax, 'Ashby Material Property Chart');
                legend(ax, 'Location', 'best');
                styles.apply(ax);
                hold(ax, 'off');

                styles.export(fig, filepath, 'Preset', 'journal_double');
                delete(fig);

                uialert(app.UIFigure, sprintf('Exported to:\n%s', filepath), ...
                    'Export Complete', 'Icon', 'success');
            catch ex
                if exist('fig', 'var') && isvalid(fig), delete(fig); end
                uialert(app.UIFigure, sprintf('Export failed: %s', ex.message), ...
                    'Export Error', 'Icon', 'error');
            end
        end

        function estimateCost(app)
            try
                r = matsel.cost_estimate('component', ...
                    'Material', app.SelCostMaterialField.Value, ...
                    'Volume', app.SelCostVolumeField.Value, ...
                    'ManufacturingFactor', 2.0);
                app.SelCostLabel.Text = sprintf('Mass: %.2f kg | Raw: $%.2f | Total: $%.2f (2x mfg)', ...
                    r.mass_kg, r.raw_cost, r.total_cost);
            catch ex
                app.SelCostLabel.Text = sprintf('Error: %s', ex.message);
            end
        end

        %% ---- MECHTEST TAB ----
        function createMechtestTab(app)
            app.MechTab = uitab(app.TabGroup, 'Title', 'Mechanical Testing');

            uilabel(app.MechTab, 'Text', 'Material:', ...
                'Position', [20 620 55 22]);

            % Build dropdown from presets + database materials
            presets = {'steel', 'aluminum', 'polymer', 'ceramic', 'rubber'};
            try
                T = matdb.list();
                dbNames = T.Name';
            catch
                dbNames = {};
            end
            allItems = [presets, dbNames];
            app.MechMaterialDrop = uidropdown(app.MechTab, ...
                'Items', allItems, ...
                'Position', [80 620 160 22]);

            app.MechGenerateButton = uibutton(app.MechTab, ...
                'Text', 'Generate Data', 'Position', [250 620 100 22], ...
                'ButtonPushedFcn', @(~,~) generateTestData(app));

            app.MechAnalyzeButton = uibutton(app.MechTab, ...
                'Text', 'Analyze', 'Position', [360 620 80 22], ...
                'ButtonPushedFcn', @(~,~) analyzeTestData(app), ...
                'Enable', 'off');

            app.MechAxes = uiaxes(app.MechTab, ...
                'Position', [50 180 600 420]);

            app.MechResultsArea = uitextarea(app.MechTab, ...
                'Position', [670 30 290 610], 'Editable', 'off', ...
                'FontName', 'Courier New');

            app.MechExportButton = uibutton(app.MechTab, ...
                'Text', 'Export Report', 'Position', [460 620 100 22], ...
                'ButtonPushedFcn', @(~,~) exportMechReport(app), ...
                'Enable', 'off');

            app.MechFitModelsButton = uibutton(app.MechTab, ...
                'Text', 'Fit Models', 'Position', [570 620 80 22], ...
                'ButtonPushedFcn', @(~,~) fitConstitutiveModels(app), ...
                'Enable', 'off');
        end

        function generateTestData(app)
            mat_type = app.MechMaterialDrop.Value;
            [app.CurrentStrain, app.CurrentStress] = mechtest.generate_sample(mat_type);
            plot(app.MechAxes, app.CurrentStrain * 100, app.CurrentStress, 'b-', 'LineWidth', 2);
            xlabel(app.MechAxes, 'Strain (%)');
            ylabel(app.MechAxes, 'Stress (MPa)');
            title(app.MechAxes, sprintf('%s - Stress-Strain Curve', mat_type));
            grid(app.MechAxes, 'on');
            app.MechAnalyzeButton.Enable = 'on';
            app.MechResultsArea.Value = 'Data generated. Click Analyze.';
        end

        function analyzeTestData(app)
            if isempty(app.CurrentStrain), return; end
            results = mechtest.analyze(app.CurrentStrain, app.CurrentStress);

            % Plot with markers
            cla(app.MechAxes);
            hold(app.MechAxes, 'on');
            plot(app.MechAxes, app.CurrentStrain*100, app.CurrentStress, 'b-', 'LineWidth', 2);
            plot(app.MechAxes, results.strain_at_uts*100, results.uts, 'rv', ...
                'MarkerSize', 10, 'MarkerFaceColor', 'r');
            ys_strain = results.yield_strength / (results.youngs_modulus * 1000);
            plot(app.MechAxes, ys_strain*100, results.yield_strength, 'g^', ...
                'MarkerSize', 10, 'MarkerFaceColor', 'g');
            hold(app.MechAxes, 'off');
            xlabel(app.MechAxes, 'Strain (%)');
            ylabel(app.MechAxes, 'Stress (MPa)');
            title(app.MechAxes, 'Analyzed Stress-Strain Curve');
            grid(app.MechAxes, 'on');

            txt = sprintf(['MECHANICAL TEST RESULTS\n' ...
                '========================\n\n' ...
                'Elastic Modulus:    %8.1f GPa\n' ...
                'Yield Strength:    %8.1f MPa\n' ...
                'Ultimate Strength: %8.1f MPa\n' ...
                'Elongation:        %8.1f %%\n' ...
                'Fracture Stress:   %8.1f MPa\n' ...
                'Toughness:         %8.2f MJ/m³\n' ...
                'Resilience:        %8.4f MJ/m³\n' ...
                'Strain at UTS:     %8.4f'], ...
                results.youngs_modulus, results.yield_strength, ...
                results.uts, results.elongation, results.fracture_stress, ...
                results.toughness, results.resilience, results.strain_at_uts);
            app.MechResultsArea.Value = txt;
            app.MechExportButton.Enable = 'on';
            app.MechFitModelsButton.Enable = 'on';
        end

        function exportMechReport(app)
            if isempty(app.CurrentStrain), return; end
            results = mechtest.analyze(app.CurrentStrain, app.CurrentStress);
            mat_type = app.MechMaterialDrop.Value;
            safeName = regexprep(mat_type, '[/\\:*?"<>|]', '_');
            filename = fullfile(tempdir, sprintf('mechtest_report_%s.html', safeName));
            mechtest.generate_report(results, filename, ...
                'Format', 'html', 'SampleName', mat_type);
            web(filename);
        end

        function fitConstitutiveModels(app)
            if isempty(app.CurrentStrain), return; end
            cm = mechtest.constitutive_models(app.CurrentStrain, app.CurrentStress);

            txt = sprintf('CONSTITUTIVE MODEL FITS\n========================\n\n');

            models = {'hollomon', 'ludwik', 'voce', 'swift'};
            labels = {'Hollomon: sigma = K*eps^n', ...
                      'Ludwik: sigma = s0 + K*eps^n', ...
                      'Voce: sigma = ss - (ss-s0)*exp(-th*eps)', ...
                      'Swift: sigma = K*(e0+eps)^n'};

            for i = 1:4
                m = models{i};
                if ~isfield(cm, m), continue; end
                f = cm.(m);
                txt = [txt, sprintf('%s\n', labels{i})];
                if isnan(f.R2)
                    txt = [txt, sprintf('  (fit failed)\n\n')];
                    continue;
                end
                switch m
                    case 'hollomon'
                        txt = [txt, sprintf('  K = %.1f MPa,  n = %.4f\n', f.K, f.n)];
                    case 'ludwik'
                        txt = [txt, sprintf('  s0 = %.1f MPa,  K = %.1f MPa,  n = %.4f\n', f.sigma0, f.K, f.n)];
                    case 'voce'
                        txt = [txt, sprintf('  ss = %.1f MPa,  s0 = %.1f MPa,  th = %.2f\n', f.sigma_s, f.sigma0, f.theta)];
                    case 'swift'
                        txt = [txt, sprintf('  K = %.1f MPa,  e0 = %.5f,  n = %.4f\n', f.K, f.eps0, f.n)];
                end
                txt = [txt, sprintf('  R^2 = %.4f\n\n', f.R2)];
            end

            txt = [txt, sprintf('Best fit: %s\n', cm.best_model)];
            app.MechResultsArea.Value = txt;
        end

        %% ---- PHASE DIAGRAM TAB ----
        function createPhaseTab(app)
            app.PhaseTab = uitab(app.TabGroup, 'Title', 'Phase Diagrams');

            uilabel(app.PhaseTab, 'Text', 'System:', ...
                'Position', [20 620 50 22]);
            app.PhaseSystemDrop = uidropdown(app.PhaseTab, ...
                'Items', {'Cu-Ni', 'Pb-Sn', 'Al-Si', 'Al-Cu', 'Fe-Ni'}, ...
                'Position', [75 620 100 22]);

            app.PhasePlotButton = uibutton(app.PhaseTab, ...
                'Text', 'Plot Diagram', 'Position', [190 620 100 22], ...
                'ButtonPushedFcn', @(~,~) plotPhaseDiagram(app));

            uilabel(app.PhaseTab, 'Text', 'T (°C):', ...
                'Position', [320 620 42 22]);
            app.PhaseTempField = uieditfield(app.PhaseTab, 'numeric', ...
                'Position', [365 620 70 22], 'Value', 1250);

            uilabel(app.PhaseTab, 'Text', 'mol% B:', ...
                'Position', [450 620 45 22]);
            app.PhaseCompField = uieditfield(app.PhaseTab, 'numeric', ...
                'Position', [500 620 50 22], 'Value', 50, ...
                'Limits', [0 100]);

            app.PhaseLeverButton = uibutton(app.PhaseTab, ...
                'Text', 'Lever Rule', 'Position', [560 620 80 22], ...
                'ButtonPushedFcn', @(~,~) calcLever(app));

            app.PhaseAxes = uiaxes(app.PhaseTab, ...
                'Position', [50 80 600 520]);

            app.PhaseLeverArea = uitextarea(app.PhaseTab, ...
                'Position', [670 80 290 560], 'Editable', 'off', ...
                'FontName', 'Courier New');
        end

        function plotPhaseDiagram(app)
            sys = app.PhaseSystemDrop.Value;
            [T_grid, x_grid, phase_map] = phasediag.binary(sys);
            T_display = T_grid - 273.15;

            cla(app.PhaseAxes);
            hold(app.PhaseAxes, 'on');

            liquidus_T = zeros(size(x_grid));
            solidus_T = zeros(size(x_grid));
            for j = 1:numel(x_grid)
                col = phase_map(:, j);
                liq_idx = find(col == 1, 1, 'last');
                sol_idx = find(col == 2, 1, 'last');
                if ~isempty(liq_idx), liquidus_T(j) = T_display(liq_idx);
                else, liquidus_T(j) = T_display(1); end
                if ~isempty(sol_idx), solidus_T(j) = T_display(sol_idx);
                else, solidus_T(j) = T_display(1); end
            end

            plot(app.PhaseAxes, x_grid*100, liquidus_T, 'r-', 'LineWidth', 2);
            plot(app.PhaseAxes, x_grid*100, solidus_T, 'b-', 'LineWidth', 2);
            xlabel(app.PhaseAxes, 'Composition (mol% B)');
            ylabel(app.PhaseAxes, 'Temperature (°C)');
            title(app.PhaseAxes, sprintf('%s Phase Diagram', sys));
            legend(app.PhaseAxes, {'Liquidus', 'Solidus'}, 'Location', 'best');
            grid(app.PhaseAxes, 'on');
            hold(app.PhaseAxes, 'off');

            app.PhaseLeverArea.Value = sprintf('Phase diagram plotted for %s.\nUse Lever Rule to analyze a point.', sys);
        end

        function calcLever(app)
            sys = app.PhaseSystemDrop.Value;
            T_C = app.PhaseTempField.Value;
            T_K = T_C + 273.15;  % convert °C to K for backend
            x0_pct = app.PhaseCompField.Value;
            x0 = x0_pct / 100;  % convert mol% to fraction

            r = phasediag.lever(sys, T_K, x0);

            txt = sprintf(['LEVER RULE ANALYSIS\n' ...
                '=====================\n\n' ...
                'System:      %s\n' ...
                'Temperature: %.1f °C\n' ...
                'Composition: %.1f mol%% B\n\n' ...
                'Phase State: %s\n\n'], ...
                sys, T_C, x0_pct, upper(r.phase));

            if strcmp(r.phase, 'two-phase')
                txt = [txt, sprintf([ ...
                    'Liquid fraction:  %.1f%%\n' ...
                    'Solid fraction:   %.1f%%\n\n' ...
                    'Liquid composition: %.1f mol%% B\n' ...
                    'Solid composition:  %.1f mol%% B\n'], ...
                    r.f_liquid*100, r.f_solid*100, r.x_liquid*100, r.x_solid*100)];
            elseif strcmp(r.phase, 'liquid')
                txt = [txt, sprintf('Fully liquid (above liquidus)\n')];
            else
                txt = [txt, sprintf('Fully solid (below solidus)\n')];
            end

            app.PhaseLeverArea.Value = txt;
        end

        %% ---- MICROSTRUCTURE TAB ----
        function createMicrostructureTab(app)
            app.MicroTab = uitab(app.TabGroup, 'Title', 'Microstructure');

            uilabel(app.MicroTab, 'Text', 'Type:', ...
                'Position', [20 620 35 22]);
            app.MicroTypeDrop = uidropdown(app.MicroTab, ...
                'Items', {'grains', 'porous', 'dual_phase'}, ...
                'Position', [60 620 110 22]);

            uilabel(app.MicroTab, 'Text', 'Grains/Features:', ...
                'Position', [185 620 100 22]);
            app.MicroGrainsSpin = uieditfield(app.MicroTab, 'numeric', ...
                'Position', [290 620 50 22], 'Value', 40);

            app.MicroGenButton = uibutton(app.MicroTab, ...
                'Text', 'Generate', 'Position', [355 620 80 22], ...
                'ButtonPushedFcn', @(~,~) generateMicro(app));

            app.MicroAnalyzeButton = uibutton(app.MicroTab, ...
                'Text', 'Analyze', 'Position', [445 620 70 22], ...
                'ButtonPushedFcn', @(~,~) analyzeMicro(app), ...
                'Enable', 'off');

            app.MicroBatchButton = uibutton(app.MicroTab, ...
                'Text', 'Batch Folder...', 'Position', [530 620 100 22], ...
                'ButtonPushedFcn', @(~,~) batchMicro(app));

            app.MicroClassifyButton = uibutton(app.MicroTab, ...
                'Text', 'Classify', 'Position', [645 620 80 22], ...
                'ButtonPushedFcn', @(~,~) classifyMicro(app), ...
                'Enable', 'off');

            app.MicroAxesImg = uiaxes(app.MicroTab, ...
                'Position', [20 100 480 500]);

            app.MicroResultsArea = uitextarea(app.MicroTab, ...
                'Position', [520 100 440 520], 'Editable', 'off', ...
                'FontName', 'Courier New');
        end

        function generateMicro(app)
            mtype = app.MicroTypeDrop.Value;
            n_grains = app.MicroGrainsSpin.Value;

            if strcmpi(mtype, 'porous')
                [img, meta] = microstructure.generate_synthetic( ...
                    'Type', mtype, 'NumGrains', n_grains, 'Porosity', 0.08);
            else
                [img, meta] = microstructure.generate_synthetic( ...
                    'Type', mtype, 'NumGrains', n_grains);
            end

            app.CurrentMicroImage = img;
            imagesc(app.MicroAxesImg, img);
            colormap(app.MicroAxesImg, gray);
            axis(app.MicroAxesImg, 'image');
            title(app.MicroAxesImg, sprintf('Synthetic: %s (%dx%d)', mtype, meta.size(1), meta.size(2)));

            app.MicroAnalyzeButton.Enable = 'on';
            app.MicroClassifyButton.Enable = 'on';
            app.MicroResultsArea.Value = sprintf('Generated %s image. Click Analyze.', mtype);
        end

        function analyzeMicro(app)
            if isempty(app.CurrentMicroImage), return; end
            img = app.CurrentMicroImage;
            mtype = app.MicroTypeDrop.Value;

            txt = sprintf('MICROSTRUCTURE ANALYSIS\n========================\n\n');

            % Grain size analysis (always)
            gs = microstructure.grainsize(img, 'PixelSize', 1);
            txt = [txt, sprintf(['Grain Size (Linear Intercept):\n' ...
                '  Mean Intercept:    %.1f um\n' ...
                '  Std Dev:           %.1f um\n' ...
                '  Grain Count:       %d\n' ...
                '  ASTM Grain #:      %.1f\n\n'], ...
                gs.mean_intercept, gs.std_intercept, gs.grain_count, gs.astm_grain_number)];

            % Porosity (especially for porous)
            por = microstructure.porosity(img);
            txt = [txt, sprintf(['Porosity Analysis:\n' ...
                '  Porosity:          %.2f %%\n' ...
                '  Number of Pores:   %d\n' ...
                '  Mean Pore Area:    %.1f px\n\n'], ...
                por.porosity_percent, por.num_pores, por.mean_pore_area)];

            % Phase fraction
            n_ph = 2;
            pf = microstructure.phase_fraction(img, 'NumPhases', n_ph);
            txt = [txt, sprintf('Phase Fraction (%d phases):\n', n_ph)];
            for k = 1:n_ph
                txt = [txt, sprintf('  Phase %d:           %.1f %%\n', k, pf.fractions_percent(k))]; %#ok<AGROW>
            end

            app.MicroResultsArea.Value = txt;
        end

        function batchMicro(app)
            folder = uigetdir('', 'Select folder of micrograph images');
            if isequal(folder, 0), return; end

            % Find image files
            exts = {'*.png','*.jpg','*.jpeg','*.tif','*.tiff','*.bmp'};
            files = {};
            for e = 1:numel(exts)
                d = dir(fullfile(folder, exts{e}));
                for f = 1:numel(d)
                    files{end+1} = fullfile(folder, d(f).name); %#ok<AGROW>
                end
            end

            if isempty(files)
                app.MicroResultsArea.Value = 'No image files found in selected folder.';
                return;
            end

            n_batch = numel(files);
            app.MicroResultsArea.Value = sprintf('Analyzing %d images from:\n%s', n_batch, folder);
            drawnow;

            results = microstructure.batch_process(files, ...
                'Analyses', {'grainsize', 'porosity'}, 'ShowProgress', false);
            s = results.summary;

            txt = sprintf('BATCH ANALYSIS (%d images)\n', n_batch);
            txt = [txt, sprintf('================================\n')];
            txt = [txt, sprintf('Folder: %s\n\n', folder)];

            if isfield(s, 'mean_grain_size')
                txt = [txt, sprintf(['Grain Size (averaged across %d fields of view):\n' ...
                    '  Mean Grain Size:   %.1f um\n' ...
                    '  Std Dev:           %.1f um\n' ...
                    '  Mean ASTM #:       %.1f\n\n'], ...
                    n_batch, s.mean_grain_size, s.std_grain_size, s.mean_astm_number)];
            end

            if isfield(s, 'mean_porosity')
                txt = [txt, sprintf(['Porosity (averaged across %d fields of view):\n' ...
                    '  Mean Porosity:     %.2f %%\n' ...
                    '  Std Dev:           %.2f %%\n\n'], ...
                    n_batch, s.mean_porosity, s.std_porosity)];
            end

            txt = [txt, sprintf('--- Per-Image Details ---\n')];
            for i = 1:n_batch
                [~, fname, fext] = fileparts(files{i});
                r = results.individual{i};
                if isfield(r, 'error')
                    txt = [txt, sprintf('%s%s: ERROR - %s\n', fname, fext, r.error)]; %#ok<AGROW>
                else
                    line = sprintf('%s%s:', fname, fext);
                    if isfield(r, 'grainsize')
                        line = [line, sprintf(' grain=%.1f um', r.grainsize.mean_intercept)];
                    end
                    if isfield(r, 'porosity')
                        line = [line, sprintf(' pore=%.2f%%', r.porosity.porosity_percent)];
                    end
                    txt = [txt, line, sprintf('\n')]; %#ok<AGROW>
                end
            end

            app.MicroResultsArea.Value = txt;

            % Show first successfully loaded image
            for i = 1:n_batch
                if ~isfield(results.individual{i}, 'error')
                    img = imread(files{i});
                    if size(img, 3) == 3
                        img = rgb2gray(img);
                    end
                    app.CurrentMicroImage = img;
                    imagesc(app.MicroAxesImg, img);
                    colormap(app.MicroAxesImg, gray);
                    axis(app.MicroAxesImg, 'image');
                    [~, fn, fe] = fileparts(files{i});
                    title(app.MicroAxesImg, sprintf('%s%s (1 of %d)', fn, fe, n_batch));
                    break;
                end
            end
        end

        function classifyMicro(app)
            if isempty(app.CurrentMicroImage), return; end
            result = intelligence.classify_microstructure(app.CurrentMicroImage);

            txt = sprintf('MICROSTRUCTURE CLASSIFICATION\n');
            txt = [txt, sprintf('==============================\n\n')];
            txt = [txt, sprintf('Prediction:  %s\n', upper(result.prediction))];
            txt = [txt, sprintf('Confidence:  %.1f%%\n\n', result.confidence * 100)];
            txt = [txt, sprintf('--- Class Probabilities ---\n')];
            txt = [txt, sprintf('  Grains:     %.1f%%\n', result.probabilities.grains * 100)];
            txt = [txt, sprintf('  Porous:     %.1f%%\n', result.probabilities.porous * 100)];
            txt = [txt, sprintf('  Dual Phase: %.1f%%\n\n', result.probabilities.dual_phase * 100)];
            txt = [txt, sprintf('--- Features ---\n')];
            feat = result.features;
            txt = [txt, sprintf('  Mean intensity:  %.4f\n', feat.mean_intensity)];
            txt = [txt, sprintf('  Std intensity:   %.4f\n', feat.std_intensity)];
            txt = [txt, sprintf('  Skewness:        %.4f\n', feat.skewness)];
            txt = [txt, sprintf('  Kurtosis:        %.4f\n', feat.kurtosis)];
            txt = [txt, sprintf('  Edge density:    %.4f\n', feat.edge_density)];
            txt = [txt, sprintf('  Dark regions:    %.4f\n', feat.dark_region_count)];
            txt = [txt, sprintf('  Bimodality:      %.4f\n', feat.bimodality)];
            txt = [txt, sprintf('  Contrast:        %.4f\n', feat.contrast)];

            app.MicroResultsArea.Value = txt;
        end

        %% ---- INTELLIGENCE TAB ----
        function createIntelligenceTab(app)
            app.IntelTab = uitab(app.TabGroup, 'Title', 'Intelligence');

            % --- Property Prediction section ---
            uilabel(app.IntelTab, 'Text', 'PROPERTY PREDICTION', ...
                'Position', [20 620 200 22], 'FontWeight', 'bold');

            uilabel(app.IntelTab, 'Text', 'Material:', ...
                'Position', [20 592 55 22]);
            app.IntelMaterialField = uieditfield(app.IntelTab, ...
                'Position', [80 592 160 22], 'Value', 'Al 6061-T6');

            app.IntelPredictButton = uibutton(app.IntelTab, ...
                'Text', 'Predict', 'Position', [250 592 70 22], ...
                'ButtonPushedFcn', @(~,~) runPrediction(app));

            app.IntelResultsArea = uitextarea(app.IntelTab, ...
                'Position', [20 410 300 175], 'Editable', 'off', ...
                'FontName', 'Courier New');

            % --- Material Recommendation section ---
            uilabel(app.IntelTab, 'Text', 'MATERIAL RECOMMENDATION', ...
                'Position', [20 380 220 22], 'FontWeight', 'bold');

            uilabel(app.IntelTab, 'Text', 'Max Density (kg/m³):', ...
                'Position', [20 352 130 22]);
            app.IntelRecDensMax = uieditfield(app.IntelTab, 'numeric', ...
                'Position', [155 352 70 22], 'Value', 5000);

            uilabel(app.IntelTab, 'Text', 'Min Yield (MPa):', ...
                'Position', [20 324 110 22]);
            app.IntelRecYSMin = uieditfield(app.IntelTab, 'numeric', ...
                'Position', [155 324 70 22], 'Value', 200);

            app.IntelRecButton = uibutton(app.IntelTab, ...
                'Text', 'Recommend', 'Position', [240 338 80 22], ...
                'ButtonPushedFcn', @(~,~) runRecommendation(app));

            app.IntelRecTable = uitable(app.IntelTab, ...
                'Position', [20 80 620 235]);

            % --- Surrogate Model section ---
            uilabel(app.IntelTab, 'Text', 'SURROGATE MODEL', ...
                'Position', [670 620 180 22], 'FontWeight', 'bold');

            app.IntelSurrogateBtn = uibutton(app.IntelTab, ...
                'Text', 'Build Model (density+E -> yield)', ...
                'Position', [670 592 260 22], ...
                'ButtonPushedFcn', @(~,~) buildSurrogate(app));

            app.IntelAnomalyBtn = uibutton(app.IntelTab, ...
                'Text', 'Anomaly Detection', ...
                'Position', [670 562 260 22], ...
                'ButtonPushedFcn', @(~,~) runAnomalyDetection(app));

            app.IntelImportanceBtn = uibutton(app.IntelTab, ...
                'Text', 'Feature Importance', ...
                'Position', [670 532 260 22], ...
                'ButtonPushedFcn', @(~,~) runFeatureImportance(app));

            app.IntelClusterBtn = uibutton(app.IntelTab, ...
                'Text', 'Cluster Materials', ...
                'Position', [670 502 260 22], ...
                'ButtonPushedFcn', @(~,~) runClustering(app));

            app.IntelSurrogateArea = uitextarea(app.IntelTab, ...
                'Position', [670 80 290 410], 'Editable', 'off', ...
                'FontName', 'Courier New');
        end

        function runPrediction(app)
            name = app.IntelMaterialField.Value;
            try
                pred = intelligence.predict_properties(name, 'K', 3);
                txt = sprintf(['PROPERTY PREDICTION\n' ...
                    '=====================\n\n' ...
                    'Material: %s\n\n' ...
                    'Nearest Neighbors:\n'], name);
                for i = 1:numel(pred.nearest_materials)
                    txt = [txt, sprintf('  %d. %s (d=%.3f)\n', ...
                        i, pred.nearest_materials{i}, pred.distances(i))]; %#ok<AGROW>
                end
                txt = [txt, sprintf(['\nPredicted Properties:\n' ...
                    '  Density:         %8.0f kg/m³\n' ...
                    '  Young''s Modulus: %8.1f GPa\n' ...
                    '  Yield Strength:  %8.0f MPa\n' ...
                    '  UTS:             %8.0f MPa\n' ...
                    '  Therm. Cond.:    %8.1f W/(m·K)\n' ...
                    '  Melting Point:   %8.0f °C\n'], ...
                    pred.density, pred.youngs_modulus, ...
                    pred.yield_strength, pred.uts, ...
                    pred.thermal_conductivity, pred.melting_point)];
                app.IntelResultsArea.Value = txt;
            catch ex
                app.IntelResultsArea.Value = sprintf('Error: %s', ex.message);
            end
        end

        function runRecommendation(app)
            req.constraints.density = [0 app.IntelRecDensMax.Value];
            req.constraints.yield_strength = [app.IntelRecYSMin.Value Inf];
            req.objectives(1) = struct('property','yield_strength','goal','max','weight',0.5);
            req.objectives(2) = struct('property','density','goal','min','weight',0.3);
            req.objectives(3) = struct('property','cost','goal','min','weight',0.2);
            T = intelligence.recommend(req, 'TopN', 10);
            if height(T) > 0
                app.IntelRecTable.Data = T;
                app.IntelRecTable.ColumnName = T.Properties.VariableNames;
            else
                app.IntelRecTable.Data = {};
            end
        end

        function buildSurrogate(app)
            try
                model = intelligence.surrogate_model( ...
                    {'density', 'youngs_modulus'}, 'yield_strength');

                txt = sprintf(['SURROGATE MODEL\n' ...
                    '=================\n\n' ...
                    'Inputs:  density, youngs_modulus\n' ...
                    'Output:  yield_strength\n' ...
                    'Degree:  %d\n' ...
                    'Samples: %d\n\n' ...
                    'R²:      %.4f\n' ...
                    'RMSE:    %.1f MPa\n' ...
                    'CV-RMSE: %.1f MPa\n\n' ...
                    'Example Predictions:\n'], ...
                    model.degree, model.n_samples, ...
                    model.r_squared, model.rmse, model.cv_rmse);

                test_cases = [2700 70; 7850 200; 4430 114; 1600 181];
                test_labels = {'Al-like', 'Steel-like', 'Ti-like', 'CFRP-like'};
                for i = 1:size(test_cases, 1)
                    y = model.predict(test_cases(i,:));
                    txt = [txt, sprintf('  %s (rho=%.0f, E=%.0f): %.0f MPa\n', ...
                        test_labels{i}, test_cases(i,1), test_cases(i,2), y)]; %#ok<AGROW>
                end

                app.IntelSurrogateArea.Value = txt;
            catch ex
                app.IntelSurrogateArea.Value = sprintf('Error: %s', ex.message);
            end
        end

        function runAnomalyDetection(app)
            try
                results = intelligence.anomaly_detection();
                txt = sprintf('ANOMALY DETECTION\n===================\n\n');
                txt = [txt, sprintf('Threshold: %.1f (Mahalanobis distance)\n', results.threshold)];
                txt = [txt, sprintf('Anomalies found: %d / %d\n\n', results.n_anomalies, numel(results.materials))];
                if results.n_anomalies > 0
                    txt = [txt, sprintf('--- Anomalous Materials ---\n')];
                    T = results.anomalies;
                    for i = 1:height(T)
                        txt = [txt, sprintf('  %s (%s): %.2f\n', T.Name{i}, T.Category{i}, T.MahalanobisDistance(i))]; %#ok<AGROW>
                    end
                else
                    txt = [txt, sprintf('No anomalies detected.\n')];
                end
                txt = [txt, sprintf('\n--- Top 10 Most Unusual ---\n')];
                T = results.rankings;
                for i = 1:min(10, height(T))
                    txt = [txt, sprintf('  %2d. %-20s %.2f\n', i, T.Name{i}, T.MahalanobisDistance(i))]; %#ok<AGROW>
                end
                app.IntelSurrogateArea.Value = txt;
            catch ex
                app.IntelSurrogateArea.Value = sprintf('Error: %s', ex.message);
            end
        end

        function runFeatureImportance(app)
            try
                results = intelligence.feature_importance('yield_strength', 'Method', 'both');
                txt = sprintf('FEATURE IMPORTANCE\n====================\n\n');
                txt = [txt, sprintf('Target: %s\n', results.target)];
                txt = [txt, sprintf('Samples: %d\n', results.n_samples)];
                txt = [txt, sprintf('Method: %s\n\n', results.method)];
                txt = [txt, sprintf('--- Ranked Features ---\n')];
                T = results.ranking;
                for i = 1:height(T)
                    txt = [txt, sprintf('  %2d. %-22s %.4f\n', i, T.Feature{i}, T.CombinedScore(i))]; %#ok<AGROW>
                end
                txt = [txt, sprintf('\n--- Correlation Scores ---\n')];
                T2 = results.correlation_ranking;
                for i = 1:height(T2)
                    txt = [txt, sprintf('  %-22s |r| = %.4f\n', T2.Feature{i}, T2.AbsCorrelation(i))]; %#ok<AGROW>
                end
                app.IntelSurrogateArea.Value = txt;
            catch ex
                app.IntelSurrogateArea.Value = sprintf('Error: %s', ex.message);
            end
        end

        function runClustering(app)
            try
                results = intelligence.cluster_materials('K', 4);
                txt = sprintf('MATERIAL CLUSTERING\n=====================\n\n');
                txt = [txt, sprintf('Clusters: %d\n', results.n_clusters)];
                txt = [txt, sprintf('Silhouette: %.3f\n\n', results.silhouette)];
                for k = 1:results.n_clusters
                    s = results.cluster_summary{k};
                    txt = [txt, sprintf('--- Cluster %d (%d materials) ---\n', k, s.size)];
                    txt = [txt, sprintf('  Types: %s\n', strjoin(s.categories, ', '))];
                    for m = 1:min(5, numel(s.materials))
                        txt = [txt, sprintf('  - %s\n', s.materials{m})]; %#ok<AGROW>
                    end
                    if numel(s.materials) > 5
                        txt = [txt, sprintf('  ... and %d more\n', numel(s.materials) - 5)];
                    end
                    txt = [txt, sprintf('\n')]; %#ok<AGROW>
                end
                app.IntelSurrogateArea.Value = txt;
            catch ex
                app.IntelSurrogateArea.Value = sprintf('Error: %s', ex.message);
            end
        end

        %% ---- XRD TAB ----
        function createXRDTab(app)
            app.XrdTab = uitab(app.TabGroup, 'Title', 'XRD Analysis');

            uilabel(app.XrdTab, 'Text', 'Material:', ...
                'Position', [20 620 55 22]);
            app.XrdMaterialDrop = uidropdown(app.XrdTab, ...
                'Items', {'Aluminum (FCC)', 'Iron (BCC)', 'Austenite (FCC)', ...
                    'Titanium (HCP)', 'Copper (FCC)', 'Nickel (FCC)', ...
                    'Chromium (BCC)', 'Silicon (Diamond)', 'ZnO (Wurtzite)', ...
                    'NaCl (Rock Salt)', 'Dual Phase (BCC+FCC)'}, ...
                'ItemsData', {'fcc_al', 'bcc_fe', 'fcc_austenite', ...
                    'hcp_ti', 'fcc_cu', 'fcc_ni', ...
                    'bcc_cr', 'diamond_si', 'wurtzite_zno', ...
                    'rocksalt_nacl', 'dual_phase'}, ...
                'Position', [80 620 155 22]);

            uilabel(app.XrdTab, 'Text', 'Profile:', ...
                'Position', [250 620 45 22]);
            app.XrdProfileDrop = uidropdown(app.XrdTab, ...
                'Items', {'Pseudo-Voigt', 'Gaussian', 'Lorentzian'}, ...
                'ItemsData', {'pseudo_voigt', 'gaussian', 'lorentzian'}, ...
                'Position', [300 620 115 22]);

            uilabel(app.XrdTab, 'Text', 'Sensitivity:', ...
                'Position', [430 620 65 22]);
            app.XrdSensitivitySpin = uieditfield(app.XrdTab, 'numeric', ...
                'Position', [500 620 45 22], 'Value', 10, ...
                'Limits', [1 50], 'RoundFractionalValues', 'on', ...
                'Tooltip', 'Min peak height as % of max intensity');

            app.XrdGenButton = uibutton(app.XrdTab, ...
                'Text', 'Generate Pattern', 'Position', [560 620 120 22], ...
                'ButtonPushedFcn', @(~,~) generateXRD(app));

            app.XrdAnalyzeButton = uibutton(app.XrdTab, ...
                'Text', 'Full Analysis', 'Position', [690 620 90 22], ...
                'ButtonPushedFcn', @(~,~) analyzeXRD(app), ...
                'Enable', 'off');

            app.XrdExportButton = uibutton(app.XrdTab, ...
                'Text', 'Export CSV', 'Position', [790 620 80 22], ...
                'ButtonPushedFcn', @(~,~) exportXRD(app), ...
                'Enable', 'off');

            app.XrdAxes = uiaxes(app.XrdTab, ...
                'Position', [50 100 600 500]);

            app.XrdResultsArea = uitextarea(app.XrdTab, ...
                'Position', [670 100 290 520], 'Editable', 'off', ...
                'FontName', 'Courier New');
        end

        function generateXRD(app)
            mat = app.XrdMaterialDrop.Value;
            matLabel = app.XrdMaterialDrop.Items{strcmp(app.XrdMaterialDrop.ItemsData, mat)};
            [tt, int, meta] = xrd.generate_pattern('Material', mat);
            app.CurrentTwoTheta = tt;
            app.CurrentIntensity = int;

            cla(app.XrdAxes, 'reset');
            hold(app.XrdAxes, 'on');
            plot(app.XrdAxes, tt, int, 'b-', 'LineWidth', 1.2, 'HandleVisibility', 'off');

            % Mark known peak positions with Miller index labels
            for pi = 1:numel(meta.peak_positions)
                pos = meta.peak_positions(pi);
                idx = find(tt >= pos, 1, 'first');
                if ~isempty(idx)
                    plot(app.XrdAxes, pos, int(idx), 'rv', ...
                        'MarkerSize', 8, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
                    text(app.XrdAxes, pos, int(idx) + max(int)*0.04, ...
                        sprintf('(%s)', meta.peak_hkl{pi}), ...
                        'HorizontalAlignment', 'center', 'FontSize', 11, ...
                        'FontWeight', 'bold', 'Color', [0.7 0 0]);
                end
            end
            hold(app.XrdAxes, 'off');
            legend(app.XrdAxes, 'off');

            xlabel(app.XrdAxes, '2\theta (degrees)');
            ylabel(app.XrdAxes, 'Intensity (a.u.)');
            title(app.XrdAxes, sprintf('XRD Pattern: %s', matLabel));
            ylim(app.XrdAxes, [0 max(int)*1.15]);
            grid(app.XrdAxes, 'on');

            app.XrdAnalyzeButton.Enable = 'on';
            app.XrdResultsArea.Value = sprintf(['Generated %s pattern (%d points).\n' ...
                'Known peaks: %d reflections\n\nClick "Full Analysis" for:\n' ...
                '  - Background subtraction\n  - Peak finding & fitting\n' ...
                '  - Crystallite size analysis'], ...
                matLabel, numel(tt), numel(meta.peak_positions));
        end

        function analyzeXRD(app)
            if isempty(app.CurrentTwoTheta), return; end
            tt = app.CurrentTwoTheta;
            int = app.CurrentIntensity;
            profileType = app.XrdProfileDrop.Value;
            mat = app.XrdMaterialDrop.Value;
            matLabel = app.XrdMaterialDrop.Items{strcmp(app.XrdMaterialDrop.ItemsData, mat)};

            % Background subtraction
            [~, corrected, bg] = xrd.subtract_background(tt, int);

            % Peak detection with user-tunable sensitivity
            minHt = app.XrdSensitivitySpin.Value / 100;
            peaks = xrd.find_peaks(tt, corrected, ...
                'MinHeight', minHt, 'MinProminence', minHt * 0.5, 'MinDistance', 1.5);

            % Peak fitting with selected profile
            fits = xrd.fit_peaks(tt, corrected, peaks.positions, 'Profile', profileType);

            % --- Plot ---
            cla(app.XrdAxes, 'reset');
            hold(app.XrdAxes, 'on');
            plot(app.XrdAxes, tt, int, '-', 'Color', [0.7 0.7 0.7], ...
                'LineWidth', 0.5, 'DisplayName', 'Raw');
            plot(app.XrdAxes, tt, bg, 'r--', 'LineWidth', 1, 'DisplayName', 'Background');
            plot(app.XrdAxes, tt, corrected, 'b-', 'LineWidth', 1, 'DisplayName', 'Corrected');

            % Overlay fitted profiles (single legend entry)
            fitColor = [0.8 0.4 0.0];
            for i = 1:numel(fits)
                f = fits{i};
                if ~isnan(f.R2)
                    h = plot(app.XrdAxes, f.two_theta, f.fitted, '-', ...
                        'Color', fitColor, 'LineWidth', 1.5);
                    if i > 1
                        h.HandleVisibility = 'off';
                    else
                        h.DisplayName = sprintf('Fitted (%s)', strrep(profileType,'_','-'));
                    end
                end
            end

            plot(app.XrdAxes, peaks.positions, peaks.intensities, 'kv', ...
                'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.8 0.2], 'DisplayName', 'Peaks');

            % Label detected peaks with Miller indices or 2-theta
            [~, ~, meta] = xrd.generate_pattern('Material', mat);
            for pi = 1:peaks.count
                lbl = '';
                for mi = 1:numel(meta.peak_positions)
                    if abs(peaks.positions(pi) - meta.peak_positions(mi)) < 1.5
                        lbl = sprintf('(%s)', meta.peak_hkl{mi});
                        break;
                    end
                end
                if isempty(lbl)
                    lbl = sprintf('%.1f°', peaks.positions(pi));
                end
                text(app.XrdAxes, peaks.positions(pi), ...
                    peaks.intensities(pi) + max(int)*0.04, lbl, ...
                    'HorizontalAlignment', 'center', 'FontSize', 10, ...
                    'FontWeight', 'bold', 'Color', [0 0.5 0]);
            end
            hold(app.XrdAxes, 'off');
            xlabel(app.XrdAxes, '2\theta (degrees)');
            ylabel(app.XrdAxes, 'Intensity (a.u.)');
            title(app.XrdAxes, sprintf('XRD Analysis: %s (%s fit)', matLabel, strrep(profileType, '_', '-')));
            ylim(app.XrdAxes, [0 max(int)*1.15]);
            legend(app.XrdAxes, 'Location', 'best');
            grid(app.XrdAxes, 'on');

            % --- Build results text ---
            profileLabel = strrep(profileType, '_', '-');
            txt = sprintf('XRD FULL ANALYSIS\n');
            txt = [txt, sprintf('=====================\n')];
            txt = [txt, sprintf('Material: %s\n', matLabel)];
            txt = [txt, sprintf('Profile:  %s\n', profileLabel)];
            txt = [txt, sprintf('Peaks found: %d\n\n', peaks.count)];

            txt = [txt, sprintf('--- BACKGROUND SUBTRACTION ---\n')];
            txt = [txt, sprintf('Method: iterative polynomial\n')];
            txt = [txt, sprintf('Max background: %.1f\n', max(bg))];
            txt = [txt, sprintf('Mean background: %.1f\n\n', mean(bg))];

            txt = [txt, sprintf('--- PEAK FITTING (%s) ---\n\n', profileLabel)];

            fwhms = zeros(peaks.count, 1);
            centers = zeros(peaks.count, 1);

            for i = 1:numel(fits)
                f = fits{i};
                d = xrd.bragg(f.center);
                txt = [txt, sprintf('Peak %d:\n', i)]; %#ok<AGROW>
                txt = [txt, sprintf('  2theta  = %7.2f deg\n', f.center)]; %#ok<AGROW>
                txt = [txt, sprintf('  d-space = %7.4f A\n', d)]; %#ok<AGROW>
                txt = [txt, sprintf('  FWHM    = %7.4f deg\n', f.fwhm)]; %#ok<AGROW>
                txt = [txt, sprintf('  Height  = %7.1f\n', f.height)]; %#ok<AGROW>
                txt = [txt, sprintf('  Area    = %7.1f\n', f.area)]; %#ok<AGROW>
                txt = [txt, sprintf('  R^2     = %7.4f\n\n', f.R2)]; %#ok<AGROW>
                fwhms(i) = f.fwhm;
                centers(i) = f.center;
            end

            % Crystallite size analysis
            txt = [txt, sprintf('--- CRYSTALLITE SIZE ---\n\n')];

            % Scherrer for each peak
            sc = xrd.crystallite_size(fwhms, centers);
            txt = [txt, sprintf('Scherrer Analysis (per peak):\n')];
            for i = 1:numel(sc.crystallite_size_nm)
                txt = [txt, sprintf('  Peak %d (%.1f deg): %.1f nm\n', ...
                    i, centers(i), sc.crystallite_size_nm(i))]; %#ok<AGROW>
            end
            txt = [txt, sprintf('  Mean crystallite size: %.1f nm\n\n', ...
                mean(sc.crystallite_size_nm))];

            % Williamson-Hall if enough peaks
            if peaks.count >= 3
                wh = xrd.crystallite_size(fwhms, centers, 'Method', 'williamson_hall');
                txt = [txt, sprintf('Williamson-Hall Analysis:\n')];
                txt = [txt, sprintf('  Crystallite size: %.1f nm\n', wh.crystallite_size_nm)];
                txt = [txt, sprintf('  Microstrain:      %.6f\n', wh.microstrain)];
                txt = [txt, sprintf('  R^2:              %.4f\n', wh.R2)];
            else
                txt = [txt, sprintf('Williamson-Hall: need >= 3 peaks\n')];
            end

            app.XrdResultsArea.Value = txt;
            app.XrdExportButton.Enable = 'on';
        end

        function exportXRD(app)
            if isempty(app.CurrentTwoTheta), return; end
            matLabel = app.XrdMaterialDrop.Items{strcmp(app.XrdMaterialDrop.ItemsData, app.XrdMaterialDrop.Value)};
            safeName = regexprep(matLabel, '[/\\:*?"<>| ]', '_');
            filename = fullfile(tempdir, sprintf('xrd_data_%s.csv', safeName));
            T = table(app.CurrentTwoTheta, app.CurrentIntensity, ...
                'VariableNames', {'TwoTheta_deg', 'Intensity_au'});
            writetable(T, filename);
            uialert(app.UIFigure, sprintf('Data exported to:\n%s', filename), ...
                'Export Complete', 'Icon', 'success');
        end
    end
end
