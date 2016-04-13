function install(skipTests)
    if nargin < 1
        skipTests = false;
    end

    package(skipTests);
    root = fileparts(mfilename('fullpath'));
    matlab.addons.toolbox.installToolbox(fullfile(root, 'target', 'Stage.mltbx'));
end

