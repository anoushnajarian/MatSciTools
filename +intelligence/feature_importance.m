function results = feature_importance(target_prop, varargin)
%INTELLIGENCE.FEATURE_IMPORTANCE Rank property importance for predicting a target
%   RESULTS = INTELLIGENCE.FEATURE_IMPORTANCE(TARGET_PROP) analyzes which material
%   properties are most important for predicting TARGET_PROP using correlation
%   analysis and leave-one-out regression importance.
%
%   TARGET_PROP is the name of the target property to predict (e.g., 'yield_strength').
%
%   Optional Parameters:
%     'Properties'  - Cell array of candidate input properties (default: all numeric)
%     'Categories'  - Filter by material category (default: all)
%     'Method'      - 'correlation' (default), 'regression', or 'both'
%
%   Returns a struct with:
%     target        - Target property name
%     features      - Cell array of input feature names
%     importance    - Importance scores (sorted descending)
%     ranking       - Table with ranked features
%     method        - Method used
%
%   Example:
%     results = intelligence.feature_importance('yield_strength');
%     disp(results.ranking);
%
%     results = intelligence.feature_importance('uts', 'Method', 'both');

    p = inputParser;
    addRequired(p, 'target_prop', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Properties', {}, @iscell);
    addParameter(p, 'Categories', {}, @iscell);
    addParameter(p, 'Method', 'both', @(x) ismember(x, {'correlation','regression','both'}));
    parse(p, target_prop, varargin{:});
    opts = p.Results;

    % Load database
    db = matdb.search('density', [-Inf Inf]);

    if ~isempty(opts.Categories)
        mask = false(1, numel(db));
        for i = 1:numel(opts.Categories)
            mask = mask | strcmpi({db.category}, opts.Categories{i});
        end
        db = db(mask);
    end

    n = numel(db);

    % Default properties (excluding the target)
    allProps = {'density', 'youngs_modulus', 'yield_strength', 'uts', ...
        'elongation', 'hardness', 'thermal_conductivity', ...
        'thermal_expansion', 'melting_point', 'cost'};

    if ~isempty(opts.Properties)
        candidateProps = opts.Properties;
    else
        candidateProps = allProps;
    end

    % Remove target from candidates
    candidateProps = candidateProps(~strcmpi(candidateProps, target_prop));
    nFeatures = numel(candidateProps);

    % Build data matrix
    Y = zeros(n, 1);
    X = zeros(n, nFeatures);
    for i = 1:n
        Y(i) = db(i).(target_prop);
        for j = 1:nFeatures
            X(i, j) = db(i).(candidateProps{j});
        end
    end

    results = struct();
    results.target = target_prop;
    results.features = candidateProps;
    results.method = opts.Method;
    results.n_samples = n;

    % --- Correlation-based importance ---
    if strcmp(opts.Method, 'correlation') || strcmp(opts.Method, 'both')
        corrScores = zeros(1, nFeatures);
        for j = 1:nFeatures
            r = corrcoef(X(:, j), Y);
            corrScores(j) = abs(r(1, 2));
        end
        % Handle NaN correlations (constant features)
        corrScores(isnan(corrScores)) = 0;

        results.correlation_scores = corrScores;
        [sortedCorr, corrIdx] = sort(corrScores, 'descend');
        results.correlation_ranking = table( ...
            candidateProps(corrIdx)', sortedCorr', ...
            'VariableNames', {'Feature', 'AbsCorrelation'});
    end

    % --- Regression-based importance (drop-one-out) ---
    if strcmp(opts.Method, 'regression') || strcmp(opts.Method, 'both')
        % Baseline: linear regression with all features
        X_norm = normalize_features(X);
        baseRMSE = loo_rmse(X_norm, Y);

        regScores = zeros(1, nFeatures);
        for j = 1:nFeatures
            % Remove feature j and compute LOO RMSE
            X_reduced = X_norm;
            X_reduced(:, j) = [];
            reducedRMSE = loo_rmse(X_reduced, Y);
            % Importance = how much worse the model gets without this feature
            regScores(j) = max(0, (reducedRMSE - baseRMSE) / baseRMSE);
        end

        results.regression_scores = regScores;
        results.baseline_rmse = baseRMSE;
        [sortedReg, regIdx] = sort(regScores, 'descend');
        results.regression_ranking = table( ...
            candidateProps(regIdx)', sortedReg', ...
            'VariableNames', {'Feature', 'ImportanceScore'});
    end

    % --- Combined ranking ---
    if strcmp(opts.Method, 'both')
        % Normalize both score types to [0,1] and average
        normCorr = corrScores / max(max(corrScores), eps);
        normReg = regScores / max(max(regScores), eps);
        combined = 0.5 * normCorr + 0.5 * normReg;

        [sortedComb, combIdx] = sort(combined, 'descend');
        results.combined_scores = combined;
        results.ranking = table( ...
            candidateProps(combIdx)', sortedComb', ...
            corrScores(combIdx)', regScores(combIdx)', ...
            'VariableNames', {'Feature', 'CombinedScore', 'Correlation', 'RegressionImportance'});
        results.importance = sortedComb;
    elseif strcmp(opts.Method, 'correlation')
        results.importance = corrScores;
        results.ranking = results.correlation_ranking;
    else
        results.importance = regScores;
        results.ranking = results.regression_ranking;
    end
end

function X_norm = normalize_features(X)
%NORMALIZE_FEATURES Zero-mean, unit-variance normalization
    mu = mean(X, 1);
    s = std(X, 0, 1);
    s(s == 0) = 1;
    X_norm = (X - mu) ./ s;
end

function rmse = loo_rmse(X, Y)
%LOO_RMSE Leave-one-out cross-validated RMSE for linear regression
    n = size(X, 1);
    X_aug = [ones(n, 1), X];
    errors = zeros(n, 1);
    for i = 1:n
        trainIdx = [1:i-1, i+1:n];
        coeffs = X_aug(trainIdx, :) \ Y(trainIdx);
        errors(i) = Y(i) - X_aug(i, :) * coeffs;
    end
    rmse = sqrt(mean(errors.^2));
end
