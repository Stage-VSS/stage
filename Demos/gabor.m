function gabor()
    % Stage needs to be initialized at least once before opening it's first window.
    initStage();
    
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
    
    % Create the grating stimulus.
    grating = Grating();
    grating.position = [width/2, height/2];
    grating.size = [300, 300];
    grating.spatialFreq = 1/100; % 1 cycle per 100 pixels
    
    % Assign a gaussian mask to the grating.
    mask = Mask.createGaussianMask();
    grating.setMask(mask);
    
    % Add the grating stimulus to the presentation.
    presentation.addStimulus(grating);
    
    % Define the grating's phase property as a function of time. The phase will shift 360 degrees per second.
    presentation.addController(grating, 'phase', @(state)state.time * 360);
    
    % Play the presentation!
    presentation.play();
    
    % Window automatically closes when the window object is deleted.
end