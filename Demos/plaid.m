function plaid()
    % Open a window in windowed-mode and grab it's canvas.
    window = Window([640, 480], false);
    canvas = window.canvas;
    
    % Set the canvas background color to gray.
    canvas.setClearColor(0.5);
    canvas.clear();
    
    % Create a 5 second presentation.
    duration = 5;
    presentation = Presentation(canvas, duration);
    
    % Grab the canvas size so we can center the stimulus.
    width = canvas.size(1);
    height = canvas.size(2);
    
    % Create two grating stimuli to layer on one another.
    grating1 = Grating();
    grating1.position = [width/2, height/2];
    grating1.size = [300, 300];
    grating1.spatialFreq = 1/100; % 1 cycle per 100 pixels
    grating1.orientation = 45;
    
    grating2 = Grating();
    grating2.position = grating1.position;
    grating2.size = grating1.size;
    grating2.spatialFreq = grating1.spatialFreq;
    grating2.orientation = 135;
    grating2.opacity = 0.5;
    
    % Assign a circle mask to the gratings.
    mask = Mask.createCircleMask();
    grating1.setMask(mask);
    grating2.setMask(mask);
    
    % Add the grating stimuli to the presentation.
    presentation.addStimulus(grating1);
    presentation.addStimulus(grating2);
    
    % Define the grating's phase property as a function of time. The first grating will shift 360 degrees per second.
    % The second grating will shift 180 degrees per second.
    presentation.addController(grating1, 'phase', @(state)state.time * 360);
    presentation.addController(grating2, 'phase', @(state)state.time * 180);
    
    % Play the presentation!
    presentation.play();
    
    % Window automatically closes when the window object is deleted.
end