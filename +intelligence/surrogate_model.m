function model = surrogate_model(input_props, output_prop, varargin)
%INTELLIGENCE.SURROGATE_MODEL Build a polynomial surrogate model for property prediction
%   MODEL = INTELLIGENCE.SURROGATE_MODEL(INPUT_PROPS, OUTPUT_PROP) builds a
%   regression model mapping input properties to an output property using the
%   built-in material database.
%
%   INPUT_PROPS is a cell array of input property names.
%   OUTPUT_PROP is the target property name.
%
%   Optional Parameters:
%     'Degree'     - Polynomial degree (default: 2)
%     'Categories' - Filter by material category (default: all)
%     'Validate'   - Leave-one-out cross-validation (default: true)
%
%   Returns a struct with:
%     coefficients - Polynomial fit coefficients
%     r_squared    - R² value on training data
%     rmse         - Root mean square error
%     cv_rmse      - Leave-one-out cross-validation RMSE
%     predict      - Function handle: model.predict(values)
%
%   Example:
%     model = intelligence.surrogate_model({'density', 'youngs_modulus'}, 'yield_strength');
%     predicted_ys = model.predict([2700, 70]); % Al-like material

    p = inputParser;
    addRequired(p, 'input_props', @iscell);
    addRequired(p, 'output_prop', @(x) ischar(x)||isstring(x));
    addParameter(p, 'Degree', 2, @isnumeric);
    addParameter(p, 'Categories', {}, @iscell);
    addParameter(p, 'Validate', true, @islogical);
    parse(p, input_props, output_prop, varargin{:});
    opts = p.Results;

    % Get data
    db = matdb.search('density', [-Inf Inf]);

    if ~isempty(opts.Categories)
        mask = false(1, numel(db));
        for i = 1:numel(opts.Categories)
            mask = mask | strcmpi({db.category}, opts.Categories{i});
        end
        db = db(mask);
    end

    n = numel(db);
    n_inputs = numel(input_props);

    % Build matrices
    X = zeros(n, n_inputs);
    Y = zeros(n, 1);
    for i = 1:n
        for j = 1:n_inputs
            X(i, j) = db(i).(input_props{j});
        end
        Y(i) = db(i).(output_prop);
    end

    % Normalize inputs for numerical stability
    X_mean = mean(X, 1);
    X_std = std(X, 0, 1);
    X_std(X_std == 0) = 1;
    X_norm = (X - X_mean) ./ X_std;

    % Build polynomial features
    X_poly = build_poly_features(X_norm, opts.Degree);

    % Least squares fit
    coeffs = X_poly \ Y;
    Y_pred = X_poly * coeffs;

    % Metrics
    ss_res = sum((Y - Y_pred).^2);
    ss_tot = sum((Y - mean(Y)).^2);
    r_squared = 1 - ss_res / ss_tot;
    rmse = sqrt(mean((Y - Y_pred).^2));

    % Leave-one-out cross-validation
    cv_rmse = NaN;
    if opts.Validate && n > 3
        cv_errors = zeros(n, 1);
        for i = 1:n
            train_idx = [1:i-1, i+1:n];
            X_train = X_poly(train_idx, :);
            Y_train = Y(train_idx);
            c_cv = X_train \ Y_train;
            cv_errors(i) = Y(i) - X_poly(i, :) * c_cv;
        end
        cv_rmse = sqrt(mean(cv_errors.^2));
    end

    % Build model struct
    model = struct();
    model.input_props = input_props;
    model.output_prop = output_prop;
    model.coefficients = coeffs;
    model.degree = opts.Degree;
    model.r_squared = r_squared;
    model.rmse = rmse;
    model.cv_rmse = cv_rmse;
    model.n_samples = n;
    model.X_mean = X_mean;
    model.X_std = X_std;

    % Create prediction function
    model.predict = @(x_new) predict_fn(x_new, coeffs, X_mean, X_std, opts.Degree);
end

function y = predict_fn(x_new, coeffs, X_mean, X_std, degree)
    x_norm = (x_new - X_mean) ./ X_std;
    X_poly = build_poly_features(x_norm, degree);
    y = X_poly * coeffs;
end

function X_poly = build_poly_features(X, degree)
    [n, p] = size(X);
    % Start with bias + linear terms
    X_poly = [ones(n, 1), X];

    if degree >= 2
        % Add quadratic terms (x_i^2 and x_i*x_j)
        for i = 1:p
            X_poly = [X_poly, X(:,i).^2]; %#ok<AGROW>
            for j = i+1:p
                X_poly = [X_poly, X(:,i).*X(:,j)]; %#ok<AGROW>
            end
        end
    end

    if degree >= 3
        % Add cubic terms (x_i^3)
        for i = 1:p
            X_poly = [X_poly, X(:,i).^3]; %#ok<AGROW>
        end
    end
end
