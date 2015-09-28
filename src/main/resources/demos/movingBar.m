function movingBar()
    % Open a window in windowed-mode and create a canvas.
    window = stage.core.Window([640, 480], false);
    canvas = stage.core.Canvas(window);

    % Create the bar stimulus.
    bar = stage.builtin.stimuli.Rectangle();
    bar.size = [100, canvas.height];

    % Create a controller to change the bar's position property as a function of time.
    barPositionController = stage.builtin.controllers.PropertyController(bar, 'position', @(state)[state.time*200-50, canvas.height/2]);

    % Create a 4 second presentation and add the stimulus and controller.
    presentation = stage.core.Presentation(4);
    presentation.addStimulus(bar);
    presentation.addController(barPositionController);

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
