# MatSciTools API Reference

**Version 1.0** — Complete reference for all public functions.

---

## Module Overview

| Module | Namespace | Functions | Description |
|--------|-----------|-----------|-------------|
| Material Database | `matdb` | 6 | Property database for 57 engineering materials + Materials Project API |
| Material Selection | `matsel` | 5 | Ashby charts, filtering, performance indices, cost estimation |
| Mechanical Testing | `mechtest` | 11 | Stress-strain analysis, constitutive models, reports |
| Phase Diagrams | `phasediag` | 4 | Binary phase diagrams and lever rule calculations |
| Microstructure | `microstructure` | 8 | Grain size, porosity, phase fraction, batch processing |
| XRD Analysis | `xrd` | 7 | Pattern generation, peak fitting, crystallite size |
| Modeling | `intelligence` | 7 | ML prediction, recommendation, classification, anomaly detection, clustering |
| Standards | `standards` | 2 | ASTM E8 and E112 compliance checking |
| GUI | `gui` | 1 | 7-tab interactive application |

---

## Material Database (`matdb`)

### `matdb.list`

List available materials in the database.

**Syntax:**
```matlab
T = matdb.list()
T = matdb.list(category)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `category` | `char` (optional) | Filter: `'Metal'`, `'Ceramic'`, `'Polymer'`, `'Composite'` |

**Returns:** `table` with columns `Name`, `Category`.

```matlab
all = matdb.list();
metals = matdb.list('Metal');
```

---

### `matdb.get`

Retrieve all properties for a specific material.

**Syntax:**
```matlab
mat = matdb.get(name)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `char` | Material name (case-insensitive, partial match supported) |

**Returns:** `struct` with fields: `name`, `category`, `subcategory`, `density` (kg/m³), `youngs_modulus` (GPa), `yield_strength` (MPa), `uts` (MPa), `elongation` (%), `hardness` (HV), `poissons_ratio`, `thermal_conductivity` (W/(m·K)), `thermal_expansion` (µm/(m·K)), `melting_point` (°C), `specific_heat` (J/(kg·K)), `cost` (USD/kg).

```matlab
steel = matdb.get('AISI 1045');
fprintf('Density: %.0f kg/m³\n', steel.density);
```

---

### `matdb.search`

Search materials by property constraints.

**Syntax:**
```matlab
results = matdb.search('Property', [min max], ...)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| Property name | `char` | Any numeric property field name |
| Range | `[1×2 double]` | `[min max]` bounds |

**Returns:** Struct array of matching materials.

```matlab
light_strong = matdb.search('density', [0 3000], 'yield_strength', [200 Inf]);
```

---

### `matdb.compare`

Compare properties of multiple materials side by side.

**Syntax:**
```matlab
T = matdb.compare(names)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `names` | `cell` | Cell array of material name strings |

**Returns:** `table` with one row per material, columns for each property.

```matlab
T = matdb.compare({'Al 6061-T6', 'Ti-6Al-4V', 'CFRP (Carbon/Epoxy)'});
```

---

### `matdb.units`

Return units for each material property.

**Syntax:**
```matlab
u = matdb.units()
```

**Returns:** `struct` mapping property names to unit strings.

```matlab
u = matdb.units();
fprintf('Density unit: %s\n', u.density);  % → 'kg/m³'
```

---

### `matdb.materials_project`

Query the Materials Project API (v2) for material data.

