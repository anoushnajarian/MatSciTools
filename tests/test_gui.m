classdef test_gui < matlab.unittest.TestCase
%TEST_GUI Unit tests for the GUI application

    properties
        App
    end

    methods (TestMethodSetup)
        function launchApp(testCase)
            testCase.App = gui.MatSciApp();
            testCase.addTeardown(@() delete(testCase.App));
        end
    end

    methods (Test)
        function testAppCreates(testCase)
            testCase.verifyClass(testCase.App, 'gui.MatSciApp');
        end

        function testFigureExists(testCase)
            fig = testCase.App.UIFigure;
            testCase.verifyTrue(isvalid(fig));
            testCase.verifyEqual(fig.Name, 'MatSciTools v0.10');
        end

        function testHasSixTabs(testCase)
            tabs = testCase.App.TabGroup.Children;
            testCase.verifyGreaterThanOrEqual(numel(tabs), 7);
        end

        function testTabTitles(testCase)
            tabs = testCase.App.TabGroup.Children;
            titles = arrayfun(@(t) t.Title, tabs, 'UniformOutput', false);
            testCase.verifyTrue(any(strcmp(titles, 'Material Database')));
            testCase.verifyTrue(any(strcmp(titles, 'Material Selection')));
            testCase.verifyTrue(any(strcmp(titles, 'Mechanical Testing')));
            testCase.verifyTrue(any(strcmp(titles, 'Phase Diagrams')));
            testCase.verifyTrue(any(strcmp(titles, 'Microstructure')));
            testCase.verifyTrue(any(strcmp(titles, 'Intelligence')));
            testCase.verifyTrue(any(strcmp(titles, 'XRD Analysis')));
        end

        function testDatabaseTableLoaded(testCase)
            % Database table should be populated on launch
            data = testCase.App.DbTable.Data;
            testCase.verifyGreaterThan(height(data), 50);
        end

        function testDatabaseCategoryFilter(testCase)
            testCase.App.DbCategoryDropdown.Value = 'Metal';
            % Trigger callback directly
            testCase.App.DbCategoryDropdown.ValueChangedFcn([], []);
            drawnow;
            data = testCase.App.DbTable.Data;
            testCase.verifyGreaterThan(height(data), 0);
            testCase.verifyTrue(all(strcmp(data.Category, 'Metal')));
        end

        function testMechtestGenerate(testCase)
            testCase.App.MechMaterialDrop.Value = 'steel';
            % Simulate button press by calling internal method via the callback
            testCase.App.MechGenerateButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.verifyTrue(testCase.App.MechAnalyzeButton.Enable);
            testCase.verifyFalse(isempty(testCase.App.CurrentStrain));
        end

        function testMechtestAnalyze(testCase)
            testCase.App.MechMaterialDrop.Value = 'aluminum';
            testCase.App.MechGenerateButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.App.MechAnalyzeButton.ButtonPushedFcn([], []);
            drawnow;
            txt = testCase.App.MechResultsArea.Value;
            testCase.verifyTrue(contains(strjoin(txt), 'Elastic Modulus'));
        end

        function testMicrostructureGenerate(testCase)
            testCase.App.MicroTypeDrop.Value = 'grains';
            testCase.App.MicroGrainsSpin.Value = 20;
            testCase.App.MicroGenButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.verifyFalse(isempty(testCase.App.CurrentMicroImage));
            testCase.verifyTrue(testCase.App.MicroAnalyzeButton.Enable);
        end

        function testMicrostructureAnalyze(testCase)
            testCase.App.MicroTypeDrop.Value = 'porous';
            testCase.App.MicroGenButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.App.MicroAnalyzeButton.ButtonPushedFcn([], []);
            drawnow;
            txt = testCase.App.MicroResultsArea.Value;
            testCase.verifyTrue(contains(strjoin(txt), 'Porosity'));
        end

        function testIntelligencePredict(testCase)
            testCase.App.IntelMaterialField.Value = 'Ti-6Al-4V';
            testCase.App.IntelPredictButton.ButtonPushedFcn([], []);
            drawnow;
            txt = testCase.App.IntelResultsArea.Value;
            testCase.verifyTrue(contains(strjoin(txt), 'Predicted Properties'));
        end

        function testIntelligenceRecommend(testCase)
            testCase.App.IntelRecDensMax.Value = 5000;
            testCase.App.IntelRecYSMin.Value = 200;
            testCase.App.IntelRecButton.ButtonPushedFcn([], []);
            drawnow;
            data = testCase.App.IntelRecTable.Data;
            testCase.verifyGreaterThan(height(data), 0);
        end

        function testIntelligenceSurrogate(testCase)
            testCase.App.IntelSurrogateBtn.ButtonPushedFcn([], []);
            drawnow;
            txt = testCase.App.IntelSurrogateArea.Value;
            testCase.verifyTrue(contains(strjoin(txt), 'SURROGATE MODEL'));
        end

        function testCostEstimation(testCase)
            testCase.App.SelCostMaterialField.Value = 'AISI 1045';
            testCase.App.SelCostVolumeField.Value = 0.001;
            testCase.App.SelCostButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.verifyTrue(contains(testCase.App.SelCostLabel.Text, 'Mass:'));
        end

        function testMicroBatchButtonExists(testCase)
            testCase.verifyTrue(isvalid(testCase.App.MicroBatchButton));
            testCase.verifyEqual(testCase.App.MicroBatchButton.Text, 'Batch Folder...');
        end

        function testXrdGenerate(testCase)
            testCase.App.XrdMaterialDrop.Value = 'fcc_al';
            testCase.App.XrdGenButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.verifyFalse(isempty(testCase.App.CurrentTwoTheta));
            testCase.verifyFalse(isempty(testCase.App.CurrentIntensity));
            testCase.verifyTrue(testCase.App.XrdAnalyzeButton.Enable);
        end

        function testXrdAnalyze(testCase)
            testCase.App.XrdMaterialDrop.Value = 'fcc_al';
            testCase.App.XrdProfileDrop.Value = 'pseudo_voigt';
            testCase.App.XrdGenButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.App.XrdAnalyzeButton.ButtonPushedFcn([], []);
            drawnow;
            txt = testCase.App.XrdResultsArea.Value;
            testCase.verifyTrue(contains(strjoin(txt), 'PEAK FITTING'));
            testCase.verifyTrue(contains(strjoin(txt), 'CRYSTALLITE SIZE'));
        end

        function testXrdProfileSelector(testCase)
            testCase.App.XrdMaterialDrop.Value = 'bcc_fe';
            testCase.App.XrdProfileDrop.Value = 'gaussian';
            testCase.App.XrdGenButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.App.XrdAnalyzeButton.ButtonPushedFcn([], []);
            drawnow;
            txt = strjoin(testCase.App.XrdResultsArea.Value);
            testCase.verifyTrue(contains(txt, 'gaussian'));
        end

        function testXrdSensitivity(testCase)
            testCase.verifyTrue(isvalid(testCase.App.XrdSensitivitySpin));
            testCase.verifyEqual(testCase.App.XrdSensitivitySpin.Value, 10);
        end

        function testMicroClassifyButton(testCase)
            testCase.App.MicroTypeDrop.Value = 'grains';
            testCase.App.MicroGrainsSpin.Value = 20;
            testCase.App.MicroGenButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.verifyTrue(testCase.App.MicroClassifyButton.Enable);
            testCase.App.MicroClassifyButton.ButtonPushedFcn([], []);
            drawnow;
            txt = testCase.App.MicroResultsArea.Value;
            testCase.verifyTrue(contains(strjoin(txt), 'CLASSIFICATION'));
        end

        function testMicroClassifyPorous(testCase)
            testCase.App.MicroTypeDrop.Value = 'porous';
            testCase.App.MicroGenButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.App.MicroClassifyButton.ButtonPushedFcn([], []);
            drawnow;
            txt = strjoin(testCase.App.MicroResultsArea.Value);
            testCase.verifyTrue(contains(txt, 'Probabilities'));
        end

        function testXrdExportButton(testCase)
            testCase.verifyTrue(isvalid(testCase.App.XrdExportButton));
            testCase.verifyFalse(testCase.App.XrdExportButton.Enable);
        end

        function testXrdExportAfterAnalysis(testCase)
            testCase.App.XrdMaterialDrop.Value = 'fcc_al';
            testCase.App.XrdProfileDrop.Value = 'pseudo_voigt';
            testCase.App.XrdGenButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.App.XrdAnalyzeButton.ButtonPushedFcn([], []);
            drawnow;
            testCase.verifyTrue(testCase.App.XrdExportButton.Enable);
        end

        function testXrdTabOrder(testCase)
            tabs = testCase.App.TabGroup.Children;
            titles = arrayfun(@(t) t.Title, tabs, 'UniformOutput', false);
            xrdIdx = find(strcmp(titles, 'XRD Analysis'));
            intelIdx = find(strcmp(titles, 'Intelligence'));
            testCase.verifyLessThan(xrdIdx, intelIdx);
        end
    end
end
