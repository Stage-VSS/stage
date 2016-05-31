function expandingSpot()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Create the spot stimulus.
    spot = stage.builtin.stimuli.Ellipse();
    spot.position = canvas.size/2;

    % Create a controller to change the spot's radius property as a function of time.
    spotRadiusXController = stage.builtin.controllers.PropertyController(spot, 'radiusX', @(state)state.time * 30 + 100);
    spotRadiusYController = stage.builtin.controllers.PropertyController(spot, 'radiusY', @(state)state.time * 30 + 100);

    % Create a 4 second presentation and add the stimulus and controller.
    presentation = Presentation(4);
    presentation.addStimulus(spot);
    presentation.addController(spotRadiusXController);
    presentation.addController(spotRadiusYController);

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
