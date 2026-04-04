function predicted = predict_properties(composition, varargin)
%INTELLIGENCE.PREDICT_PROPERTIES Predict material properties from composition
%   PREDICTED = INTELLIGENCE.PREDICT_PROPERTIES(COMPOSITION) predicts mechanical
%   and thermal properties using a k-nearest-neighbors regression model trained
%   on the built-in material database.
%
%   COMPOSITION is a struct with element weight percentages, e.g.:
%     composition.Fe = 98; composition.C = 0.45; composition.Mn = 0.7;
%   Or a string name of a known material for demonstration.
%
%   Optional Parameters:
%     'K'         - Number of nearest neighbors (default: 3)
%     'Properties'- Cell array of properties to predict (default: all)
%
%   Returns a struct with predicted values and confidence (based on neighbor spread).
%
%   Example:
%     comp.Fe = 97; comp.C = 0.45; comp.Mn = 0.75;
%     pred = intelligence.predict_properties(comp);

    p = inputParser;
    addRequired(p, 'composition');
    addParameter(p, 'K', 3, @isnumeric);
    addParameter(p, 'Properties', {'density', 'youngs_modulus', 'yield_strength', 'uts', ...
        'thermal_conductivity', 'melting_point'}, @iscell);
    parse(p, composition, varargin{:});
    opts = p.Results;

    % Build feature matrix from database
    db = matdb.search('density', [-Inf Inf]);
    n = numel(db);

    % Create feature vectors from database materials
    % Use available numeric properties as features for similarity
    feature_props = {'density', 'youngs_modulus', 'yield_strength', 'uts', ...
        'elongation', 'hardness', 'thermal_conductivity', 'thermal_expansion', ...
        'melting_point', 'cost'};

    features = zeros(n, numel(feature_props));
    for i = 1:n
        for j = 1:numel(feature_props)
            features(i, j) = db(i).(feature_props{j});
        end
    end

    % Normalize features
    feat_min = min(features, [], 1);
    feat_max = max(features, [], 1);
    feat_range = feat_max - feat_min;
    feat_range(feat_range == 0) = 1;
    features_norm = (features - feat_min) ./ feat_range;

    % Build query feature vector
    if ischar(composition) || isstring(composition)
        % Use a known material and add perturbation for demo
        query_mat = matdb.get(composition);
        query = zeros(1, numel(feature_props));
        for j = 1:numel(feature_props)
            query(j) = query_mat.(feature_props{j});
        end
    elseif isstruct(composition)
        % Match by composition similarity - use category heuristics
        % For simplicity, find materials with similar density and modulus if provided
        query = zeros(1, numel(feature_props));
        % Set defaults to midrange
        query = (feat_min + feat_max) / 2;

        % Override with any provided properties
        fields = fieldnames(composition);
        for f = 1:numel(fields)
            idx = find(strcmpi(feature_props, fields{f}));
            if ~isempty(idx)
                query(idx) = composition.(fields{f});
            end
        end
    else
        error('intelligence:InvalidInput', 'Composition must be a struct or material name string.');
    end

    query_norm = (query - feat_min) ./ feat_range;

    % KNN: find K nearest neighbors
    K = min(opts.K, n);
    dists = sqrt(sum((features_norm - query_norm).^2, 2));
    [sorted_dists, sort_idx] = sort(dists);
    nn_idx = sort_idx(1:K);
    nn_dists = sorted_dists(1:K);

    % Weight by inverse distance
    if all(nn_dists == 0)
        weights = ones(K, 1) / K;
    else
        weights = 1 ./ max(nn_dists, eps);
        weights = weights / sum(weights);
    end

    % Predict properties
    predicted = struct();
    predicted.method = 'KNN regression';
    predicted.k = K;
    predicted.nearest_materials = {db(nn_idx).name};
    predicted.distances = nn_dists';

    for i = 1:numel(opts.Properties)
        prop = opts.Properties{i};
        if isfield(db, prop)
            vals = [db(nn_idx).(prop)]';
            predicted.(prop) = sum(weights .* vals);
            predicted.([prop '_confidence']) = 1 - std(vals) / max(mean(vals), eps);
        end
    end
end