**Syntax:**
```matlab
results = matdb.materials_project(api_key)
results = matdb.materials_project(api_key, 'Formula', 'Fe2O3')
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `api_key` | `char` | — | API key (`'demo'` for example data) |
| `'Formula'` | `char` | `''` | Chemical formula to search |
| `'Elements'` | `cell` | `{}` | Filter by elements |
| `'MaxResults'` | `double` | `10` | Maximum results |

**Returns:** `struct` with `.count`, `.data`, `.table`.

```matlab
results = matdb.materials_project('demo', 'Formula', 'Fe2O3');
```

---

## Material Selection (`matsel`)

### `matsel.ashby`

Create an Ashby-style material property chart.

**Syntax:**
```matlab
fig = matsel.ashby(prop_x, prop_y)
fig = matsel.ashby(prop_x, prop_y, 'Name', Value)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prop_x` | `char` | — | X-axis property name |
| `prop_y` | `char` | — | Y-axis property name |
| `'Categories'` | `cell` | all | Categories to include |
| `'LogScale'` | `[1×2 logical]` | `[true, true]` | Log scale per axis |

**Returns:** Figure handle.

```matlab
fig = matsel.ashby('density', 'youngs_modulus');
```

---

### `matsel.filter`

Filter materials by property constraints.

**Syntax:**
```matlab
T = matsel.filter('Property', [min max], ...)
```

**Returns:** `table` of matching materials.

```matlab
T = matsel.filter('density', [0 3000], 'yield_strength', [200 Inf]);
```

---

### `matsel.index`

Calculate and rank by a performance index.

**Syntax:**
```matlab
T = matsel.index(numerator, denominator)
T = matsel.index(num, den, 'Power', [p_num p_den], 'TopN', 10)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `numerator` | `char` | — | Numerator property |
| `denominator` | `char` | — | Denominator property |
| `'Power'` | `[1×2 double]` | `[1 1]` | Exponents: `num^p / den^p` |
| `'Categories'` | `cell` | all | Filter by category |
| `'TopN'` | `double` | all | Return top N results |

**Returns:** `table` sorted by descending performance index.

```matlab
T = matsel.index('youngs_modulus', 'density', 'TopN', 5);
```

---

### `matsel.rank`

Rank materials by weighted multi-criteria scoring.

**Syntax:**
```matlab
T = matsel.rank(criteria)
T = matsel.rank(criteria, 'TopN', 10)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `criteria` | `struct array` | Fields: `property`, `weight`, `goal` (`'max'` or `'min'`) |
| `'Categories'` | `cell` | Filter by category |
| `'TopN'` | `double` | Return top N |

```matlab
c(1) = struct('property','yield_strength','weight',0.5,'goal','max');
c(2) = struct('property','density','weight',0.3,'goal','min');
T = matsel.rank(c, 'TopN', 10);
```

---

### `matsel.cost_estimate`

Material cost estimation and cost-performance analysis.

**Syntax:**
```matlab
r = matsel.cost_estimate('component', 'Material', name, 'Volume', vol)
r = matsel.cost_estimate('ranking', 'Property', prop, 'TopN', n)
r = matsel.cost_estimate('substitute', 'Material', name)
```

| Mode | Description |
|------|-------------|
| `'component'` | Estimate cost for a specific component |
| `'ranking'` | Rank materials by cost-performance ratio |
| `'substitute'` | Find cheaper material substitutes |

```matlab
r = matsel.cost_estimate('component', 'Material', 'AISI 1045', ...
    'Volume', 0.001, 'ManufacturingFactor', 2.0);
fprintf('Total cost: $%.2f\n', r.total_cost);
```

---

## Mechanical Testing (`mechtest`)

### `mechtest.analyze`

Extract key mechanical properties from stress-strain data.

**Syntax:**
```matlab
results = mechtest.analyze(strain, stress)
results = mechtest.analyze(strain, stress, 'OffsetStrain', 0.002)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `strain` | `double` | — | Engineering strain (mm/mm) |
| `stress` | `double` | — | Engineering stress (MPa) |
| `'OffsetStrain'` | `double` | `0.002` | Offset for yield determination |

**Returns:** `struct` with: `youngs_modulus` (GPa), `yield_strength` (MPa), `uts` (MPa), `elongation` (%), `fracture_stress` (MPa), `toughness` (MJ/m³), `resilience` (MJ/m³), `strain_at_uts`.

```matlab
[strain, stress] = mechtest.generate_sample('steel');
results = mechtest.analyze(strain, stress);
```

---

### `mechtest.generate_sample`

Generate synthetic stress-strain data for testing.

