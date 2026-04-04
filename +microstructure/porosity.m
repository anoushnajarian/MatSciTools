function results = porosity(img, varargin)
%MICROSTRUCTURE.POROSITY Calculate porosity from a microstructure image
%   RESULTS = MICROSTRUCTURE.POROSITY(IMG) measures the area fraction of pores.
%
%   Pores are assumed to be dark regions in the image. The threshold separates
%   pore pixels from matrix pixels.
%
%   Optional Parameters:
%     'Threshold'  - Binarization threshold (0-1), default: auto (Otsu's method)
%     'MinPoreSize'- Minimum pore size in pixels to count (default: 5)
%     'ShowPlot'   - Display analysis visualization (default: false)
%
%   Returns a struct with:
%     porosity_percent  - Area fraction of pores (%)
%     num_pores         - Number of detected pores
%     mean_pore_area    - Mean pore area (pixels)
%     total_pore_area   - Total pore area (pixels)
%     image_area        - Total image area (pixels)
%
%   Example:
%     results = microstructure.porosity('sample.png');

    p = inputParser;
    addRequired(p, 'img');
    addParameter(p, 'Threshold', [], @isnumeric);
    addParameter(p, 'MinPoreSize', 5, @isnumeric);
    addParameter(p, 'ShowPlot', false, @islogical);
    parse(p, img, varargin{:});
    opts = p.Results;

    % Load image if filename
    if ischar(img) || isstring(img)
        if ~isfile(img)
            error('microstructure:FileNotFound', 'Image file not found: %s', img);
        end
        img = imread(img);
    end

    % Convert to grayscale
    if size(img, 3) == 3
        img = uint8(0.2989*double(img(:,:,1)) + 0.5870*double(img(:,:,2)) + 0.1140*double(img(:,:,3)));
    end
    img_norm = double(img) / double(max(img(:)));

    % Threshold
    if isempty(opts.Threshold)
        % Otsu's method
        counts = histcounts(img_norm(:), 256);
        total = numel(img_norm);
        counts = counts / total;
        bins = linspace(0, 1, 256);
        best_t = 0.5; best_var = 0;
        for i = 1:255
            w0 = sum(counts(1:i)); w1 = 1 - w0;
            if w0 == 0 || w1 == 0, continue; end
            mu0 = sum(bins(1:i).*counts(1:i))/w0;
            mu1 = sum(bins(i+1:256).*counts(i+1:256))/w1;
            v = w0*w1*(mu0-mu1)^2;
            if v > best_var, best_var = v; best_t = bins(i); end
        end
        thresh = best_t;
    else
        thresh = opts.Threshold;
    end

    % Pores are dark (below threshold)
    pore_mask = img_norm < thresh;

    % Connected component labeling (simple flood-fill)
    labeled = label_components(pore_mask);
    num_labels = max(labeled(:));

    % Filter by minimum pore size
    pore_areas = [];
    filtered_mask = false(size(pore_mask));
    for k = 1:num_labels
        area = sum(labeled(:) == k);
        if area >= opts.MinPoreSize
            pore_areas(end+1) = area; %#ok<AGROW>
            filtered_mask = filtered_mask | (labeled == k);
        end
    end

    results = struct();
    results.image_area = numel(img_norm);
    results.total_pore_area = sum(filtered_mask(:));
    results.porosity_percent = results.total_pore_area / results.image_area * 100;
    results.num_pores = numel(pore_areas);
    if results.num_pores > 0
        results.mean_pore_area = mean(pore_areas);
    else
        results.mean_pore_area = 0;
    end

    if opts.ShowPlot
        figure('Name', 'Porosity Analysis', 'NumberTitle', 'off');
        subplot(1,2,1); imagesc(img_norm); colormap(gray); axis image;
        title('Original Image');
        subplot(1,2,2); imagesc(filtered_mask); colormap(gray); axis image;
        title(sprintf('Pores: %.2f%%', results.porosity_percent));
    end
end

function labeled = label_components(bw)
%LABEL_COMPONENTS Simple connected component labeling (4-connectivity)
    [rows, cols] = size(bw);
    labeled = zeros(rows, cols);
    current_label = 0;
    for r = 1:rows
        for c = 1:cols
            if bw(r,c) && labeled(r,c) == 0
                current_label = current_label + 1;
                % BFS flood fill
                queue = [r, c];
                labeled(r, c) = current_label;
                head = 1;
                while head <= size(queue, 1)
                    cr = queue(head, 1); cc = queue(head, 2);
                    head = head + 1;
                    neighbors = [cr-1,cc; cr+1,cc; cr,cc-1; cr,cc+1];
                    for n = 1:4
                        nr = neighbors(n,1); nc = neighbors(n,2);
                        if nr>=1 && nr<=rows && nc>=1 && nc<=cols && bw(nr,nc) && labeled(nr,nc)==0
                            labeled(nr, nc) = current_label;
                            queue(end+1, :) = [nr, nc]; %#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
end
