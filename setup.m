function setup()
%SETUP Add MatSciTools directories to the MATLAB path
%   SETUP() adds the project root, tests, and examples to the MATLAB path.
%
%   Example:
%     setup();
%     run_all_tests();

    root = fileparts(mfilename('fullpath'));
    addpath(root);
    addpath(fullfile(root, 'tests'));
    addpath(fullfile(root, 'examples'));
    addpath(fullfile(root, 'data'));

    fprintf('MatSciTools paths added. Run matscitools() for info.\n');
end