**Syntax:**
```matlab
[strain, stress] = mechtest.generate_sample(type)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | `char` | `'steel'`, `'aluminum'`, `'polymer'`, `'ceramic'`, `'rubber'` |
| `'NumPoints'` | `double` | Number of data points (default: 500) |
| `'Noise'` | `double` | Noise level fraction (default: 0.005) |

---

### `mechtest.import_data`

Import stress-strain data from CSV or Excel files.

**Syntax:**
```matlab
[strain, stress] = mechtest.import_data(filename)
[strain, stress] = mechtest.import_data(filename, 'StrainCol', 1, 'StressCol', 2)
```

---

### `mechtest.plot`

Plot annotated stress-strain curve.

**Syntax:**
```matlab
fig = mechtest.plot(strain, stress, results)
fig = mechtest.plot(strain, stress, results, 'Title', 'My Test')
```

---

### `mechtest.compare`

Overlay multiple stress-strain curves.

**Syntax:**
```matlab
fig = mechtest.compare(datasets)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `datasets` | `struct array` | Fields: `strain`, `stress`, `name` |

---

### `mechtest.constitutive_models`

Fit hardening constitutive models to stress-strain data.

**Syntax:**
```matlab
results = mechtest.constitutive_models(eng_strain, eng_stress)
results = mechtest.constitutive_models(eng_strain, eng_stress, 'Models', {'hollomon','voce'})
```

**Models:** Hollomon (`σ = K·ε^n`), Ludwik (`σ = σ₀ + K·ε^n`), Voce (`σ = σ_s - (σ_s-σ₀)·exp(-θ·ε)`), Swift (`σ = K·(ε₀+ε)^n`).

**Returns:** `struct` with one field per model + `best_model`.

---

### `mechtest.true_stress_strain`

Convert engineering to true stress-strain.

**Syntax:**
```matlab
[true_strain, true_stress] = mechtest.true_stress_strain(eng_strain, eng_stress)
```

---

### `mechtest.statistics`

Compute statistics across multiple specimens.

**Syntax:**
```matlab
stats = mechtest.statistics(results_array)
```

**Returns:** `struct` with `mean`, `std`, `min`, `max`, `cv` for each property.

---

### `mechtest.report` / `mechtest.stats_report`

Print formatted results to the command window.

```matlab
mechtest.report(results, 'SampleName', 'Steel Sample');
mechtest.stats_report(stats, 'TestName', 'Batch 2024');
```

---

### `mechtest.generate_report`

Write formatted report to a file (text or HTML).

**Syntax:**
```matlab
filepath = mechtest.generate_report(results, filename)
filepath = mechtest.generate_report(results, filename, 'Format', 'html')
```

---

## Phase Diagrams (`phasediag`)

### `phasediag.binary`

Compute a binary phase diagram.

**Syntax:**
```matlab
[T_grid, x_grid, phase_map] = phasediag.binary(system)
[T_grid, x_grid, phase_map] = phasediag.binary('custom', 'Tm_A', 1085, ...)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `system` | `char` | `'Cu-Ni'`, `'Pb-Sn'`, `'Al-Cu'`, `'Al-Si'`, `'Fe-Ni'`, or `'custom'` |

**Returns:** `T_grid` (temperature), `x_grid` (composition), `phase_map` (phase IDs: 1=liquid, 2=two-phase, 3=solid).

---

### `phasediag.lever`

Lever rule calculation for phase fractions.

**Syntax:**
```matlab
result = phasediag.lever(system, T, x0)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `system` | `char` | System name |
| `T` | `double` | Temperature (K) |
| `x0` | `double` | Overall composition (mole fraction B) |

**Returns:** `struct` with `phase`, `f_liquid`, `f_solid`, `x_liquid`, `x_solid`.

---

### `phasediag.plot`

Plot a binary phase diagram.

**Syntax:**
```matlab
fig = phasediag.plot(system)
fig = phasediag.plot(system, 'ShowTieLine', 1400, 'Composition', 0.3)
```

---

### `phasediag.systems`

List available binary phase diagram systems.

```matlab
info = phasediag.systems();
```

---

## Microstructure Analysis (`microstructure`)

### `microstructure.generate_synthetic`

Generate synthetic microstructure images for testing.

