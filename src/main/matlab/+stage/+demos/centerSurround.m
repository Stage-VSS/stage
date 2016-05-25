function centerSurround()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([500, 500], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Create the surround stimulus.
    surround = stage.builtin.stimuli.Ellipse(4096);
    surround.position = canvas.size/2;
    surround.radiusX = 200;
    surround.radiusY = 200;
    surround.color = [130/255, 48/255, 139/255];
    
    % Create the center stimulus.
    center = stage.builtin.stimuli.Ellipse(4096);
    center.position = canvas.size/2;
    center.radiusX = surround.radiusX/2;
    center.radiusY = surround.radiusY/2;
    center.color = 1;

    % Create a 5 second presentation and add the stimulus and controller.
    presentation = Presentation(5);
    presentation.setBackgroundColor(1);
    presentation.addStimulus(surround);
    presentation.addStimulus(center);

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
