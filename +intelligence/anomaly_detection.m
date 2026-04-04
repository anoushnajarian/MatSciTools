function results = anomaly_detection(varargin)
%INTELLIGENCE.ANOMALY_DETECTION Detect anomalous materials using Mahalanobis distance
%   RESULTS = INTELLIGENCE.ANOMALY_DETECTION() analyzes all materials in the
%   database and identifies statistical outliers based on their property vectors.
%
%   Optional Parameters:
%     'Properties'  - Cell array of properties to use (default: mechanical+thermal)
%     'Threshold'   - Mahalanobis distance threshold for anomaly (default: 3.0)
%     'Categories'  - Filter by category (default: all)
%     'Material'    - Check a specific material (returns its anomaly score)
%
%   Returns a struct with:
%     materials     - Cell array of all material names
%     distances     - Mahalanobis distance for each material
%     is_anomaly    - Logical vector (true = anomalous)
%     threshold     - Threshold used
%     anomalies     - Table of detected anomalies with details
%     rankings      - Table of all materials sorted by distance (most anomalous first)
%
%   Example:
%     results = intelligence.anomaly_detection();
%     disp(results.anomalies);
%
%     results = intelligence.anomaly_detection('Material', 'PTFE');
%     fprintf('Anomaly score: %.2f\n', results.score);

    p = inputParser;
    addParameter(p, 'Properties', {'density', 'youngs_modulus', 'yield_strength', ...
        'uts', 'elongation', 'hardness', 'thermal_conductivity', ...
        'thermal_expansion', 'melting_point'}, @iscell);
    addParameter(p, 'Threshold', 3.0, @isnumeric);
    addParameter(p, 'Categories', {}, @iscell);
    addParameter(p, 'Material', '', @(x) ischar(x)||isstring(x));
    parse(p, varargin{:});
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
    props = opts.Properties;
    nProps = numel(props);

    % Build feature matrix
    X = zeros(n, nProps);
    for i = 1:n
        for j = 1:nProps
            X(i, j) = db(i).(props{j});
        end
    end

    % Compute mean and covariance
    mu = mean(X, 1);
    C = cov(X);

    % Regularize covariance if near-singular
    eigVals = eig(C);
    if min(eigVals) < 1e-10 * max(eigVals)
        C = C + eye(nProps) * max(eigVals) * 1e-6;
    end

    % Compute Mahalanobis distance for each material
    C_inv = inv(C); %#ok<MINV>
    distances = zeros(n, 1);
    for i = 1:n
        diff = X(i, :) - mu;
        distances(i) = sqrt(diff * C_inv * diff');
    end

    % Single material mode
    if ~isempty(opts.Material)
        results = struct();
        idx = find(strcmpi({db.name}, opts.Material), 1);
        if isempty(idx)
            try
                mat = matdb.get(opts.Material);
                queryVec = zeros(1, nProps);
                for j = 1:nProps
                    queryVec(j) = mat.(props{j});
                end
                diff = queryVec - mu;
                results.score = sqrt(diff * C_inv * diff');
                results.is_anomaly = results.score > opts.Threshold;
                results.material = opts.Material;
                results.threshold = opts.Threshold;

                % Identify which properties contribute most
                contributions = zeros(1, nProps);
                stdX = std(X, 0, 1);
                stdX(stdX == 0) = 1;
                for j = 1:nProps
                    contributions(j) = abs(queryVec(j) - mu(j)) / stdX(j);
                end
                [~, contribIdx] = sort(contributions, 'descend');
                results.top_deviations = cell(min(3, nProps), 2);
                for k = 1:min(3, nProps)
                    j = contribIdx(k);
                    results.top_deviations{k, 1} = props{j};
                    results.top_deviations{k, 2} = contributions(j);
                end
            catch
                error('intelligence:InvalidMaterial', 'Material "%s" not found.', opts.Material);
            end
        else
            results.score = distances(idx);
            results.is_anomaly = distances(idx) > opts.Threshold;
            results.material = opts.Material;
            results.threshold = opts.Threshold;

            % Property deviations
            stdX = std(X, 0, 1);
            stdX(stdX == 0) = 1;
            contributions = abs(X(idx, :) - mu) ./ stdX;
            [~, contribIdx] = sort(contributions, 'descend');
            results.top_deviations = cell(min(3, nProps), 2);
            for k = 1:min(3, nProps)
                j = contribIdx(k);
                results.top_deviations{k, 1} = props{j};
                results.top_deviations{k, 2} = contributions(j);
            end
        end
        return;
    end

    % Full database analysis
    isAnomaly = distances > opts.Threshold;

    results = struct();
    results.materials = {db.name}';
    results.distances = distances;
    results.is_anomaly = isAnomaly;
    results.threshold = opts.Threshold;
    results.n_anomalies = sum(isAnomaly);

    % Anomalies table
    anomIdx = find(isAnomaly);
    if ~isempty(anomIdx)
        anomNames = {db(anomIdx).name}';
        anomCats = {db(anomIdx).category}';
        anomDists = distances(anomIdx);
        results.anomalies = table(anomNames, anomCats, anomDists, ...
            'VariableNames', {'Name', 'Category', 'MahalanobisDistance'});
        results.anomalies = sortrows(results.anomalies, 'MahalanobisDistance', 'descend');
    else
        results.anomalies = table();
    end

    % Full ranking
    [sortedDist, sortIdx] = sort(distances, 'descend');
    rankNames = {db(sortIdx).name}';
    rankCats = {db(sortIdx).category}';
    results.rankings = table(rankNames, rankCats, sortedDist, ...
        'VariableNames', {'Name', 'Category', 'MahalanobisDistance'});
end