**Syntax:**
```matlab
[img, metadata] = microstructure.generate_synthetic()
[img, metadata] = microstructure.generate_synthetic('Type', 'porous', 'NumGrains', 50)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `'Type'` | `char` | `'grains'` | `'grains'`, `'porous'`, or `'dual_phase'` |
| `'Size'` | `[1×2 double]` | `[256 256]` | Image dimensions `[rows cols]` |
| `'NumGrains'` | `double` | `30` | Number of grains/pores/features |
| `'Porosity'` | `double` | `0.05` | Target porosity for `'porous'` type |
| `'Noise'` | `double` | `0.02` | Noise level (0–1) |

**Returns:** `img` (uint8 matrix), `metadata` struct.

---

### `microstructure.grainsize`

Measure grain size using ASTM E112 linear intercept method.

**Syntax:**
```matlab
results = microstructure.grainsize(img)
results = microstructure.grainsize(img, 'PixelSize', 0.5)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `img` | matrix or `char` | — | Grayscale image or filename |
| `'PixelSize'` | `double` | `1` | µm per pixel |

**Returns:** `struct` with `mean_intercept`, `std_intercept`, `grain_count`, `astm_grain_number`, `num_lines`, `pixel_size`.

---

### `microstructure.porosity`

Calculate porosity as area fraction of pores.

**Syntax:**
```matlab
results = microstructure.porosity(img)
```

**Returns:** `struct` with `porosity_percent`, `num_pores`, `mean_pore_area`, `image_area`.

---

### `microstructure.phase_fraction`

Estimate phase area fractions via thresholding.

**Syntax:**
```matlab
results = microstructure.phase_fraction(img, 'NumPhases', 2)
```

**Returns:** `struct` with `num_phases`, `fractions`, `fractions_percent`.

---

### `microstructure.batch_process`

Batch processing of multiple images.

**Syntax:**
```matlab
results = microstructure.batch_process(images, 'Analyses', {'grainsize','porosity'})
```

**Returns:** `struct` with `summary` (aggregate stats) and `individual` (per-image results).

---

### microstructure.circular_intercept(img, ...)

Grain size measurement using the Abrams three-circle intercept method (ASTM E112).

**Parameters:**
- `img` — Grayscale image (matrix or filename)
- `'NumCircles'` — Number of concentric circles (default: 3)
- `'RadiusFraction'` — Max radius as fraction of image half-size (default: 0.4)
- `'PixelSize'` — Physical size per pixel in micrometers (default: 1)
- `'Threshold'` — Binarization threshold 0-1 (default: auto/Otsu)
- `'ShowPlot'` — Display visualization (default: false)

**Returns:** struct with `mean_intercept`, `std_intercept`, `grain_count`, `astm_grain_number`, `num_circles`, `circle_results`

---

### `microstructure.report` / `microstructure.generate_report`

Print or write microstructure analysis reports.

```matlab
microstructure.report(results, 'grainsize', 'SampleName', 'Test');
filepath = microstructure.generate_report(results_struct, filename);
```

---

## XRD Analysis (`xrd`)

### `xrd.generate_pattern`

Generate synthetic XRD patterns for testing.

**Syntax:**
```matlab
[two_theta, intensity, metadata] = xrd.generate_pattern()
[two_theta, intensity, metadata] = xrd.generate_pattern('Material', 'bcc_fe')
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `'Material'` | `char` | `'fcc_al'` | Material: `fcc_al`, `bcc_fe`, `fcc_austenite`, `dual_phase`, `hcp_ti`, `fcc_cu`, `fcc_ni`, `bcc_cr` |
| `'Wavelength'` | `double` | `1.5406` | X-ray wavelength (Å, Cu Kα) |
| `'NoiseLevel'` | `double` | `0.02` | Noise as fraction of max intensity |
| `'NumPoints'` | `double` | `2000` | Number of data points |
| `'TwoThetaRange'` | `[1×2 double]` | `[20 90]` | 2θ range in degrees |

**Returns:** `two_theta`, `intensity` vectors; `metadata` struct with `material`, `wavelength`, `peak_positions`, `peak_hkl`.

---

### `xrd.subtract_background`

Remove polynomial background from XRD data.

**Syntax:**
```matlab
[two_theta, corrected, background] = xrd.subtract_background(two_theta, intensity)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `'Method'` | `char` | `'polynomial'` | `'polynomial'` or `'linear'` |
| `'Order'` | `double` | `4` | Polynomial order |

