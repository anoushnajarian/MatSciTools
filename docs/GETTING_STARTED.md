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
```

Each demo is a MATLAB live-script-compatible file with `%%` section breaks — you can step through sections one at a time with **Ctrl+Enter**.

---

## Running Tests

If unit tests are available in a `tests/` folder, run them with:

```matlab
results = runtests('tests');
disp(results);
```

---

## Where to Find Help

| Resource | Location |
|----------|----------|
| Function help | `help matdb.get`, `help mechtest.analyze`, etc. |
| Demos | `examples/` folder |
| Specification | `docs/SPECIFICATION.md` |
| Roadmap | `docs/ROADMAP.md` |
| Literature Review | `docs/LITERATURE_REVIEW.md` |

Every public function has a built-in help block — type `help <module>.<function>` at the MATLAB command prompt for usage details and examples.
