function package(skipTests)
    if nargin < 1
        skipTests = false;
    end
    
    if ~skipTests
        test();
    end
    rootPath = fileparts(mfilename('fullpath'));
    targetPath = fullfile(rootPath, 'target');
    [~, ~] = mkdir(targetPath);
    
    addpath(genpath(fullfile(rootPath, 'apps')));
    addpath(genpath(fullfile(rootPath, 'lib')));
    addpath(genpath(fullfile(rootPath, 'src')));
    
    % Package apps.
    listing = dir(fullfile(rootPath, 'apps'));
    for i = 1:numel(listing)
        l = listing(i);
        if ~l.isdir || any(strcmp(l.name, {'.', '..'}))
            continue;
        end
        run(fullfile(rootPath, 'apps', l.name, 'package.m'));
        movefile(fullfile(rootPath, 'apps', l.name, 'target', '*.mlappinstall'), fullfile(targetPath, 'apps'));
    end
    
    projectFile = fullfile(rootPath, 'Stage.prj');
    
    dom = xmlread(projectFile);
    root = dom.getDocumentElement();
    config = root.getElementsByTagName('configuration').item(0);
    
    % Update version number.
    version = config.getElementsByTagName('param.version').item(0);
    version.setTextContent(stageui.app.App.version);
    
    % Replace fullpaths with ${PROJECT_ROOT}.
    config.setAttribute('file', fullfile('${PROJECT_ROOT}', 'Stage.prj'));
    config.setAttribute('location', '${PROJECT_ROOT}');
    output = config.getElementsByTagName('param.output').item(0);
    output.setTextContent(fullfile('${PROJECT_ROOT}', 'target'));
    deliverable = config.getElementsByTagName('build-deliverables').item(0).getElementsByTagName('file').item(0);
    deliverable.setAttribute('location', '${PROJECT_ROOT}');
    deliverable.setTextContent(fullfile('${PROJECT_ROOT}', 'target'));
    
    % Remove unsetting the param.output.
    unsets = config.getElementsByTagName('unset').item(0);
    param = unsets.getElementsByTagName('param.output');
    if param.getLength() > 0
        unsets.removeChild(param.item(0));
    end
    
    % Set param.docs.
    docs = config.getElementsByTagName('param.docs').item(0);
    docs.setTextContent(fullfile('${PROJECT_ROOT}', 'src', 'main', 'resources', 'docs'));
    
    % Remove unsetting the param.apps.
    unsets = config.getElementsByTagName('unset').item(0);
    param = unsets.getElementsByTagName('param.apps');
    if param.getLength() > 0
        unsets.removeChild(param.item(0));
    end
    
    % Add apps to params.
    apps = config.getElementsByTagName('param.apps').item(0);
    files = apps.getElementsByTagName('file');
    while files.getLength() > 0
        apps.removeChild(files.item(0));
    end
    listing = dir(fullfile(targetPath, 'apps'));
    for i = 1:numel(listing)
        l = listing(i);
        if any(strcmp(l.name, {'.', '..'}))
            continue;
        end
        a = apps.getOwnerDocument().createElement('file');
        a.setTextContent(fullfile('${PROJECT_ROOT}', l.name));
        apps.appendChild(a);
    end
    
    % Setup root files.
    fileset = config.getElementsByTagName('fileset.rootfiles').item(0);
    files = fileset.getElementsByTagName('file');
    while files.getLength() > 0
        fileset.removeChild(files.item(0));
    end
    lib = fileset.getOwnerDocument().createElement('file');
    lib.setTextContent(fullfile('${PROJECT_ROOT}', 'lib'));
    fileset.appendChild(lib);
    src = fileset.getOwnerDocument().createElement('file');
    src.setTextContent(fullfile('${PROJECT_ROOT}', 'src'));
    fileset.appendChild(src);
    listing = dir(fullfile(targetPath, 'apps'));
    for i = 1:numel(listing)
        l = listing(i);
        if any(strcmp(l.name, {'.', '..'}))
            continue;
        end
        a = fileset.getOwnerDocument().createElement('file');
        a.setTextContent(fullfile('${PROJECT_ROOT}', l.name));
        fileset.appendChild(a);
    end
    
    % This adds a new line after each line in the XML.
    %xmlwrite(projectFile, dom);
    
    domString = strrep(char(dom.saveXML(root)), 'encoding="UTF-16"', 'encoding="UTF-8"');
    fid = fopen(projectFile, 'w');
    fwrite(fid, domString);
    fclose(fid);
    
    % Apps won't seems to be packaged unless they are in the root directory.
    movefile(fullfile(targetPath, 'apps', '*.mlappinstall'), fullfile(rootPath));
    moveback = onCleanup(@()movefile(fullfile(rootPath, '*.mlappinstall'), fullfile(targetPath, 'apps')));
    
    matlab.addons.toolbox.packageToolbox(fullfile(rootPath, 'Stage.prj'),  fullfile(targetPath, 'Stage'));
end

