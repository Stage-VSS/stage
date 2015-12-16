function plaid()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Create two grating stimuli to layer on one another.
    grating1 = stage.builtin.stimuli.Grating();
    grating1.position = canvas.size / 2;
    grating1.size = [300, 300];
    grating1.spatialFreq = 1/100; % 1 cycle per 100 pixels
    grating1.orientation = 45;

    grating2 = stage.builtin.stimuli.Grating();
    grating2.position = grating1.position;
    grating2.size = grating1.size;
    grating2.spatialFreq = grating1.spatialFreq;
    grating2.orientation = 135;
    grating2.opacity = 0.5;

    % Assign a circular envelope mask to the gratings.
    grating1.setMask(Mask.createCircularEnvelope());
    grating2.setMask(Mask.createCircularEnvelope());

    % Create controllers to change the grating phases as functions of time. The first grating will shift 360 degrees per
    % second. The second grating will shift 180 degrees per second.
    grating1PhaseController = stage.builtin.controllers.PropertyController(grating1, 'phase', @(state)state.time * 360);
    grating2PhaseController = stage.builtin.controllers.PropertyController(grating2, 'phase', @(state)state.time * 180);

    % Create a 5 second presentation and add the stimuli and controllers.
    presentation = Presentation(5);
    presentation.setBackgroundColor(0.5);
    presentation.addStimulus(grating1);
    presentation.addStimulus(grating2);
    presentation.addController(grating1PhaseController);
    presentation.addController(grating2PhaseController);

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