---

### `xrd.find_peaks`

Detect peaks in an XRD pattern.

**Syntax:**
```matlab
peaks = xrd.find_peaks(two_theta, intensity)
peaks = xrd.find_peaks(two_theta, intensity, 'MinHeight', 0.10, 'MinDistance', 2.0)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `'MinHeight'` | `double` | `0.05` | Min height as fraction of max |
| `'MinDistance'` | `double` | `0.5` | Min peak separation (degrees) |
| `'MinProminence'` | `double` | `0.025` | Min prominence as fraction of max |

**Returns:** `struct` with `positions`, `intensities`, `count`.

---

### `xrd.fit_peaks`

Fit analytical profiles to detected peaks.

**Syntax:**
```matlab
fits = xrd.fit_peaks(two_theta, intensity, peak_positions)
fits = xrd.fit_peaks(two_theta, intensity, positions, 'Profile', 'gaussian')
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `'Profile'` | `char` | `'pseudo_voigt'` | `'gaussian'`, `'lorentzian'`, `'pseudo_voigt'` |
| `'Window'` | `double` | `2.0` | Half-width of fitting window (degrees) |

**Returns:** Cell array of structs, each with: `center`, `fwhm`, `height`, `area`, `R2`, `profile`, `fitted`, `two_theta`.

---

### `xrd.bragg`

Compute d-spacing from Bragg's law.

**Syntax:**
```matlab
d = xrd.bragg(two_theta)
d = xrd.bragg(two_theta, 'Wavelength', 1.5406)
```

**Returns:** d-spacing in Angstroms.

```matlab
d = xrd.bragg(44.7);  % → ~2.026 Å
```

---

### `xrd.crystallite_size`

Estimate crystallite size via Scherrer or Williamson-Hall analysis.

**Syntax:**
```matlab
results = xrd.crystallite_size(fwhm_deg, two_theta)
results = xrd.crystallite_size(fwhm_deg, two_theta, 'Method', 'williamson_hall')
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `'Method'` | `char` | `'scherrer'` | `'scherrer'` or `'williamson_hall'` |
| `'Wavelength'` | `double` | `1.5406` | X-ray wavelength (Å) |
| `'K'` | `double` | `0.9` | Scherrer constant |

**Returns:** `struct` with `crystallite_size_nm`; for Williamson-Hall: also `microstrain`, `R2`.

---

### xrd.williamson_hall_plot(fwhm_deg, two_theta, ...)

Williamson-Hall analysis with publication-quality plot. Separates crystallite size from microstrain.

**Parameters:**
- `fwhm_deg` — Peak FWHMs in degrees (vector)
- `two_theta` — Peak positions in degrees (vector)
- `'Wavelength'` — X-ray wavelength in Angstroms (default: 1.5406)
- `'K'` — Scherrer constant (default: 0.9)
- `'InstrBroadening'` — Instrumental broadening in degrees (default: 0)
- `'ShowPlot'` — Generate figure (default: true)
- `'Title'` — Plot title (default: 'Williamson-Hall Plot')

**Returns:** struct with `crystallite_size_nm`, `microstrain`, `R2`, `fit_coeffs`, `x`, `y`, `y_fit`

---

## Intelligence (`intelligence`)

### `intelligence.predict_properties`

Predict material properties using KNN regression.

**Syntax:**
```matlab
predicted = intelligence.predict_properties(name_or_composition, 'K', 3)
```

**Returns:** `struct` with predicted property values and `nearest_materials`, `distances`.

```matlab
pred = intelligence.predict_properties('Al 6061-T6');
fprintf('Predicted yield: %.0f MPa\n', pred.yield_strength);
```

---

### `intelligence.recommend`

Multi-objective material recommendation.

**Syntax:**
```matlab
T = intelligence.recommend(requirements, 'TopN', 10)
```

| Field | Type | Description |
|-------|------|-------------|
| `requirements.constraints` | `struct` | Property bounds, e.g. `.density = [0 3000]` |
| `requirements.objectives` | `struct array` | Fields: `property`, `goal` (`'max'`/`'min'`), `weight` |

```matlab
req.constraints.density = [0 5000];
req.objectives(1) = struct('property','yield_strength','goal','max','weight',0.5);
T = intelligence.recommend(req, 'TopN', 10);
```

---

### `intelligence.surrogate_model`

Build a polynomial regression surrogate model.

**Syntax:**
```matlab
model = intelligence.surrogate_model(input_props, output_prop)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `input_props` | `cell` | Input property names |
| `output_prop` | `char` | Target property name |

