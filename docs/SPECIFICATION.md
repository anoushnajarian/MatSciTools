# MatSciTools — Material Science Engineering Toolkit for MATLAB

## Project Specification

**Version:** 1.0.0  
**Date:** April 4, 2026  
**Status:** Released  
**License:** Open Source (MIT)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Target Users](#2-target-users)
3. [Core Modules](#3-core-modules)
   - 3.1 [Material Database (`matdb`)](#31-material-database-matdb)
   - 3.2 [Material Selection (`matsel`)](#32-material-selection-matsel)
   - 3.3 [Mechanical Testing Analysis (`mechtest`)](#33-mechanical-testing-analysis-mechtest)
   - 3.4 [Phase Diagrams (`phasediag`)](#34-phase-diagrams-phasediag)
   - 3.5 [Microstructure Analysis (`microstructure`)](#35-microstructure-analysis-microstructure)
4. [Architecture](#4-architecture)
5. [Technical Requirements](#5-technical-requirements)
6. [Quality Requirements](#6-quality-requirements)
7. [Deliverables](#7-deliverables)
8. [Project Roadmap](#8-project-roadmap)

---

## 1. Overview

MatSciTools is an **open-source MATLAB toolkit** for material science and engineering. It provides an integrated suite of tools for:

- Material property lookup and comparison
- Ashby-style material selection charts
- Mechanical testing data analysis
- Binary phase diagram computation
- Microstructure image analysis

The project targets students, researchers, and practicing engineers who need accessible computational MSE tools **without expensive commercial licenses**. All core functionality runs on a vanilla MATLAB installation with no required toolboxes.

---

## 2. Target Users

| User Group | Primary Use Cases |
|---|---|
| **Undergraduate / graduate MSE students** | Homework, lab reports, thesis research — property lookup, stress-strain analysis, phase diagram exercises |
| **Materials researchers** | Rapid prototyping of analyses, microstructure quantification, data visualization for publications |
| **Mechanical / civil / aerospace engineers** | Material selection for design, performance index ranking, property trade-off charts |
| **Quality control engineers** | Mechanical test data processing, multi-specimen statistics, automated report generation |

### User Assumptions

- Users have access to MATLAB R2020a or later.
- Users have a basic working knowledge of MATLAB syntax and the command window.
- No prior experience with MatSciTools-specific APIs is assumed; documentation and examples are provided.

---

## 3. Core Modules

### 3.1 Material Database (`matdb`)

#### Purpose

Provide a built-in, searchable database of common engineering materials with key mechanical, thermal, and economic properties.

#### Database Contents

- **~50 common engineering materials** spanning:
  - **Metals & alloys:** carbon steels, stainless steels, aluminum alloys, titanium alloys, copper alloys, nickel superalloys
  - **Ceramics:** alumina, silicon carbide, zirconia, glass
  - **Polymers:** PE, PP, PVC, PMMA, nylon, PTFE, epoxy
  - **Composites:** CFRP, GFRP, WC-Co

#### Material Properties

Each material record contains the following fields:

| Property | Field Name | Units | Type |
|---|---|---|---|
| Name | `name` | — | `char` |
| Category | `category` | — | `char` (metal / ceramic / polymer / composite) |
| Density | `density` | kg/m³ | `double` |
| Elastic modulus | `E` | GPa | `double` |
| Yield strength | `yield_strength` | MPa | `double` |
| Ultimate tensile strength | `UTS` | MPa | `double` |
| Hardness (Vickers) | `hardness` | HV | `double` |
| Poisson's ratio | `poisson` | — | `double` |
| Thermal conductivity | `k_thermal` | W/(m·K) | `double` |
| Thermal expansion coeff. | `alpha` | 1/K (×10⁻⁶) | `double` |
| Melting point | `T_melt` | °C | `double` |
| Cost (approximate) | `cost` | USD/kg | `double` |

#### Data Storage

- Data stored as MATLAB struct arrays in `.mat` files under `data/`.
- Main database file: `data/matdb_default.mat`.
- Custom user databases can be loaded from any `.mat` file following the same struct schema.

#### Public Functions

| Function | Signature | Description |
|---|---|---|
| `matdb_list` | `matdb.matdb_list()` | List all materials in the active database. Returns a table of names and categories. |
| `matdb_get` | `matdb.matdb_get(name)` | Retrieve the full property struct for a material by exact name. |
| `matdb_search` | `matdb.matdb_search(query)` | Search materials by partial name match or category. Supports wildcards. |
| `matdb_compare` | `matdb.matdb_compare(names, props)` | Generate a comparison table for a list of materials across specified properties. |

#### Extensibility

Users can add custom materials by:

1. Loading the database struct: `db = matdb.load('data/matdb_default.mat');`
2. Appending a new struct entry with the required fields.
3. Saving back: `matdb.save(db, 'data/matdb_custom.mat');`

Input validation ensures all required fields are present and have correct types.

---

### 3.2 Material Selection (`matsel`)

#### Purpose

Generate Ashby-style material property charts and perform constraint-based material selection with performance index ranking.

#### Features

- **Ashby charts:** Log-log scatter plots of any two material properties (e.g., E vs. density).
- **Color coding** by material family (metals = blue, ceramics = red, polymers = green, composites = orange).
- **Constraint filtering:** Apply min/max bounds on any property to narrow candidates.
- **Performance indices:** Compute derived merit indices (e.g., `E/density` for stiff-lightweight, `yield_strength/cost` for cost-effective strength).
- **Ranking:** Sort filtered materials by a chosen performance index.

#### Public Functions

| Function | Signature | Description |
|---|---|---|
| `matsel_ashby` | `matsel.matsel_ashby(db, xprop, yprop)` | Generate an Ashby chart plotting `yprop` vs. `xprop` with material family colors and labels. Returns figure handle. |
| `matsel_filter` | `matsel.matsel_filter(db, constraints)` | Filter the database by a struct of constraints (e.g., `constraints.density_max = 3000`). Returns filtered struct array. |
| `matsel_index` | `matsel.matsel_index(db, expression)` | Compute a custom performance index. `expression` is a string like `'E ./ density'`. Returns the database augmented with an `index` field. |
| `matsel_rank` | `matsel.matsel_rank(db, expression, n)` | Rank materials by performance index and return the top `n` candidates as a table. |

#### Ashby Chart Details

- Both axes default to logarithmic scale.
- Optional guideline slopes can be overlaid (e.g., lines of constant `E/density`).
- Materials are plotted as labeled scatter points; legend shows family grouping.
- Name-value pair options: `'LogScale'` (true/false), `'Guidelines'` (slope values), `'FontSize'`, `'MarkerSize'`.

---

### 3.3 Mechanical Testing Analysis (`mechtest`)

#### Purpose

Import, process, analyze, and visualize stress-strain data from mechanical testing (tensile, compression) experiments.

#### Data Import

- **Supported formats:** CSV (`.csv`), Excel (`.xlsx`, `.xls`).
- **Expected columns:** strain (dimensionless or %) and stress (MPa). Column mapping is configurable.
- **Multi-specimen support:** Import multiple files at once for batch processing.

#### Analysis Capabilities

| Measurement | Method | Output Field |
|---|---|---|
| Elastic modulus (E) | Linear regression on the initial linear region | `E` (GPa) |
| Yield strength (σ_y) | 0.2% offset method — intersection of stress-strain curve with a line of slope E offset by 0.002 strain | `yield_strength` (MPa) |
| Ultimate tensile strength (UTS) | Maximum stress value | `UTS` (MPa) |
| Elongation at break (ε_f) | Strain at final data point (or fracture detection) | `elongation` (%) |
| Toughness | Trapezoidal integration of the full stress-strain curve (area under curve) | `toughness` (MJ/m³) |
| Resilience | Area under the elastic region (up to yield) | `resilience` (MJ/m³) |

#### Stress-Strain Conversion

- **Engineering → True** conversion:
  - True stress: `σ_true = σ_eng × (1 + ε_eng)`
  - True strain: `ε_true = ln(1 + ε_eng)`
- Valid up to the onset of necking (UTS point).

#### Visualization

- Stress-strain curve with annotated key points (yield, UTS, fracture).
- Overlay of engineering and true stress-strain curves.
- Multi-specimen overlay plots with legend.

#### Public Functions

| Function | Signature | Description |
|---|---|---|
| `mechtest_import` | `mechtest.mechtest_import(filepath)` | Import stress-strain data from a CSV or Excel file. Returns a struct with `strain`, `stress` vectors and metadata. |
| `mechtest_analyze` | `mechtest.mechtest_analyze(data)` | Run the full analysis suite on imported data. Returns a results struct with all computed properties. |
| `mechtest_plot` | `mechtest.mechtest_plot(data, results)` | Plot the stress-strain curve with annotated key points. Returns figure handle. |
| `mechtest_compare` | `mechtest.mechtest_compare(data_array)` | Overlay multiple specimens on one plot. Compute mean and standard deviation of properties. |
| `mechtest_report` | `mechtest.mechtest_report(results, filepath)` | Export a summary report (text or CSV) of all computed mechanical properties. |

---

### 3.4 Phase Diagrams (`phasediag`)

#### Purpose

Compute and plot binary phase diagrams using simplified thermodynamic models, and perform lever rule calculations.

#### Thermodynamic Models

1. **Ideal solution model:**
   - Assumes zero enthalpy of mixing (ΔH_mix = 0).
   - Liquidus/solidus computed from melting points and the ideal solution equations.

2. **Regular solution model:**
   - Includes an interaction parameter Ω for enthalpy of mixing.
   - `ΔG_mix = Ω·x_A·x_B + RT(x_A·ln(x_A) + x_B·ln(x_B))`
   - Supports miscibility gaps and eutectic behavior.

#### Built-in System Templates

| System | Type | Key Features |
|---|---|---|
| **Fe-C** | Eutectic + eutectoid | Simplified Fe-Fe₃C diagram with austenite, ferrite, cementite regions |
| **Cu-Ni** | Isomorphous | Complete solid solubility — ideal for teaching |
| **Pb-Sn** | Eutectic | Classic eutectic system with limited solid solubility |
| **Al-Cu** | Eutectic | Age-hardening system with solvus line |

Templates are stored as parameter sets in `data/phasediag_systems.mat`.

#### Lever Rule

Given a composition and temperature within a two-phase region:
- Compute the compositions of each phase (from tie-line endpoints).
- Compute the weight fraction of each phase: `W_α = (C_β - C₀) / (C_β - C_α)`.

#### Public Functions

| Function | Signature | Description |
|---|---|---|
| `phasediag_binary` | `phasediag.phasediag_binary(params)` | Compute the phase boundaries for a binary system given thermodynamic parameters. Returns boundary curves. |
| `phasediag_lever` | `phasediag.phasediag_lever(diagram, comp, temp)` | Perform lever rule calculation at a given composition and temperature. Returns phase fractions and compositions. |
| `phasediag_plot` | `phasediag.phasediag_plot(diagram)` | Plot the binary phase diagram with labeled regions, tie lines, and optional operating point. Returns figure handle. |

---

### 3.5 Microstructure Analysis (`microstructure`)

#### Purpose

Import microscopy images and perform quantitative microstructure analysis including grain size measurement, porosity calculation, and phase fraction estimation.

#### Image Import

- Supported formats: JPEG, PNG, TIFF, BMP.
- Supports optical micrographs and SEM images.
- Scale bar detection or manual scale input (µm/pixel).

#### Analysis Capabilities

| Analysis | Method | Standard |
|---|---|---|
| **Grain size** | Heyn intercept method — random test lines overlaid on image, intersections with grain boundaries counted | ASTM E112 |
| **Grain size (alt)** | Equivalent circular diameter from detected grain areas | — |
| **Porosity** | Area fraction of pores detected by intensity thresholding | — |
| **Phase fraction** | Area fraction of distinct phases via multi-level thresholding or user-defined intensity ranges | — |

#### Image Processing Pipeline

1. **Import & scale:** Load image, convert to grayscale, set scale factor.
2. **Pre-processing:** Noise reduction (median filter), contrast enhancement (histogram equalization).
3. **Segmentation:** Edge detection (Canny or Sobel) for grain boundaries; Otsu thresholding for porosity/phase analysis; optional watershed segmentation for touching grains.
4. **Measurement:** Count intercepts, compute areas, calculate statistics.
5. **Reporting:** Generate annotated image overlays and summary statistics.

#### Public Functions

| Function | Signature | Description |
|---|---|---|
| `micro_import` | `microstructure.micro_import(filepath, scale)` | Import a microscopy image with a given scale (µm/pixel). Returns an image struct with metadata. |
| `micro_grainsize` | `microstructure.micro_grainsize(img_struct)` | Measure grain size using ASTM E112 intercept method. Returns mean intercept length, ASTM grain size number, and statistics. |
| `micro_porosity` | `microstructure.micro_porosity(img_struct)` | Calculate porosity as area fraction of detected pores. Returns porosity percentage and pore size distribution. |
| `micro_phasefraction` | `microstructure.micro_phasefraction(img_struct, n_phases)` | Estimate area fractions of `n_phases` phases via thresholding. Returns fraction array and labeled image. |
| `micro_report` | `microstructure.micro_report(results, filepath)` | Export a microstructure analysis report with annotated images and summary statistics. |

> **Note:** This module requires the **Image Processing Toolbox**. A runtime check warns users if the toolbox is not installed.

---

## 4. Architecture

### Directory Structure

```
MatSciTools/
├── +matdb/                % Material database module (package namespace)
│   ├── matdb_list.m
│   ├── matdb_get.m
│   ├── matdb_search.m
│   ├── matdb_compare.m
│   ├── load.m
│   └── save.m
├── +matsel/               % Material selection module
│   ├── matsel_ashby.m
│   ├── matsel_filter.m
│   ├── matsel_index.m
│   └── matsel_rank.m
├── +mechtest/             % Mechanical testing analysis module
│   ├── mechtest_import.m
│   ├── mechtest_analyze.m
│   ├── mechtest_plot.m
│   ├── mechtest_compare.m
│   └── mechtest_report.m
├── +phasediag/            % Phase diagram module
│   ├── phasediag_binary.m
│   ├── phasediag_lever.m
│   └── phasediag_plot.m
├── +microstructure/       % Microstructure analysis module
│   ├── micro_import.m
│   ├── micro_grainsize.m
│   ├── micro_porosity.m
│   ├── micro_phasefraction.m
│   └── micro_report.m
├── +utils/                % Shared utility functions
│   ├── validate_input.m
│   ├── plot_defaults.m
│   └── export_table.m
├── data/                  % Data files
│   ├── matdb_default.mat
│   ├── phasediag_systems.mat
│   └── sample/            % Sample data for examples
│       ├── tensile_test_1.csv
│       ├── tensile_test_2.csv
│       └── micrograph_steel.png
├── tests/                 % Unit test suite
│   ├── test_matdb.m
│   ├── test_matsel.m
│   ├── test_mechtest.m
│   ├── test_phasediag.m
│   └── test_microstructure.m
├── docs/                  % Documentation
│   ├── SPECIFICATION.md
│   ├── GettingStarted.md
│   └── APIReference.md
├── examples/              % Demo scripts
│   ├── demo_matdb.m
│   ├── demo_ashby.m
│   ├── demo_tensile.m
│   ├── demo_phasediag.m
│   └── demo_microstructure.m
├── matscitools.m          % Main entry point — prints version info, adds paths
├── install.m              % One-time setup script (adds to MATLAB path)
├── LICENSE
└── README.md
```

### Design Principles

1. **Package namespaces:** Each module lives in a `+folder`, providing clean namespacing (e.g., `matdb.matdb_get('Steel 1045')`).
2. **Struct-based data passing:** All data and results are passed as MATLAB structs — no custom classes required — keeping the barrier to entry low.
3. **Minimal dependencies:** Core modules (`matdb`, `matsel`, `mechtest`) require only base MATLAB.
4. **Consistent API patterns:** Every module follows `module_action()` naming. Import functions return data structs, analysis functions return results structs, plot functions return figure handles.

---

## 5. Technical Requirements

### MATLAB Version

| Requirement | Value |
|---|---|
| Minimum version | **MATLAB R2020a** |
| Reason | String array support, modern table features, `arguments` block validation |

### Toolbox Dependencies

| Toolbox | Required? | Used By |
|---|---|---|
| Base MATLAB | **Yes** | All modules |
| Image Processing Toolbox | Optional | `microstructure` module (grain detection, segmentation) |
| Statistics and Machine Learning Toolbox | Optional | Advanced multi-specimen statistics in `mechtest` |

When an optional toolbox is unavailable, the affected functions must:
- Display a clear warning identifying the missing toolbox.
- Gracefully degrade or error with an actionable message.

### Platform Compatibility

- **Windows** (primary development target)
- **macOS**
- **Linux**

File I/O uses platform-agnostic MATLAB functions (`fullfile`, `filesep`).

---

## 6. Quality Requirements

### Documentation Standards

- **Every public function** must include:
  - An H1 line (first comment line) with a one-sentence summary.
  - A full description block with input/output documentation.
  - At least one usage example in the help text.
- Module-level documentation in `docs/`.

### Testing Standards

- **Unit tests** for all modules using MATLAB's built-in testing framework (`matlab.unittest`).
- Tests organized in `tests/` directory, one test file per module.
- Each public function has at least:
  - 1 test for normal operation (happy path).
  - 1 test for edge cases (empty input, boundary values).
  - 1 test for invalid input (verifying error handling).
- Tests must be runnable via: `results = runtests('tests');`

### Input Validation

- All public functions validate inputs using MATLAB `arguments` blocks (R2019b+).
- Invalid inputs produce errors with a consistent format: `[MODULE:function] message` (e.g., `[matdb:matdb_get] Material name must be a character vector or string.`).

### Code Style

- Functions use lowercase with underscores (snake_case).
- Variables use camelCase.
- Constants use UPPER_SNAKE_CASE.
- Maximum line length: 100 characters.
- All files end with a newline.

---

## 7. Deliverables

| # | Deliverable | Description |
|---|---|---|
| 1 | **MATLAB source code** | All five modules with public and internal functions |
| 2 | **Material property database** | `matdb_default.mat` with ~50 engineering materials |
| 3 | **Phase diagram templates** | `phasediag_systems.mat` with Fe-C, Cu-Ni, Pb-Sn, Al-Cu parameters |
| 4 | **Unit test suite** | Full test coverage for all modules |
| 5 | **User documentation** | Getting Started guide, API reference, this specification |
| 6 | **Demo scripts** | One demo per module with sample data |
| 7 | **Sample data** | CSV tensile test data, sample micrograph images |
| 8 | **Installation script** | `install.m` for one-step MATLAB path setup |

---

## 8. Project Roadmap

All phases complete as of v1.0.

### Phase 1 — Foundation (v0.1) ✅

- [x] Project structure and packaging (`+folder` namespaces)
- [x] Material database module (`matdb`) — 57 materials
- [x] Material selection module (`matsel`) — Ashby charts, filtering, ranking
- [x] Mechanical testing module (`mechtest`) — import, analyze, plot
- [x] Unit tests and demo scripts

### Phase 2 — Advanced Analysis (v0.2) ✅

- [x] Phase diagram module (`phasediag`) — 5 binary systems, lever rule
- [x] True stress-strain conversion, multi-specimen statistics
- [x] Cost estimation, report generation (text and HTML)

### Phase 3 — Image Analysis (v0.3) ✅

- [x] Microstructure module — grain size (linear + circular intercept), porosity, phase fraction
- [x] Synthetic microstructure generation, batch processing

### Phase 4 — Intelligence & XRD (v0.4) ✅

- [x] Intelligence module — KNN prediction, surrogates, recommendation, clustering, anomaly detection
- [x] XRD module — 11 crystal structures, peak fitting, crystallite size, Williamson-Hall
- [x] Constitutive models (Hollomon, Ludwik, Voce, Swift)
- [x] ASTM compliance (E8, E112), Materials Project API

### Phase 5 — GUI & Release (v1.0) ✅

- [x] 7-tab programmatic uifigure GUI with slider controls
- [x] Standalone compiler, publication-quality export
- [x] 5 educational labs with instructor answer keys
- [x] 237 tests across 16 test files
- [x] Published to GitHub with MIT license, CITATION.cff
- [x] Complete documentation (API Reference, Getting Started, Specification)

---

*This specification was finalized for v1.0 on April 4, 2026.*
