classdef test_matdb < matlab.unittest.TestCase
%TEST_MATDB Unit tests for the material database module

    methods (Test)
        function testListReturnsTable(testCase)
            T = matdb.list();
            testCase.verifyClass(T, 'table');
            testCase.verifyGreaterThan(height(T), 25);
        end

        function testListHasExpectedColumns(testCase)
            T = matdb.list();
            expected = {'Name', 'Category', 'Subcategory', 'Density_kg_m3', ...
                        'YoungsModulus_GPa', 'YieldStrength_MPa', 'UTS_MPa'};
            testCase.verifyEqual(T.Properties.VariableNames, expected);
        end

        function testListFilterByCategory(testCase)
            metals = matdb.list('Metal');
            categories = unique(metals.Category);
            testCase.verifyEqual(categories, {'Metal'});

            ceramics = matdb.list('Ceramic');
            testCase.verifyGreaterThan(height(ceramics), 0);

            polymers = matdb.list('Polymer');
            testCase.verifyGreaterThan(height(polymers), 0);

            composites = matdb.list('Composite');
            testCase.verifyGreaterThan(height(composites), 0);
        end

        function testGetExactMatch(testCase)
            mat = matdb.get('AISI 1045 Steel');
            testCase.verifyEqual(mat.name, 'AISI 1045 Steel');
            testCase.verifyEqual(mat.category, 'Metal');
            testCase.verifyGreaterThan(mat.density, 7000);
            testCase.verifyGreaterThan(mat.youngs_modulus, 190);
        end

        function testGetPartialMatch(testCase)
            mat = matdb.get('Al 6061');
            testCase.verifyTrue(contains(mat.name, 'Al 6061'));
        end

        function testGetCaseInsensitive(testCase)
            mat = matdb.get('aisi 1045 steel');
            testCase.verifyEqual(mat.name, 'AISI 1045 Steel');
        end

        function testGetNotFoundError(testCase)
            testCase.verifyError(@() matdb.get('Nonexistent Material XYZ'), 'matdb:NotFound');
        end

        function testGetInvalidInputError(testCase)
            testCase.verifyError(@() matdb.get(123), 'matdb:InvalidInput');
        end

        function testSearchByDensity(testCase)
            results = matdb.search('density', [0 3000]);
            densities = [results.density];
            testCase.verifyTrue(all(densities <= 3000));
            testCase.verifyTrue(all(densities >= 0));
        end

        function testSearchMultipleConstraints(testCase)
            results = matdb.search('density', [0 3000], 'yield_strength', [200 Inf]);
            testCase.verifyGreaterThan(numel(results), 0);
            for i = 1:numel(results)
                testCase.verifyLessThanOrEqual(results(i).density, 3000);
                testCase.verifyGreaterThanOrEqual(results(i).yield_strength, 200);
            end
        end

        function testSearchNoResults(testCase)
            results = matdb.search('density', [0 1], 'youngs_modulus', [1000 Inf]);
            testCase.verifyEmpty(results);
        end

        function testSearchInvalidProperty(testCase)
            testCase.verifyError(@() matdb.search('nonexistent', [0 1]), 'matdb:InvalidProperty');
        end

        function testCompareReturnsTable(testCase)
            T = matdb.compare({'Al 6061-T6', 'Ti-6Al-4V'});
            testCase.verifyClass(T, 'table');
            testCase.verifyEqual(width(T), 2);
            testCase.verifyEqual(numel(T.Properties.RowNames), 12);
        end

        function testUnitsReturnsStruct(testCase)
            u = matdb.units();
            testCase.verifyClass(u, 'struct');
            testCase.verifyTrue(isfield(u, 'density'));
            testCase.verifyTrue(isfield(u, 'youngs_modulus'));
            testCase.verifyEqual(u.density, 'kg/m^3');
            testCase.verifyEqual(u.youngs_modulus, 'GPa');
        end

        function testAllMaterialsHaveRequiredFields(testCase)
            db = matdb.search('density', [-Inf Inf]);
            required = {'name', 'category', 'density', 'youngs_modulus', ...
                        'yield_strength', 'uts', 'elongation', 'thermal_conductivity'};
            for i = 1:numel(db)
                for j = 1:numel(required)
                    testCase.verifyTrue(isfield(db(i), required{j}), ...
                        sprintf('Material %s missing field %s', db(i).name, required{j}));
                end
            end
        end

        function testDensitiesArePositive(testCase)
            db = matdb.search('density', [-Inf Inf]);
            testCase.verifyTrue(all([db.density] > 0));
        end

        function testModulusArePositive(testCase)
            db = matdb.search('density', [-Inf Inf]);
            testCase.verifyTrue(all([db.youngs_modulus] > 0));
        end
    end
end
