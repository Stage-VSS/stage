function noise()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Create the noise image matrix.
    noiseMatrix = uint8(rand(200, 200) * 255);

    % Create the noise stimulus.
    noise = stage.builtin.stimuli.Image(noiseMatrix);
    noise.position = canvas.size / 2;
    noise.size = [200, 200];

    % Create controllers to change the noise's x and y texture shift properties as functions of time.
    noiseShiftXController = stage.builtin.controllers.PropertyController(noise, 'shiftX', @(state)state.time * 0.5);
    noiseShiftYController = stage.builtin.controllers.PropertyController(noise, 'shiftY', @(state)state.time * 0.5);

    % Create a 5 second presentation and add the stimulus and controllers.
    presentation = Presentation(5);
    presentation.addStimulus(noise);
    presentation.addController(noiseShiftXController);
    presentation.addController(noiseShiftYController);

    % Set the noise texture to repeat in the s (i.e. x) and t (i.e. y) coordinate as it is shifted.
    noise.setWrapModeS(GL.REPEAT); % x
    noise.setWrapModeT(GL.REPEAT); % y

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
