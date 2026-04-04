function compile_standalone(varargin)
%COMPILE_STANDALONE Build standalone MatSciTools application or toolbox package
%   COMPILE_STANDALONE() compiles the MatSciTools GUI into a standalone
%   executable that can run without a MATLAB license (requires MATLAB Runtime).
%
%   COMPILE_STANDALONE('Mode', 'toolbox') packages as a .mltbx toolbox
%   installer that works on Windows, macOS, and Linux (requires MATLAB).
%
%   Optional Parameters:
%     'Mode'       - 'standalone' (default) or 'toolbox'
%     'OutputDir'  - Output directory (default: 'build')
%     'AppName'    - Name of the application (default: 'MatSciTools')
%     'Verbose'    - Show detailed compiler output (default: true)
%     'Icon'       - Path to application icon file (default: '')
%
%   Standalone mode:
%     - Requires MATLAB Compiler toolbox
%     - Produces a platform-specific executable (.exe on Windows, .app on macOS)
%     - End users need the free MATLAB Runtime
%     - Cannot cross-compile: build on each target platform
%
%   Toolbox mode:
%     - No extra toolbox required
%     - Produces a cross-platform .mltbx installer
%     - End users install via MATLAB Add-On Explorer (double-click .mltbx)
%     - Works on Windows, macOS, and Linux
%
%   Example:
%     compile_standalone();                          % standalone exe
%     compile_standalone('Mode', 'toolbox');          % cross-platform .mltbx
%     compile_standalone('OutputDir', 'dist');

    p = inputParser;
    addParameter(p, 'Mode', 'standalone', @(x) ismember(x, {'standalone','toolbox'}));
    addParameter(p, 'OutputDir', 'build', @ischar);
    addParameter(p, 'AppName', 'MatSciTools', @ischar);
    addParameter(p, 'Verbose', true, @islogical);
    addParameter(p, 'Icon', '', @ischar);
    parse(p, varargin{:});
    opts = p.Results;

    fprintf('\n');
    fprintf('  MatSciTools Build System\n');
    fprintf('  ========================\n\n');

    root = fileparts(mfilename('fullpath'));
    addpath(root);
    addpath(fullfile(root, 'tests'));
    addpath(fullfile(root, 'examples'));
    addpath(fullfile(root, 'data'));

    outDir = fullfile(root, opts.OutputDir);
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    if strcmp(opts.Mode, 'toolbox')
        build_toolbox(root, outDir, opts);
    else
        build_standalone(root, outDir, opts);
    end
end

%% ========== STANDALONE BUILD ==========

function build_standalone(root, outDir, opts)
    fprintf('  Mode: Standalone executable\n');
    fprintf('  Platform: %s\n', computer);

    if ismac
        fprintf('  Target: macOS .app bundle\n');
    elseif ispc
        fprintf('  Target: Windows .exe\n');
    else
        fprintf('  Target: Linux executable\n');
    end
    fprintf('\n');

    if ~check_compiler()
        return;
    end

    fprintf('  Output directory: %s\n', outDir);
    fprintf('  Application name: %s\n\n', opts.AppName);

    fprintf('  Collecting source files...\n');
    sourceFiles = collect_sources(root);
    fprintf('    Found %d source files\n', numel(sourceFiles));

    fprintf('  Collecting data files...\n');
    dataFiles = collect_data(root);
    fprintf('    Found %d data files\n', numel(dataFiles));

    entryPoint = fullfile(outDir, 'matscitools_app.m');
    create_entry_point(entryPoint);
    fprintf('  Created entry point: %s\n', entryPoint);

    mccArgs = {'-m', entryPoint, '-d', outDir, '-o', opts.AppName};

    for i = 1:numel(sourceFiles)
        mccArgs{end+1} = '-a'; %#ok<AGROW>
        mccArgs{end+1} = sourceFiles{i}; %#ok<AGROW>
    end

    for i = 1:numel(dataFiles)
        mccArgs{end+1} = '-a'; %#ok<AGROW>
        mccArgs{end+1} = dataFiles{i}; %#ok<AGROW>
    end

    if ~isempty(opts.Icon) && exist(opts.Icon, 'file')
        mccArgs{end+1} = '-e';
    end

    if opts.Verbose
        mccArgs{end+1} = '-v';
    end

    fprintf('\n  Compiling (this may take several minutes)...\n\n');
    try
        mcc(mccArgs{:});

        if ismac
            exeName = [opts.AppName '.app'];
        elseif ispc
            exeName = [opts.AppName '.exe'];
        else
            exeName = opts.AppName;
        end

        fprintf('\n  ========================================\n');
        fprintf('  Compilation SUCCESSFUL!\n');
        fprintf('  ========================================\n\n');
        fprintf('  Executable: %s\n\n', fullfile(outDir, exeName));
        fprintf('  To distribute:\n');
        fprintf('    1. Share the executable with end users\n');
        fprintf('    2. Users must install MATLAB Runtime (free)\n');
        fprintf('    3. Runtime version: R%s\n', version('-release'));
        fprintf('    4. Download: mathworks.com/products/compiler/mcr\n\n');

        if ismac || isunix
            fprintf('  NOTE: This executable only runs on %s.\n', computer);
            fprintf('  To build for other platforms, run compile_standalone()\n');
            fprintf('  on each target OS, or use ''Mode'',''toolbox'' for a\n');
            fprintf('  cross-platform .mltbx package.\n\n');
        end
    catch ex
        fprintf('\n  Compilation FAILED:\n');
        fprintf('    %s\n\n', ex.message);
        fprintf('  Troubleshooting:\n');
        fprintf('    - Ensure MATLAB Compiler is installed: ver(''compiler'')\n');
        fprintf('    - Check all source files are on the path\n');
        fprintf('    - Run setup() before compiling\n');
    end

    if exist(entryPoint, 'file')
        delete(entryPoint);
    end
