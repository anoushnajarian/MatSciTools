# MatSciTools

**Material Science Engineering Toolkit for MATLAB**

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-blue?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZD0iTTIgMjJMMTAgMiAxNiAxMiAyMiAyIiBzdHJva2U9IndoaXRlIiBmaWxsPSJub25lIiBzdHJva2Utd2lkdGg9IjIiLz48L3N2Zz4=)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/tests-230%20passing-brightgreen)](#testing)
[![File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](#installation)

An open-source MATLAB toolkit providing **9 integrated modules** and a **unified GUI** for material science and engineering — from property lookup and Ashby-style selection to mechanical testing, phase diagrams, microstructure analysis, X-ray diffraction, and ML-based property prediction.

> **No external dependencies.** No MEX compilation. No paid toolboxes required.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Modules](#modules)
- [GUI](#gui)
- [Examples](#examples)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [Citation](#citation)
- [License](#license)

---

## Features

| Feature | Description |
|---------|-------------|
| 📊 **57 materials** | Metals, ceramics, polymers, composites — searchable and comparable |
| 📈 **Ashby charts** | Interactive log-log property charts with colorblind-friendly Okabe-Ito palette |
| 🔧 **Mechanical testing** | Stress-strain analysis, 4 constitutive models (Hollomon, Ludwik, Voce, Swift) |
| ⚗️ **Phase diagrams** | Binary phase diagrams with lever rule calculations |
| 🔬 **Microstructure** | Grain size (ASTM E112), porosity, phase fraction, batch processing |
| 💎 **X-ray diffraction** | 11 crystal structures, peak fitting, Scherrer crystallite sizing |
| 🤖 **Machine learning** | KNN prediction, surrogate models, clustering, anomaly detection |
| 🖥️ **GUI** | 7-tab programmatic uifigure interface spanning all modules |
| 📐 **Standards** | ASTM E8 and E112 compliance checks |
| 🌐 **Materials Project** | API v2 integration for external property data |
| 📄 **Publication export** | PNG/PDF/TIFF/EPS/SVG with journal presets |
| 📏 **Unit converter** | Stress, temperature, length, density, energy, angle |

---

## Installation

### Option 1: Clone from GitHub (recommended)

```bash
git clone https://github.com/anoushnajarian/MatSciTools.git
```

In MATLAB:

```matlab
addpath('path/to/MatSciTools');
setup();
matscitools   % verify installation
```

### Option 2: Download ZIP

Download from [GitHub Releases](../../releases) or [MATLAB File Exchange](#), unzip, and run `setup()`.

### Option 3: MATLAB Add-On Explorer

Search for **MatSciTools** in the MATLAB Add-On Explorer, or double-click the `.mltbx` file.

---

## Quick Start

```matlab
%% Material Database — browse 57 engineering materials
steel = matdb.get('AISI 1045 Steel');
T = matdb.compare({'Al 6061-T6', 'Ti-6Al-4V', 'CFRP (Carbon/Epoxy)'});

%% Material Selection — Ashby charts and ranking
matsel.ashby('density', 'youngs_modulus');
T = matsel.index('youngs_modulus', 'density', 'TopN', 5);

%% Mechanical Testing — analyze stress-strain curves
[strain, stress] = mechtest.generate_sample('steel');
results = mechtest.analyze(strain, stress);
mechtest.report(results, 'SampleName', 'Steel Sample');

%% Phase Diagrams — binary systems and lever rule
phasediag.plot('Cu-Ni');
r = phasediag.lever('Cu-Ni', 1500, 0.4);

%% Microstructure — grain size, porosity, phase fraction
[img, ~] = microstructure.generate_synthetic('Type', 'grains', 'NumGrains', 50);
gs = microstructure.grainsize(img, 'PixelSize', 0.5);
por = microstructure.porosity(img);

%% X-Ray Diffraction — pattern analysis and peak fitting
[tt, int, meta] = xrd.generate_pattern('Material', 'fcc_al');
[~, corrected] = xrd.subtract_background(tt, int);
peaks = xrd.find_peaks(tt, corrected);
fits = xrd.fit_peaks(tt, corrected, peaks.positions);

%% Intelligence — ML-based prediction and clustering
pred = intelligence.predict_properties('Al 6061-T6', 'K', 3);
clusters = intelligence.cluster_materials('K', 5);
anomalies = intelligence.anomaly_detection();

%% Unit Conversion
matsel.convert_units(200, 'MPa', 'ksi')   % → 29.01

%% Launch GUI
app = gui.MatSciApp();
```

---

## Modules

| Module | Namespace | Functions | Description |
|--------|-----------|-----------|-------------|
| **Material Database** | `matdb` | `get`, `list`, `search`, `compare`, `units`, `materials_project` | 57 materials with property search, comparison, and Materials Project API |
| **Material Selection** | `matsel` | `ashby`, `filter`, `index`, `rank`, `cost_estimate`, `convert_units`, `plot_styles` | Ashby charts, performance indices, multi-criteria ranking, cost estimation |
| **Mechanical Testing** | `mechtest` | `analyze`, `plot`, `report`, `generate_sample`, `import_data`, `compare`, `constitutive_models`, `true_stress_strain`, `statistics`, `stats_report`, `generate_report` | Stress-strain analysis, constitutive fitting, statistical comparison |
| **Phase Diagrams** | `phasediag` | `plot`, `lever`, `binary`, `systems` | Binary phase diagrams (Cu-Ni, Pb-Sn, Al-Si, Al-Cu, Fe-Ni) and lever rule |
| **Microstructure** | `microstructure` | `grainsize`, `porosity`, `phase_fraction`, `generate_synthetic`, `batch_process`, `report`, `generate_report` | ASTM E112 grain size, porosity, phase fraction, batch processing |
| **X-Ray Diffraction** | `xrd` | `generate_pattern`, `subtract_background`, `find_peaks`, `fit_peaks`, `crystallite_size`, `bragg` | 11 crystal structures, Gaussian/Lorentzian/pseudo-Voigt fitting, Scherrer equation |
| **Intelligence** | `intelligence` | `predict_properties`, `surrogate_model`, `recommend`, `classify_microstructure`, `anomaly_detection`, `feature_importance`, `cluster_materials` | KNN prediction, polynomial surrogates, k-means clustering, Mahalanobis anomaly detection |
| **Standards** | `standards` | `astm_e8`, `astm_e112` | ASTM compliance validation |
| **GUI** | `gui` | `MatSciApp` | Unified 7-tab graphical interface |

---

## GUI

Launch the graphical interface:

```matlab
app = gui.MatSciApp();
```

The GUI provides a 7-tab interface covering:
- **Database** — browse, search, and view material properties
- **Selection** — interactive Ashby charts with cost estimation
- **Mechtest** — generate/import data, analyze, fit constitutive models, export reports
- **Phase Diagrams** — plot binary systems and compute lever rule
- **Microstructure** — generate synthetic images, analyze grain size and porosity
- **XRD** — generate patterns, find/fit peaks, export CSV
- **Intelligence** — KNN prediction, recommendations, clustering, anomaly detection

<!-- Screenshot placeholder: replace with actual screenshot -->
<!-- ![MatSciTools GUI](docs/screenshots/gui_overview.png) -->

---

## Examples

Ready-to-run demo scripts in the `examples/` folder:

| Script | Module | What it demonstrates |
|--------|--------|---------------------|
| `demo_material_database.m` | matdb | List, search, filter, compare materials |
| `demo_material_selection.m` | matsel | Ashby charts, performance indices, multi-criteria ranking |
| `demo_mechanical_testing.m` | mechtest | Stress-strain analysis, plotting, multi-specimen comparison |
| `demo_advanced_mechtest.m` | mechtest | True stress-strain, statistical analysis, expanded database |
| `demo_phase_diagram.m` | phasediag | Binary phase diagrams, lever rule, tie lines |
| `demo_microstructure.m` | microstructure | Grain size, porosity, dual-phase analysis |
| `demo_xrd.m` | xrd | Pattern generation, background subtraction, peak fitting |
| `demo_intelligence.m` | intelligence | KNN prediction, recommendations, surrogate models |

Run any demo:

```matlab
run('examples/demo_material_database.m');
```

Each demo uses `%%` section breaks — step through interactively with **Ctrl+Enter**.

---

## Testing

The test suite contains **230 tests** across 16 test files:

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

## Project Structure

```
MatSciTools/
├── +gui/               % 7-tab programmatic uifigure application
├── +intelligence/      % ML prediction, clustering, anomaly detection
├── +matdb/             % Material property database (57 materials)
│   └── private/        % Internal data loading
├── +matsel/            % Material selection, Ashby charts, unit conversion
├── +mechtest/          % Mechanical testing analysis
├── +microstructure/    % Microstructure image analysis
├── +phasediag/         % Phase diagram computation
├── +standards/         % ASTM standards compliance
├── +xrd/               % X-ray diffraction processing
├── data/               % Sample datasets (CSV)
├── docs/               % Documentation
│   ├── API_REFERENCE.md
│   ├── GETTING_STARTED.md
│   ├── ROADMAP.md
│   └── SPECIFICATION.md
├── examples/           % 8 demo scripts
├── tests/              % 230 tests across 16 files
├── build/              % Compiled outputs (gitignored)
├── matscitools.m       % Toolkit info entry point
├── setup.m             % Path initialization
├── compile_standalone.m % Build standalone .exe or .mltbx
├── CITATION.cff        % Citation metadata
├── CONTRIBUTING.md     % Contribution guidelines
├── LICENSE             % MIT License
└── README.md
```

---

## Requirements

- **MATLAB R2020a** or later
- **Statistics and Machine Learning Toolbox** — *optional* (some ranking functions)
- **MATLAB Compiler** — *optional* (only for building standalone `.exe`)

No external dependencies or MEX compilation required.

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Bug reporting and feature requests
- Coding conventions (snake_case functions, camelCase variables, arguments blocks)
- Testing requirements
- Pull request checklist

---

## Citation

If you use MatSciTools in your research, please cite:

```bibtex
@software{matscitools2026,
  title     = {MatSciTools: Material Science Engineering Toolkit for MATLAB},
  author    = {Najarian, Anoush and Shepherd, David},
  year      = {2026},
  url       = {https://github.com/anoushnajarian/MatSciTools},
  license   = {MIT}
}
```

Or use the **Cite this repository** button on GitHub (powered by [CITATION.cff](CITATION.cff)).

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Version History

| Version | Highlights |
|---------|------------|
| **v1.0** | GitHub/File Exchange release, 230 tests, 9 modules, XRD demo, publication export |
| v0.10 | Standalone compiler, anomaly detection, feature importance, clustering |
| v0.9 | API documentation, GUI classify & XRD export |
| v0.8 | Materials Project API, microstructure classification |
| v0.7 | Constitutive models, XRD module, ASTM compliance |
| v0.6 | Cost estimation, report generation, batch processing |
| v0.5 | GUI application (7-tab interface) |
| v0.4 | Intelligence module (KNN, surrogates, recommendations) |
| v0.3 | Microstructure analysis (grain size, porosity, phase fraction) |
| v0.2 | Phase diagrams, true stress-strain, 57 materials |
| v0.1 | Initial release: matdb, matsel, mechtest |
