# MATLAB File Exchange Submission Guide

## Submission Details

### Title
MatSciTools — Material Science Engineering Toolkit

### Summary (one line)
9-module MATLAB toolkit: material database (57 materials), Ashby charts, mechanical testing, phase diagrams, microstructure analysis, XRD, ML prediction, and 7-tab GUI.

### Description (for File Exchange listing)

MatSciTools is a comprehensive, open-source MATLAB toolkit for material science and engineering. It provides 9 integrated modules with a unified 7-tab GUI — no paid toolboxes or MEX compilation required.

**Modules:**
- **Material Database** — 57 engineering materials (metals, ceramics, polymers, composites) with search, filter, and compare. Materials Project API v2 integration.
- **Material Selection** — Interactive Ashby charts, performance index ranking, multi-criteria optimization, cost estimation, colorblind-friendly plots (Okabe-Ito), publication export (PNG/PDF/TIFF/EPS/SVG).
- **Mechanical Testing** — Stress-strain analysis, automated property extraction (E, σ_y, UTS, elongation, toughness), 4 constitutive models (Hollomon, Ludwik, Voce, Swift), report generation.
- **Phase Diagrams** — Binary phase diagram computation (Cu-Ni, Pb-Sn, Al-Si, Al-Cu, Fe-Ni) and lever rule calculations.
- **Microstructure Analysis** — Grain size measurement (ASTM E112 linear intercept), porosity analysis, phase fraction quantification, batch processing.
- **X-Ray Diffraction** — Pattern generation for 11 crystal structures, background subtraction, peak fitting (Gaussian, Lorentzian, pseudo-Voigt), Scherrer crystallite sizing.
- **Intelligence** — KNN property prediction, polynomial surrogate models, material recommendation, microstructure classification, k-means clustering, Mahalanobis anomaly detection, feature importance.
- **Standards** — ASTM E8 and E112 compliance checks.
- **GUI** — Programmatic uifigure with 7 tabs spanning all modules.

**Key Features:**
- 230 unit tests, all passing
- Consistent API with MATLAB package namespaces (tab-completion support)
- 8 ready-to-run demo scripts
- Unit converter (stress, temperature, length, density, energy, angle)
- No external dependencies — works with base MATLAB R2020a+

### Tags
materials-science, material-selection, ashby-chart, mechanical-testing, stress-strain, phase-diagram, microstructure, grain-size, xrd, machine-learning, matlab-gui, astm, material-database, engineering

### Category
Engineering > Materials Science

### Required Products
MATLAB (R2020a or later)

### Optional Products
Statistics and Machine Learning Toolbox

---

## How to Submit

1. Go to https://www.mathworks.com/matlabcentral/fileexchange/
2. Click **"Publish your first submission"** (or "Submit" if you've published before)
3. Choose **"Link to GitHub repository"** and enter: `https://github.com/anoushnajarian/MatSciTools`
4. Fill in the title, summary, and description from above
5. Add tags and select the category
6. Upload a screenshot of the GUI (optional but recommended)
7. Submit for review

### GitHub-linked submissions
- File Exchange automatically syncs with your GitHub releases
- Create a GitHub release tagged `v1.0` to trigger the initial sync
- Future updates: create new releases and File Exchange updates automatically

---

## Creating the GitHub Release

```bash
git tag -a v1.0 -m "MatSciTools v1.0: Initial public release"
git push origin v1.0
```

Then on GitHub:
1. Go to Releases → "Draft a new release"
2. Choose tag `v1.0`
3. Title: "MatSciTools v1.0"
4. Description: paste the summary above
5. Attach `build/MatSciTools.zip` as a release asset
6. Publish release
