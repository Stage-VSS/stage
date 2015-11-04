function package(skipTests)
    if nargin < 1
        skipTests = false;
    end
    
    if ~skipTests
        test();
    end
    root = fileparts(mfilename('fullpath'));
    
    % Package apps
    listing = dir(fullfile(root, 'apps'));
    for i = 1:numel(listing)
        l = listing(i);
        if ~l.isdir || any(strcmp(l.name, {'.', '..'}))
            continue;
        end
        run(fullfile(root, 'apps', l.name, 'package.m'));
        movefile(fullfile(root, 'apps', l.name, '*.mlappinstall'), root);
    end
    
    matlab.apputil.package(fullfile(root, 'Stage.prj'));
end

