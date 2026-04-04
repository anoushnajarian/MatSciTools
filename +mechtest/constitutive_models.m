function results = constitutive_models(eng_strain, eng_stress, varargin)
%MECHTEST.CONSTITUTIVE_MODELS Fit hardening constitutive models to stress-strain data
%   RESULTS = MECHTEST.CONSTITUTIVE_MODELS(ENG_STRAIN, ENG_STRESS) converts
%   engineering stress-strain data to true stress-strain and fits four hardening
%   constitutive models (Hollomon, Ludwik, Voce, Swift) to the plastic region.
%
%   RESULTS = MECHTEST.CONSTITUTIVE_MODELS(ENG_STRAIN, ENG_STRESS, 'Models', models)
%   fits only the specified models. MODELS is a cell array of model names chosen
%   from: 'hollomon', 'ludwik', 'voce', 'swift'. Default: all four.
%
%   RESULTS = MECHTEST.CONSTITUTIVE_MODELS(ENG_STRAIN, ENG_STRESS, 'OffsetStrain', val)
%   sets the offset strain for yield point determination (default: 0.002 = 0.2%).
%
%   Inputs:
%     ENG_STRAIN - Engineering strain vector (mm/mm)
%     ENG_STRESS - Engineering stress vector (MPa)
%
%   Optional Parameters:
%     'Models'       - Cell array of models to fit (default: {'hollomon','ludwik','voce','swift'})
%     'OffsetStrain' - Offset strain for yield determination (default: 0.002)
%
%   Returns a struct with:
%     true_strain  - True strain vector used for fitting
%     true_stress  - True stress vector used for fitting
%     plastic_idx  - Logical mask of the plastic region used for fitting
%     best_model   - Name of model with highest R^2
%     hollomon     - Struct: K, n, R2, predicted
%     ludwik       - Struct: sigma0, K, n, R2, predicted
%     voce         - Struct: sigma_s, sigma0, theta, R2, predicted
%     swift        - Struct: K, eps0, n, R2, predicted
%
%   Model equations (true stress vs true strain in plastic region):
%     Hollomon:  sigma = K * eps^n
%     Ludwik:    sigma = sigma0 + K * eps^n
%     Voce:      sigma = sigma_s - (sigma_s - sigma0) * exp(-theta * eps)
%     Swift:     sigma = K * (eps0 + eps)^n
%
%   Example:
%     [strain, stress] = mechtest.generate_sample('steel');
%     results = mechtest.constitutive_models(strain, stress);
%     fprintf('Hollomon: K=%.1f, n=%.3f, R²=%.4f\n', results.hollomon.K, results.hollomon.n, results.hollomon.R2);

    p = inputParser;
    addRequired(p, 'eng_strain', @isnumeric);
    addRequired(p, 'eng_stress', @isnumeric);
    addParameter(p, 'Models', {'hollomon','ludwik','voce','swift'}, @iscell);
    addParameter(p, 'OffsetStrain', 0.002, @isnumeric);
    parse(p, eng_strain, eng_stress, varargin{:});

    models = lower(p.Results.Models);
    offset_strain = p.Results.OffsetStrain;

    eng_strain = eng_strain(:);
    eng_stress = eng_stress(:);

    if numel(eng_strain) ~= numel(eng_stress)
        error('mechtest:SizeMismatch', 'Strain and stress vectors must have the same length.');
    end

    % --- Convert to true stress-strain ---
    true_strain = log(1 + eng_strain);
    true_stress = eng_stress .* (1 + eng_strain);

    % --- Find UTS index (use data only up to UTS) ---
    [~, uts_idx] = max(true_stress);
    true_strain = true_strain(1:uts_idx);
    true_stress = true_stress(1:uts_idx);

    % --- Find yield point using 0.2% offset method ---
    % Estimate elastic modulus from steepest slopes
    ds = diff(true_stress);
    de = diff(true_strain);
    slopes = ds ./ max(de, eps);
    [sorted_slopes, ~] = sort(slopes, 'descend');
    n_top = max(1, min(5, round(0.1 * numel(sorted_slopes))));
    E_true = median(sorted_slopes(1:n_top));

    % Offset line intersection
    offset_line = E_true * (true_strain - offset_strain);
    diff_curve = true_stress - offset_line;
    sign_changes = diff(sign(diff_curve));
    cross_idx = find(sign_changes ~= 0 & true_strain(1:end-1) > offset_strain, 1, 'first');

    if ~isempty(cross_idx)
        yield_strain = true_strain(cross_idx);
    else
        yield_strain = offset_strain;
    end

    % --- Identify plastic region ---
    plastic_idx = true_strain > yield_strain & true_strain > 0;

    results = struct();
    results.true_strain = true_strain;
    results.true_stress = true_stress;
    results.plastic_idx = plastic_idx;

    % Plastic region data
    eps_p = true_strain(plastic_idx);
    sig_p = true_stress(plastic_idx);

    % SS_tot for R2 calculations (computed on plastic region)
    ss_tot = sum((sig_p - mean(sig_p)).^2);

    % --- Valid model names ---
    valid_models = {'hollomon','ludwik','voce','swift'};
    for k = 1:numel(models)
        if ~ismember(models{k}, valid_models)
            error('mechtest:UnknownModel', ...
                'Unknown model: %s. Use: hollomon, ludwik, voce, swift.', models{k});
        end
    end

    % --- Fit Hollomon (needed by Swift as initial guess) ---
    hollomon_result = fit_nan('hollomon');
    if ismember('hollomon', models) || ismember('swift', models)
        hollomon_result = fit_hollomon(eps_p, sig_p, true_strain, ss_tot);
    end
    if ismember('hollomon', models)
        results.hollomon = hollomon_result;
    end

    % --- Fit Ludwik ---
    if ismember('ludwik', models)
        results.ludwik = fit_ludwik(eps_p, sig_p, true_strain, ss_tot);
    end

    % --- Fit Voce ---
    if ismember('voce', models)
        results.voce = fit_voce(eps_p, sig_p, true_strain, ss_tot);
    end

    % --- Fit Swift ---
    if ismember('swift', models)
        results.swift = fit_swift(eps_p, sig_p, true_strain, ss_tot, hollomon_result);
    end

    % --- Determine best model ---
    best_name = '';
    best_r2 = -Inf;
    for k = 1:numel(models)
        m = models{k};
        if isfield(results, m) && isfield(results.(m), 'R2') && ~isnan(results.(m).R2)
            if results.(m).R2 > best_r2
                best_r2 = results.(m).R2;
                best_name = m;
            end
        end
    end
    results.best_model = best_name;