**Returns:** `struct` with `predict` (function handle), `r_squared`, `rmse`, `cv_rmse`, `degree`, `n_samples`.

```matlab
model = intelligence.surrogate_model({'density','youngs_modulus'}, 'yield_strength');
y = model.predict([2700 70]);
```

---

### `intelligence.classify_microstructure`

Classify microstructure images by type using feature-based scoring.

**Syntax:**
```matlab
result = intelligence.classify_microstructure(img)
result = intelligence.classify_microstructure(img, 'ShowDetails', true)
```

**Returns:** `struct` with `prediction` (`'grains'`, `'porous'`, or `'dual_phase'`), `confidence`, `probabilities`, `scores`, `features`.

For batch mode, pass a cell array of images.

```matlab
[img, ~] = microstructure.generate_synthetic('Type', 'porous');
result = intelligence.classify_microstructure(img);
fprintf('Predicted: %s (%.1f%%)\n', result.prediction, result.confidence*100);
```

---

### `intelligence.anomaly_detection`

Mahalanobis-based anomaly detection across the material database.

**Syntax:**
```matlab
result = intelligence.anomaly_detection()
```

**Returns:** `struct` with `threshold`, `n_anomalies`, `anomalies` (table), `rankings` (table), `materials` (list).

---

### `intelligence.feature_importance`

Feature importance analysis for a target property.

**Syntax:**
```matlab
result = intelligence.feature_importance(target_property)
result = intelligence.feature_importance(target_property, 'Method', 'both')
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `target_property` | `char` | — | Target property name |
| `'Method'` | `char` | `'correlation'` | `'correlation'`, `'regression'`, or `'both'` |

**Returns:** `struct` with `ranking` (table), `target`, `n_samples`, `method`.

---

### `intelligence.cluster_materials`

K-means clustering of materials by properties.

**Syntax:**
```matlab
result = intelligence.cluster_materials()
result = intelligence.cluster_materials('K', 4)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `'K'` | `double` | `3` | Number of clusters |

**Returns:** `struct` with `n_clusters`, `silhouette`, `cluster_summary` (table), `assignments` (table).

---

## Standards Compliance (`standards`)

### `standards.astm_e8`

Check compliance with ASTM E8 tensile testing standard.

**Syntax:**
```matlab
checks = standards.astm_e8(strain, stress, results)
```

**Returns:** `struct` with compliance checks for data quality, strain rate, modulus, and yield strength determination.

---

### `standards.astm_e112`

Check compliance with ASTM E112 grain size standard.

**Syntax:**
```matlab
checks = standards.astm_e112(grainsize_results)
```

**Returns:** `struct` with compliance checks for intercept count, line count, and ASTM grain size number validity.

---

## GUI Application (`gui`)

### `gui.MatSciApp`

Launch the interactive 7-tab GUI application.

**Syntax:**
```matlab
app = gui.MatSciApp();
```

**Tabs:**
1. **Material Database** — Browse, search, and filter the 57-material database
2. **Material Selection** — Ashby charts with interactive data tips
3. **Mechanical Testing** — Generate/analyze stress-strain data, constitutive model fitting, HTML report export
4. **Phase Diagrams** — Binary phase diagrams (5 systems), lever rule calculations
5. **Microstructure** — Synthetic image generation, grain size/porosity/phase analysis, ML classification
6. **XRD Analysis** — Pattern generation (11 materials), background subtraction, peak fitting (3 profiles), crystallite size, Williamson-Hall plot always visible
7. **Modeling** — KNN property prediction, multi-objective recommendation, surrogate model building, cost estimation, slider controls for density/yield/volume, dropdown material selectors

---

*Generated for MatSciTools v1.0 — April 2026*
