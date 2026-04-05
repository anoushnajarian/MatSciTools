# Getting Started with MatSciTools

## Installation

1. **Download or clone** the MatSciTools repository:
   ```
   git clone https://github.com/anoushnajarian/MatSciTools.git
   ```

2. **Add to MATLAB path** — open MATLAB and run:
   ```matlab
   addpath('C:\path\to\mse');   % adjust to your install location
   ```
   Or use **Home → Set Path → Add Folder** in the MATLAB GUI.

3. **Verify the installation:**
   ```matlab
   matscitools
   ```
   You should see a welcome banner listing all available modules.

## Requirements

- MATLAB R2020a or later
- Statistics and Machine Learning Toolbox (optional — used by some ranking functions)

---

## Quick Start

### Material Database (`matdb`)

Browse and query the built-in material property database.

```matlab
% List every material in the database
all = matdb.list();

% Filter to metals only
metals = matdb.list('Metal');

% Get full properties for one material
steel = matdb.get('AISI 1045 Steel');

% Search by property constraints
lightweight = matdb.search('density', [0 3000], 'yield_strength', [200 Inf]);

% Side-by-side comparison table
T = matdb.compare({'Al 6061-T6', 'Ti-6Al-4V', 'CFRP (Carbon/Epoxy)'});
```

### Material Selection (`matsel`)

Ashby charts, performance indices, and multi-criteria ranking.

```matlab
% Ashby chart: density vs Young's modulus
matsel.ashby('density', 'youngs_modulus');

% Filter materials by constraints (returns a table)
T = matsel.filter('density', [0 3000], 'yield_strength', [200 Inf]);

% Rank by specific stiffness (E/ρ)
T = matsel.index('youngs_modulus', 'density', 'TopN', 5);

% Multi-criteria ranking
criteria(1).property = 'yield_strength'; criteria(1).weight = 0.4; criteria(1).goal = 'max';
criteria(2).property = 'density';        criteria(2).weight = 0.3; criteria(2).goal = 'min';
criteria(3).property = 'cost';           criteria(3).weight = 0.3; criteria(3).goal = 'min';
T = matsel.rank(criteria, 'TopN', 5);
```

### Mechanical Testing (`mechtest`)

Analyze tensile test stress-strain data.

```matlab
% Generate synthetic test data
[strain, stress] = mechtest.generate_sample('steel');

% Analyze: extracts E, σ_y, UTS, elongation, toughness, etc.
results = mechtest.analyze(strain, stress);

% Print a formatted report
mechtest.report(results, 'SampleName', 'My Steel Sample');

% Plot annotated stress-strain curve
mechtest.plot(strain, stress, results, 'Title', 'Steel Tensile Test');

% Import real test data from CSV
[strain, stress] = mechtest.import_data('data/sample_tensile_test.csv');
```

### Phase Diagrams (`phasediag`)

Plot binary phase diagrams and compute lever rule calculations.

```matlab
% Plot a binary phase diagram
phasediag.plot('Cu-Ni');

% Lever rule: system, temperature (K), composition (mole fraction)
r = phasediag.lever('Cu-Ni', 1500, 0.4);
```

### Microstructure (`microstructure`)

Analyze microstructure images for grain size, porosity, and phase fraction.

```matlab
% Generate a synthetic grain microstructure
[img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 50);

% Measure grain size (ASTM E112)
gs = microstructure.grainsize(img, 'PixelSize', 0.5);
```

### X-Ray Diffraction (`xrd`)

Generate and analyze XRD patterns, fit peaks, and estimate crystallite size.

```matlab
% Generate a synthetic diffraction pattern
[tt, int, meta] = xrd.generate_pattern('Material', 'fcc_al');

% Find peaks in the pattern
peaks = xrd.find_peaks(tt, int);
```

### Intelligence (`intelligence`)

ML-based property prediction, clustering, and anomaly detection.

```matlab
% Predict properties for a material using KNN
pred = intelligence.predict_properties('Al 6061-T6');

% Cluster materials into groups
clusters = intelligence.cluster_materials('K', 5);
```

### GUI (`gui`)

Launch the unified graphical interface spanning all modules.

```matlab
% Launch the 7-tab GUI application
app = gui.MatSciApp();
```

---

## Educational Labs

Self-contained lab exercises are available in the `labs/` folder for classroom use. Each lab includes theory, working code, student TODO tasks, and instructor answer keys:

- **Materials 101** (`labs/lab_materials_101.m`) — stress-strain curves, property extraction, constitutive models, ASTM E8
- **XRD Analysis** (`labs/lab_xrd_analysis.m`) — Bragg's law, peak fitting, Scherrer/Williamson-Hall
- **Microscopy** (`labs/lab_microscopy.m`) — grain size (linear & circular intercept), porosity, ASTM E112

---

## Running the Demos

Ready-to-run example scripts are in the `examples/` folder:

```matlab
% Material database walkthrough
run('examples/demo_material_database.m');

% Material selection & Ashby charts
run('examples/demo_material_selection.m');

% Mechanical testing analysis
run('examples/demo_mechanical_testing.m');

% Advanced mechanical testing (true stress-strain, statistics)
run('examples/demo_advanced_mechtest.m');

% Phase diagrams and lever rule
run('examples/demo_phase_diagram.m');

% Microstructure analysis
run('examples/demo_microstructure.m');

% X-ray diffraction
run('examples/demo_xrd.m');

% Intelligence (ML prediction, clustering)
run('examples/demo_intelligence.m');
```

Educational labs in the `labs/` folder:

```matlab
run('labs/lab_materials_101.m');
run('labs/lab_xrd_analysis.m');
run('labs/lab_microscopy.m');
```

Each demo is a MATLAB live-script-compatible file with `%%` section breaks — you can step through sections one at a time with **Ctrl+Enter**.

---

## Running Tests

The test suite contains **237 tests** across 16 test files:

```matlab
setup();
results = run_all_tests();
```

Or run individual test files:

```matlab
results = runtests('tests/test_matdb.m');
results = runtests('tests/test_mechtest.m');
```

---

## Where to Find Help

| Resource | Location |
|----------|----------|
| Function help | `help matdb.get`, `help mechtest.analyze`, `help intelligence.predict_properties`, `help xrd.find_peaks`, etc. |
| Demos | `examples/` folder |
| Labs | `labs/` folder |
| Specification | `docs/SPECIFICATION.md` |
| Roadmap | `docs/ROADMAP.md` |
| Literature Review | `docs/LITERATURE_REVIEW.md` |

Every public function has a built-in help block — type `help <module>.<function>` at the MATLAB command prompt for usage details and examples.