end

% =========================================================================
%  Helper: compute R2
% =========================================================================
function r2 = compute_r2(sig_actual, sig_predicted, ss_tot)
    ss_res = sum((sig_actual - sig_predicted).^2);
    if ss_tot == 0
        r2 = NaN;
    else
        r2 = 1 - ss_res / ss_tot;
    end
end

% =========================================================================
%  Helper: NaN result stub
% =========================================================================
function s = fit_nan(model_name)
    switch model_name
        case 'hollomon'
            s = struct('K', NaN, 'n', NaN, 'R2', NaN, 'predicted', []);
        case 'ludwik'
            s = struct('sigma0', NaN, 'K', NaN, 'n', NaN, 'R2', NaN, 'predicted', []);
        case 'voce'
            s = struct('sigma_s', NaN, 'sigma0', NaN, 'theta', NaN, 'R2', NaN, 'predicted', []);
        case 'swift'
            s = struct('K', NaN, 'eps0', NaN, 'n', NaN, 'R2', NaN, 'predicted', []);
    end
end

% =========================================================================
%  Hollomon:  sigma = K * eps^n
% =========================================================================
function s = fit_hollomon(eps_p, sig_p, true_strain, ss_tot)
    if numel(eps_p) < 2
        s = fit_nan('hollomon');
        return;
    end

    % Linearize: log(sigma) = log(K) + n*log(eps)
    valid = eps_p > 0 & sig_p > 0;
    if sum(valid) < 2
        s = fit_nan('hollomon');
        return;
    end

    coeffs = polyfit(log(eps_p(valid)), log(sig_p(valid)), 1);
    n = coeffs(1);
    K = exp(coeffs(2));

    predicted_full = K * true_strain.^n;
    predicted_plastic = K * eps_p.^n;
    r2 = compute_r2(sig_p, predicted_plastic, ss_tot);

    s = struct('K', K, 'n', n, 'R2', r2, 'predicted', predicted_full);
