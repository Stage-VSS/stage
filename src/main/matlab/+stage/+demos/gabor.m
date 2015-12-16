function gabor()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Create the grating stimulus.
    grating = stage.builtin.stimuli.Grating();
    grating.position = canvas.size / 2;
    grating.size = [300, 300];
    grating.spatialFreq = 1/100; % 1 cycle per 100 pixels

    % Assign a gaussian envelope mask to the grating.
    mask = Mask.createGaussianEnvelope();
    grating.setMask(mask);

    % Create a controller to change the grating's phase property as a function of time. The phase will shift 360 degrees
    % per second.
    gaborPhaseController = stage.builtin.controllers.PropertyController(grating, 'phase', @(state)state.time * 360);

    % Create a 5 second presentation and add the stimulus and controller.
    presentation = Presentation(5);
    presentation.setBackgroundColor(0.5);
    presentation.addStimulus(grating);
    presentation.addController(gaborPhaseController);

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
