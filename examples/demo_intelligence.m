%% MatSciTools Demo: Intelligent Material Analysis
% This demo shows ML-based property prediction, material recommendation,
% and surrogate modeling.

%% Setup
addpath(fileparts(fileparts(mfilename('fullpath'))));

%% 1. Property Prediction (KNN)
fprintf('=== Property Prediction: Al 6061-T6 ===\n');
pred = intelligence.predict_properties('Al 6061-T6', 'K', 3);
fprintf('Nearest materials: %s\n', strjoin(pred.nearest_materials, ', '));
fprintf('Predicted density: %.0f kg/m³\n', pred.density);
fprintf('Predicted yield: %.0f MPa\n', pred.yield_strength);
fprintf('Density confidence: %.2f\n', pred.density_confidence);

%% 2. Material Recommendation
fprintf('\n=== Material Recommendation: Aerospace Application ===\n');
fprintf('Requirements: density < 4500, yield > 300 MPa\n');
fprintf('Objectives: max strength (50%%), min density (30%%), min cost (20%%)\n\n');
req.constraints.density = [0 4500];
req.constraints.yield_strength = [300 Inf];
req.objectives(1) = struct('property', 'yield_strength', 'goal', 'max', 'weight', 0.5);
req.objectives(2) = struct('property', 'density', 'goal', 'min', 'weight', 0.3);
req.objectives(3) = struct('property', 'cost', 'goal', 'min', 'weight', 0.2);
T = intelligence.recommend(req, 'TopN', 8);
disp(T);

%% 3. Surrogate Model
fprintf('\n=== Surrogate Model: Predict Yield Strength from Density + Modulus ===\n');
model = intelligence.surrogate_model({'density', 'youngs_modulus'}, 'yield_strength');
fprintf('R² = %.3f\n', model.r_squared);
fprintf('RMSE = %.1f MPa\n', model.rmse);
fprintf('CV-RMSE = %.1f MPa\n', model.cv_rmse);
fprintf('Training samples: %d\n', model.n_samples);

% Predict for a hypothetical material
pred_ys = model.predict([2700, 70]); % Al-like
fprintf('\nPrediction for density=2700, E=70: yield = %.0f MPa\n', pred_ys);

pred_ys2 = model.predict([7850, 200]); % Steel-like
fprintf('Prediction for density=7850, E=200: yield = %.0f MPa\n', pred_ys2);

fprintf('\nDemo complete!\n');