end

% =========================================================================
%  Ludwik:  sigma = sigma0 + K * eps^n
% =========================================================================
function s = fit_ludwik(eps_p, sig_p, true_strain, ss_tot)
    if numel(eps_p) < 2
        s = fit_nan('ludwik');
        return;
    end

    sigma0 = sig_p(1);
    delta_sig = sig_p - sigma0;

    valid = eps_p > 0 & delta_sig > 0;
    if sum(valid) < 2
        s = fit_nan('ludwik');
        return;
    end

    coeffs = polyfit(log(eps_p(valid)), log(delta_sig(valid)), 1);
    n = coeffs(1);
    K = exp(coeffs(2));

    predicted_full = sigma0 + K * true_strain.^n;
    predicted_plastic = sigma0 + K * eps_p.^n;
    r2 = compute_r2(sig_p, predicted_plastic, ss_tot);

    s = struct('sigma0', sigma0, 'K', K, 'n', n, 'R2', r2, 'predicted', predicted_full);
end

% =========================================================================
%  Voce:  sigma = sigma_s - (sigma_s - sigma0) * exp(-theta * eps)
% =========================================================================
function s = fit_voce(eps_p, sig_p, true_strain, ss_tot)
    if numel(eps_p) < 3
        s = fit_nan('voce');
        return;
    end

    sigma0_init = sig_p(1);
    sigma_s_init = max(sig_p);
    theta_init = 5;

    x0 = [sigma_s_init, sigma0_init, theta_init];

    obj = @(x) sum((sig_p - (x(1) - (x(1) - x(2)) * exp(-x(3) * eps_p))).^2);

    opts = optimset('Display', 'off', 'MaxFunEvals', 5000, 'MaxIter', 5000, 'TolFun', 1e-10, 'TolX', 1e-10);
    [x_opt, ~, exitflag] = fminsearch(obj, x0, opts);

    if exitflag <= 0
        s = fit_nan('voce');
        return;
    end

    sigma_s = x_opt(1);
    sigma0 = x_opt(2);
    theta = x_opt(3);

    predicted_full = sigma_s - (sigma_s - sigma0) * exp(-theta * true_strain);
    predicted_plastic = sigma_s - (sigma_s - sigma0) * exp(-theta * eps_p);
    r2 = compute_r2(sig_p, predicted_plastic, ss_tot);

    s = struct('sigma_s', sigma_s, 'sigma0', sigma0, 'theta', theta, 'R2', r2, 'predicted', predicted_full);
end

% =========================================================================
%  Swift:  sigma = K * (eps0 + eps)^n
% =========================================================================
function s = fit_swift(eps_p, sig_p, true_strain, ss_tot, hollomon)
    if numel(eps_p) < 3
        s = fit_nan('swift');
        return;
    end

    % Initial guess from Hollomon fit
    if ~isnan(hollomon.K)
        K_init = hollomon.K;
        n_init = hollomon.n;
    else
        K_init = max(sig_p);
        n_init = 0.2;
    end
    eps0_init = 0.01;

    x0 = [K_init, eps0_init, n_init];

    obj = @(x) sum((sig_p - x(1) * (x(2) + eps_p).^x(3)).^2);

    opts = optimset('Display', 'off', 'MaxFunEvals', 5000, 'MaxIter', 5000, 'TolFun', 1e-10, 'TolX', 1e-10);
    [x_opt, ~, exitflag] = fminsearch(obj, x0, opts);

    if exitflag <= 0
        s = fit_nan('swift');
        return;
    end

    K = x_opt(1);
    eps0 = x_opt(2);
    n = x_opt(3);

    predicted_full = K * (eps0 + true_strain).^n;
    predicted_plastic = K * (eps0 + eps_p).^n;
    r2 = compute_r2(sig_p, predicted_plastic, ss_tot);

    s = struct('K', K, 'eps0', eps0, 'n', n, 'R2', r2, 'predicted', predicted_full);
end
