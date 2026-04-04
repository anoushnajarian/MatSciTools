function results = cluster_materials(varargin)
%INTELLIGENCE.CLUSTER_MATERIALS Cluster materials by properties using k-means
%   RESULTS = INTELLIGENCE.CLUSTER_MATERIALS() groups materials into clusters
%   based on their normalized property vectors using k-means clustering.
%
%   Optional Parameters:
%     'K'           - Number of clusters (default: 4)
%     'Properties'  - Cell array of properties to use (default: mechanical+thermal)
%     'Categories'  - Filter by material category (default: all)
%     'MaxIter'     - Maximum k-means iterations (default: 100)
%
%   Returns a struct with:
%     labels         - Cluster assignment for each material (1..K)
%     centroids      - K x nProps matrix of cluster centroids (normalized)
%     materials      - Cell array of material names
%     cluster_table  - Table with Name, Category, Cluster columns
%     clusters       - Cell array of K cells, each listing material names in that cluster
%     silhouette     - Mean silhouette coefficient (cluster quality, higher is better)
%     inertia        - Sum of squared distances to centroids (within-cluster variance)
%
%   Example:
%     results = intelligence.cluster_materials('K', 5);
%     disp(results.cluster_table);
%
%     results = intelligence.cluster_materials('Properties', {'density', 'youngs_modulus'});

    p = inputParser;
    addParameter(p, 'K', 4, @isnumeric);
    addParameter(p, 'Properties', {'density', 'youngs_modulus', 'yield_strength', ...
        'uts', 'elongation', 'hardness', 'thermal_conductivity', ...
        'thermal_expansion', 'melting_point'}, @iscell);
    addParameter(p, 'Categories', {}, @iscell);
    addParameter(p, 'MaxIter', 100, @isnumeric);
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
    K = min(opts.K, n);
    props = opts.Properties;
    nProps = numel(props);

    % Build feature matrix
    X = zeros(n, nProps);
    for i = 1:n
        for j = 1:nProps
            X(i, j) = db(i).(props{j});
        end
    end

    % Normalize features
    mu = mean(X, 1);
    s = std(X, 0, 1);
    s(s == 0) = 1;
    X_norm = (X - mu) ./ s;

    % K-means clustering (implemented from scratch, no toolbox)
    [labels, centroids, inertia] = kmeans_fit(X_norm, K, opts.MaxIter);

    % Compute silhouette coefficient
    silCoeffs = compute_silhouette(X_norm, labels, K);
    meanSil = mean(silCoeffs);

    % Build output
    results = struct();
    results.labels = labels;
    results.centroids = centroids;
    results.materials = {db.name}';
    results.properties = props;
    results.n_clusters = K;
    results.silhouette = meanSil;
    results.inertia = inertia;

    % Cluster table
    names = {db.name}';
    cats = {db.category}';
    results.cluster_table = table(names, cats, labels, ...
        'VariableNames', {'Name', 'Category', 'Cluster'});
    results.cluster_table = sortrows(results.cluster_table, 'Cluster');

    % Materials per cluster
    results.clusters = cell(K, 1);
    for k = 1:K
        clusterIdx = find(labels == k);
        results.clusters{k} = {db(clusterIdx).name};
    end

    % Cluster summary
    results.cluster_summary = cell(K, 1);
    for k = 1:K
        clusterIdx = find(labels == k);
        summary = struct();
        summary.size = numel(clusterIdx);
        summary.categories = unique({db(clusterIdx).category});
        summary.materials = {db(clusterIdx).name};
        % Mean properties (original scale)
        for j = 1:nProps
            vals = X(clusterIdx, j);
            summary.(sprintf('mean_%s', props{j})) = mean(vals);
        end
        results.cluster_summary{k} = summary;
    end
end

function [labels, centroids, inertia] = kmeans_fit(X, K, maxIter)
%KMEANS_FIT K-means clustering without toolbox dependency
    [n, p] = size(X);

    % Initialize centroids using k-means++ strategy
    centroids = zeros(K, p);
    centroids(1, :) = X(randi(n), :);
    for k = 2:K
        dists = inf(n, 1);
        for j = 1:k-1
            d = sum((X - centroids(j, :)).^2, 2);
            dists = min(dists, d);
        end
        probs = dists / sum(dists);
        cumProbs = cumsum(probs);
        r = rand();
        idx = find(cumProbs >= r, 1, 'first');
        centroids(k, :) = X(idx, :);
    end

    labels = zeros(n, 1);

    for iter = 1:maxIter
        % Assignment step
        newLabels = zeros(n, 1);
        for i = 1:n
            minDist = Inf;
            for k = 1:K
                d = sum((X(i, :) - centroids(k, :)).^2);
                if d < minDist
                    minDist = d;
                    newLabels(i) = k;
                end
            end
        end

        % Check convergence
        if isequal(newLabels, labels)
            break;
        end
        labels = newLabels;

        % Update step
        for k = 1:K
            members = X(labels == k, :);
            if ~isempty(members)
                centroids(k, :) = mean(members, 1);
            end
        end
    end

    % Compute inertia
    inertia = 0;
    for i = 1:n
        inertia = inertia + sum((X(i, :) - centroids(labels(i), :)).^2);
    end
end

function silCoeffs = compute_silhouette(X, labels, K)
%COMPUTE_SILHOUETTE Silhouette coefficient for each data point
    n = size(X, 1);
    silCoeffs = zeros(n, 1);

    for i = 1:n
        myCluster = labels(i);

        % a(i) = mean distance to same-cluster points
        sameIdx = find(labels == myCluster);
        sameIdx = sameIdx(sameIdx ~= i);
        if isempty(sameIdx)
            silCoeffs(i) = 0;
            continue;
        end
        a_i = mean(sqrt(sum((X(sameIdx, :) - X(i, :)).^2, 2)));

        % b(i) = min mean distance to other-cluster points
        b_i = Inf;
        for k = 1:K
            if k == myCluster, continue; end
            otherIdx = find(labels == k);
            if isempty(otherIdx), continue; end
            meanDist = mean(sqrt(sum((X(otherIdx, :) - X(i, :)).^2, 2)));
            b_i = min(b_i, meanDist);
        end

        if isinf(b_i)
            silCoeffs(i) = 0;
        else
            silCoeffs(i) = (b_i - a_i) / max(a_i, b_i);
        end
    end
end