end

%% ========== TOOLBOX BUILD ==========

function build_toolbox(root, outDir, opts)
    fprintf('  Mode: Cross-platform MATLAB Toolbox (.mltbx)\n');
    fprintf('  Output directory: %s\n\n', outDir);

    % Create toolbox packaging descriptor (prj-like struct)
    toolboxName = opts.AppName;
    toolboxVersion = '1.0';
    mltbxFile = fullfile(outDir, [toolboxName '.mltbx']);

    % Collect all files to package
    fprintf('  Collecting files...\n');
    sourceFiles = collect_sources(root);
    dataFiles = collect_data(root);
    fprintf('    %d source files, %d data files\n', numel(sourceFiles), numel(dataFiles));

    % Create a toolbox options descriptor
    descFile = fullfile(outDir, 'ToolboxPackagingConfiguration.prj');
    create_toolbox_prj(descFile, root, toolboxName, toolboxVersion);

    % Use matlab.addons.toolbox API if available (R2016b+)
    try
        tbxOpts = matlab.addons.toolbox.ToolboxOptions(root, ...
            matlab.lang.makeValidName(toolboxName));
        tbxOpts.ToolboxName = toolboxName;
        tbxOpts.ToolboxVersion = toolboxVersion;
        tbxOpts.Summary = 'Material Science Engineering Toolkit for MATLAB';
        tbxOpts.Description = [ ...
            'MatSciTools provides an integrated suite of tools for material science: ', ...
            'property database (57 materials), Ashby charts, mechanical testing, ', ...
            'phase diagrams, microstructure analysis, XRD, ML intelligence, and GUI.'];
        tbxOpts.AuthorName = 'Anoush Najarian, David Shepherd';
        tbxOpts.OutputFile = mltbxFile;

        % Add package directories
        tbxOpts.ToolboxMatlabPath = {root};
        packages = {'+matdb', '+matsel', '+mechtest', '+phasediag', ...
            '+microstructure', '+intelligence', '+xrd', '+gui', '+standards'};
        for i = 1:numel(packages)
            pkgDir = fullfile(root, packages{i});
            if exist(pkgDir, 'dir')
                tbxOpts.ToolboxMatlabPath{end+1} = pkgDir;
            end
        end

        matlab.addons.toolbox.packageToolbox(tbxOpts);

        fprintf('\n  ========================================\n');
        fprintf('  Toolbox Packaging SUCCESSFUL!\n');
        fprintf('  ========================================\n\n');
        fprintf('  Toolbox: %s\n\n', mltbxFile);
        fprintf('  To install (any platform):\n');
        fprintf('    1. Double-click %s.mltbx in MATLAB\n', toolboxName);
        fprintf('    2. Or: matlab.addons.toolbox.installToolbox(''%s'')\n', mltbxFile);
        fprintf('    3. Works on Windows, macOS, and Linux\n');
        fprintf('    4. Requires MATLAB R2020a+ (no Compiler needed)\n\n');
    catch ex
        % Fallback: create a zip-based distribution
        fprintf('  matlab.addons.toolbox API unavailable, creating zip package...\n');
        create_zip_package(root, outDir, toolboxName, sourceFiles, dataFiles);
    end

    % Clean up temp files
    if exist(descFile, 'file')
        delete(descFile);
    end
end

