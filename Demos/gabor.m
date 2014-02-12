function gabor()    
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Set the canvas background color to gray.
    canvas.setClearColor(0.5);
    canvas.clear();
    
    % Create the grating stimulus.
    grating = Grating();
    grating.position = canvas.size / 2;
    grating.size = [300, 300];
    grating.spatialFreq = 1/100; % 1 cycle per 100 pixels
    
    % Assign a gaussian mask to the grating.
    mask = Mask.createGaussianMask();
    grating.setMask(mask);
    
    % Create a 5 second presentation.
    duration = 5;
    presentation = Presentation(duration);
    
    % Add the grating stimulus to the presentation.
    presentation.addStimulus(grating);
    
    % Define the grating's phase property as a function of time. The phase will shift 360 degrees per second.
    presentation.addController(grating, 'phase', @(state)state.time * 360);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end