function package(skipTests)
    if nargin < 1
        skipTests = false;
    end
    
    if ~skipTests
        test();
    end
    rootPath = fileparts(mfilename('fullpath'));
    
    addpath(genpath(fullfile(rootPath, 'apps')));
    addpath(genpath(fullfile(rootPath, 'lib')));
    addpath(genpath(fullfile(rootPath, 'src')));
    
    % Package apps
    listing = dir(fullfile(rootPath, 'apps'));
    for i = 1:numel(listing)
        l = listing(i);
        if ~l.isdir || any(strcmp(l.name, {'.', '..'}))
            continue;
        end
        run(fullfile(rootPath, 'apps', l.name, 'package.m'));
        movefile(fullfile(rootPath, 'apps', l.name, '*.mlappinstall'), rootPath);
    end
    
    rmpath(genpath(fullfile(rootPath, 'apps')));
    
    % We need to temp remove the .git and apps folder from the root because Matlab is too stupid to ignore them
    try    
        movefile(fullfile(rootPath, '.git'), fullfile(rootPath, '..'));
    catch x
        error('Cannot move .git directory. You probably have MATLAB source control integration enabled. Disable it and try again.');
    end
    restoreGit = onCleanup(@()movefile(fullfile(rootPath, '..', '.git'), rootPath));
    movefile(fullfile(rootPath, 'apps'), fullfile(rootPath, '..'));
    restoreApps = onCleanup(@()movefile(fullfile(rootPath, '..', 'apps'), rootPath));
    
    matlab.apputil.package(fullfile(rootPath, 'Stage.prj'));
end