function create_zip_package(root, outDir, toolboxName, ~, ~)
%CREATE_ZIP_PACKAGE Fallback: zip all files for manual distribution
    zipFile = fullfile(outDir, [toolboxName '.zip']);

    % Zip directories relative to root to preserve package structure
    items = {'+matdb', '+matsel', '+mechtest', '+phasediag', ...
        '+microstructure', '+intelligence', '+xrd', '+gui', '+standards', ...
        'data', 'matscitools.m', 'setup.m', 'README.md'};
    toZip = {};
    for i = 1:numel(items)
        f = fullfile(root, items{i});
        if exist(f, 'file') || exist(f, 'dir')
            toZip{end+1} = f; %#ok<AGROW>
        end
    end

    zip(zipFile, toZip, root);

    fprintf('\n  ========================================\n');
    fprintf('  Zip Package Created!\n');
    fprintf('  ========================================\n\n');
    fprintf('  Package: %s\n\n', zipFile);
    fprintf('  To install:\n');
    fprintf('    1. Unzip to a folder\n');
    fprintf('    2. Run setup() in MATLAB\n');
    fprintf('    3. Works on Windows, macOS, and Linux\n');
    fprintf('    4. Requires MATLAB R2020a+\n\n');
end

%% ========== SHARED HELPERS ==========

function ok = check_compiler()
    ok = false;
    v = ver('compiler');
    if isempty(v)
        fprintf('  ERROR: MATLAB Compiler is not installed.\n');
        fprintf('  Install it from the Add-On Explorer or mathworks.com.\n\n');
        fprintf('  Alternative: use ''Mode'',''toolbox'' to create a cross-platform\n');
        fprintf('  .mltbx package that doesn''t require MATLAB Compiler.\n\n');
        return;
    end
    fprintf('  MATLAB Compiler v%s detected\n', v.Version);
    ok = true;
end

function files = collect_sources(root)
    packages = {'+matdb', '+matsel', '+mechtest', '+phasediag', ...
        '+microstructure', '+intelligence', '+xrd', '+gui', '+standards'};
    files = {};
    for i = 1:numel(packages)
        pkgDir = fullfile(root, packages{i});
        if exist(pkgDir, 'dir')
            d = dir(fullfile(pkgDir, '*.m'));
            for j = 1:numel(d)
                files{end+1} = fullfile(pkgDir, d(j).name); %#ok<AGROW>
            end
        end
    end
    rootFiles = {'matscitools.m', 'setup.m'};
    for i = 1:numel(rootFiles)
        f = fullfile(root, rootFiles{i});
        if exist(f, 'file')
            files{end+1} = f; %#ok<AGROW>
        end
    end
end

function files = collect_data(root)
    dataDir = fullfile(root, 'data');
    files = {};
    if ~exist(dataDir, 'dir')
        return;
    end
    exts = {'*.mat', '*.csv', '*.json'};
    for i = 1:numel(exts)
        d = dir(fullfile(dataDir, exts{i}));
        for j = 1:numel(d)
            files{end+1} = fullfile(dataDir, d(j).name); %#ok<AGROW>
        end
    end
end

function create_entry_point(filepath)
    fid = fopen(filepath, 'w');
    fprintf(fid, 'function matscitools_app()\n');
    fprintf(fid, '%%MATSCITOOLS_APP Entry point for standalone MatSciTools application\n');
    fprintf(fid, '    try\n');
    fprintf(fid, '        app = gui.MatSciApp();\n');
    fprintf(fid, '        waitfor(app.UIFigure);\n');
    fprintf(fid, '    catch ex\n');
    fprintf(fid, '        errordlg(sprintf(''MatSciTools Error:\\n%%s'', ex.message), ...\n');
    fprintf(fid, '            ''MatSciTools'', ''modal'');\n');
    fprintf(fid, '    end\n');
    fprintf(fid, 'end\n');
    fclose(fid);
end

function create_toolbox_prj(filepath, root, name, version)
%CREATE_TOOLBOX_PRJ Write a minimal toolbox packaging configuration
    fid = fopen(filepath, 'w');
    fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fid, '<deployment-project plugin="plugin.toolbox">\n');
    fprintf(fid, '  <configuration name="%s" target="target.toolbox">\n', name);
    fprintf(fid, '    <param.appname>%s</param.appname>\n', name);
    fprintf(fid, '    <param.version>%s</param.version>\n', version);
    fprintf(fid, '    <param.summary>Material Science Engineering Toolkit</param.summary>\n');
    fprintf(fid, '    <param.rootDir>%s</param.rootDir>\n', root);
    fprintf(fid, '  </configuration>\n');
    fprintf(fid, '</deployment-project>\n');
    fclose(fid);
end
