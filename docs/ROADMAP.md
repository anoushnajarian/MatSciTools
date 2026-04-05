# MatSciTools Roadmap

## Vision
Build the most accessible, integrated MATLAB toolkit for material science and engineering — bridging the gap between expensive commercial tools and fragmented scripts.

## Phase 1: Foundation (v0.1) ✅
**Status: Complete**
- [x] Literature review and gap analysis
- [x] Project specification
- [x] Project structure and architecture
- [x] Material database module (matdb) — core data + search/get/compare/list
- [x] Material selection module (matsel) — Ashby charts + filtering + ranking
- [x] Mechanical testing module (mechtest) — import, analyze, plot stress-strain curves
- [x] Unit tests for Phase 1 modules (46 tests, all passing)
- [x] Demo scripts
- [x] Getting started documentation

## Phase 2: Advanced Analysis (v0.2) ✅
**Status: Complete**
- [x] Phase diagram module (phasediag) — binary phase diagrams, lever rule
- [x] Common binary system templates (Cu-Ni, Pb-Sn, Al-Si, Al-Cu, Fe-Ni)
- [x] Engineering ↔ true stress-strain conversion
- [x] Multi-specimen comparison in mechtest
- [x] Statistical analysis for mechanical testing (mean, std, confidence intervals)
- [x] Expanded material database (57 materials)
- [x] Material cost estimation features (component cost, ranking, substitution)
- [x] Report generation (text and HTML formats for mechtest and microstructure)

## Phase 3: Image Analysis (v0.3) ✅
**Status: Complete**
- [x] Microstructure analysis module (+microstructure)
- [x] Grain boundary detection (gradient-based edge detection)
- [x] Grain size measurement (ASTM E112 linear intercept method)
- [x] Porosity calculation (connected component labeling, no toolbox needed)
- [x] Phase fraction estimation (k-means clustering)
- [x] Synthetic microstructure generation (grains, porous, dual-phase)
- [x] Batch processing for multiple images (with aggregate statistics)

## Phase 4: Intelligence (v0.4) ✅
**Status: Complete**
- [x] KNN-based material property prediction (+intelligence)
- [x] Composition-property surrogate models (polynomial regression + LOO CV)
- [x] Material recommendation engine (multi-objective with constraints)
- [x] XRD analysis module (background subtraction, peak fitting, crystallite size)
- [x] Constitutive model fitting (Hollomon, Ludwik, Voce, Swift)
- [x] ASTM compliance checking (E8 tensile, E112 grain size)
- [x] Integration with Materials Project API for data import
- [x] Neural network for microstructure classification (feature-based scoring)

## Phase 5: Enterprise (v1.0) ✅
**Status: Complete**
- [x] Programmatic uifigure GUI (+gui/MatSciApp) — 7-tab interface (Material Database, Material Selection, Mechanical Testing, Phase Diagrams, Microstructure, XRD Analysis, Modeling) with cost estimation & report export
- [x] Slider-based controls replacing numeric input fields
- [x] Constitutive model curve visualization in Mechanical Testing tab
- [x] Williamson-Hall plot always visible in XRD Analysis tab
- [x] Auto-regenerate XRD pattern on material change
- [x] Microstructure classification integrated into GUI
- [x] XRD CSV data export from GUI
- [x] Comprehensive API documentation (docs/API_REFERENCE.md)
- [x] Standalone compiled application (compile_standalone.m)
- [x] Advanced ML: anomaly detection (Mahalanobis distance)
- [x] Advanced ML: feature importance (correlation + regression)
- [x] Advanced ML: k-means material clustering with silhouette scoring
- [x] GUI integration for anomaly detection, feature importance, clustering
- [x] Published to GitHub with MIT license, CITATION.cff, CONTRIBUTING.md
- [x] Published MATLAB toolbox on File Exchange
- [x] XRD demo script (demo_xrd.m)
- [x] Educational labs (3 lab exercises with answer keys)
- [x] Circular intercept method (ASTM E112)
- [x] Williamson-Hall standalone plot function
- [x] 237 tests across 16 test files
- [ ] Integration with Simulink for material models
- [ ] Custom database management GUI
- [ ] Community material database contributions

## Release History
| Version | Date | Highlights |
|---------|------|------------|
| v0.1-alpha | 2026-04-01 | Initial release: matdb, matsel, mechtest modules |
| v0.2       | 2026-04-01 | Phase diagrams, true stress-strain, statistics, 57 materials |
| v0.3       | 2026-04-01 | Microstructure analysis (grain size, porosity, phase fraction) |
| v0.4       | 2026-04-01 | Intelligence module (KNN prediction, surrogate models, recommendation) |
| v0.5       | 2026-04-01 | GUI application (7-tab App Designer interface) |
| v0.6       | 2026-04-01 | Cost estimation, report generation, batch processing |
| v0.7       | 2026-04-02 | Constitutive models, XRD module, ASTM compliance |
| v0.8       | 2026-04-02 | Materials Project API, microstructure classification |
| v0.9       | 2026-04-02 | API documentation, GUI classify & XRD export, README overhaul |
| v0.10      | 2026-04-03 | Standalone compiler, anomaly detection, feature importance, k-means clustering |
| v1.0       | 2026-04-04 | GUI overhaul (sliders, Modeling tab, W-H inline plot), 237 tests, educational labs, circular intercept, publication export |

## Contributing
Contributions welcome! See CONTRIBUTING.md for guidelines.

## License
MIT License
