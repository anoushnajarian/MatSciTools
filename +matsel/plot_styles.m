function styles = plot_styles(varargin)
%MATSEL.PLOT_STYLES Colorblind-friendly plot styling and publication export
%   STYLES = MATSEL.PLOT_STYLES() returns a struct with styling utilities:
%     colors     - 8-color Okabe-Ito colorblind-friendly palette (Nx3 matrix)
%     categories - struct mapping material categories to palette colors
%     markers    - struct mapping material categories to marker shapes
%     apply      - function handle: styles.apply(ax) formats axes for publication
%     journal    - function handle: styles.journal(fig) sets journal-ready defaults
%     export     - function handle: styles.export(fig, filepath, ...) saves figure
%
%   Optional Parameters:
%     'FontSize'  - Base font size (default: 12)
%     'LineWidth' - Default line width (default: 1.5)
%
%   Color Palette:
%     The Okabe-Ito palette is designed for 8 visually distinct colors that
%     remain distinguishable by people with color vision deficiency.
%
%   Export Presets:
%     'journal_single' - 8.5 cm wide (single column)
%     'journal_double' - 17.5 cm wide (double column)
%     'presentation'   - 25.4 cm wide (slide)
%
%   Example:
%     styles = matsel.plot_styles();
%     figure; plot(1:10, rand(1,10)); styles.apply(gca);
%     styles.export(gcf, 'my_plot.png', 'Preset', 'journal_single');
%
%     c = styles.colors;  % 8x3 matrix
%     plot(x, y, 'Color', c(1,:));  % blue
%     plot(x, z, 'Color', c(2,:));  % orange

    p = inputParser;
    addParameter(p, 'FontSize', 12, @isnumeric);
    addParameter(p, 'LineWidth', 1.5, @isnumeric);
    parse(p, varargin{:});
    opts = p.Results;

    % Okabe-Ito colorblind-friendly palette
    styles.colors = [ ...
        0.000 0.447 0.741;   % blue
        0.850 0.325 0.098;   % orange
        0.929 0.694 0.125;   % yellow
        0.494 0.184 0.556;   % purple
        0.466 0.674 0.188;   % green
        0.301 0.745 0.933;   % sky blue
        0.635 0.078 0.184;   % dark red
        0.000 0.000 0.000];  % black

    % Category-to-color mapping (for Ashby charts etc.)
    styles.categories = struct( ...
        'Metal',     [0.000 0.447 0.741], ...
        'Ceramic',   [0.850 0.325 0.098], ...
        'Polymer',   [0.466 0.674 0.188], ...
        'Composite', [0.929 0.694 0.125]);

    % Category-to-marker mapping
    styles.markers = struct( ...
        'Metal', 'o', 'Ceramic', 's', 'Polymer', 'd', 'Composite', '^');

    % Font size and line width defaults
    styles.font_size = opts.FontSize;
    styles.line_width = opts.LineWidth;

    % Apply publication formatting to axes
    styles.apply = @(ax) apply_style(ax, opts);

    % Apply journal-ready formatting to entire figure
    styles.journal = @(fig) apply_journal(fig);

    % Export figure function
    styles.export = @(fig, filepath, varargin) export_figure(fig, filepath, varargin{:});
end

function apply_style(ax, opts)
%APPLY_STYLE Format axes for publication-quality appearance
    set(ax, 'FontSize', opts.FontSize, ...
            'FontName', 'Arial', ...
            'LineWidth', 0.8, ...
            'Box', 'on', ...
            'TickDir', 'out');
    grid(ax, 'on');
    set(ax, 'GridAlpha', 0.15);

    % Thicken any lines thinner than the default
    lines = findobj(ax, 'Type', 'Line');
    for i = 1:numel(lines)
        if lines(i).LineWidth < opts.LineWidth
            lines(i).LineWidth = opts.LineWidth;
        end
    end
end

function apply_journal(fig)
%APPLY_JOURNAL Configure entire figure for journal submission
    set(fig, 'Color', 'w');
    allAx = findall(fig, 'Type', 'axes');
    for i = 1:numel(allAx)
        set(allAx(i), 'FontName', 'Arial', ...
                       'FontSize', 10, ...
                       'LineWidth', 0.75, ...
                       'TickDir', 'out', ...
                       'Box', 'on');
    end
end

function export_figure(fig, filepath, varargin)
%EXPORT_FIGURE Export figure in publication-quality format
%   Supports: PNG, TIFF (300 DPI), PDF, EPS, SVG
%   Presets: 'journal_single' (8.5cm), 'journal_double' (17.5cm), 'presentation' (25.4cm)

    ip = inputParser;
    addRequired(ip, 'fig');
    addRequired(ip, 'filepath', @(x) ischar(x)||isstring(x));
    addParameter(ip, 'DPI', 300, @isnumeric);
    addParameter(ip, 'Width', 0, @isnumeric);
    addParameter(ip, 'Height', 0, @isnumeric);
    addParameter(ip, 'Preset', 'none', @ischar);
    parse(ip, fig, filepath, varargin{:});
    eopts = ip.Results;

    % Apply preset dimensions (in cm)
    switch eopts.Preset
        case 'journal_single'
            eopts.Width = 8.5;
            eopts.Height = 6.5;
        case 'journal_double'
            eopts.Width = 17.5;
            eopts.Height = 10;
        case 'presentation'
            eopts.Width = 25.4;
            eopts.Height = 14.3;
    end

    % Apply dimensions if specified
    if eopts.Width > 0 && eopts.Height > 0
        set(fig, 'Units', 'centimeters');
        pos = get(fig, 'Position');
        set(fig, 'Position', [pos(1) pos(2) eopts.Width eopts.Height]);
        set(fig, 'PaperUnits', 'centimeters');
        set(fig, 'PaperSize', [eopts.Width eopts.Height]);
        set(fig, 'PaperPosition', [0 0 eopts.Width eopts.Height]);
    end

    [~, ~, ext] = fileparts(filepath);
    ext = lower(ext);

    switch ext
        case '.png'
            exportgraphics(fig, filepath, 'Resolution', eopts.DPI);
        case {'.tif', '.tiff'}
            exportgraphics(fig, filepath, 'Resolution', eopts.DPI);
        case '.pdf'
            exportgraphics(fig, filepath, 'ContentType', 'vector');
        case '.eps'
            exportgraphics(fig, filepath, 'ContentType', 'vector');
        case '.svg'
            print(fig, filepath, '-dsvg');
        otherwise
            exportgraphics(fig, filepath, 'Resolution', eopts.DPI);
    end
end
