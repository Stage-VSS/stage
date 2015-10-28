function checkerboard()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Create an initial checkerboard image matrix.
    checkerboardMatrix = uint8(rand(10, 10) * 255);

    % Create the checkerboard stimulus.
    checkerboard = stage.builtin.stimuli.Image(checkerboardMatrix);
    checkerboard.position = canvas.size / 2;
    checkerboard.size = [200, 200];

    % Set the minifying and magnifying functions to form discrete stixels.
    checkerboard.setMinFunction(GL.NEAREST);
    checkerboard.setMagFunction(GL.NEAREST);

    % Create a controller to change the checkerboard image matrix every frame.
    checkerboardImageController = stage.builtin.controllers.PropertyController(checkerboard, 'imageMatrix', @(s)uint8(rand(10, 10) * 255));

    % Create a 3 second presentation and add the stimulus and controller.
    presentation = Presentation(3);
    presentation.addStimulus(checkerboard);
    presentation.addController(checkerboardImageController);

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
