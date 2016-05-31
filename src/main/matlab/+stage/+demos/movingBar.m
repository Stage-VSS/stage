function movingBar()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Create the bar stimulus.
    bar = stage.builtin.stimuli.Rectangle();
    bar.size = [100, canvas.height];

    % Create a controller to change the bar's position property as a function of time.
    barPositionController = stage.builtin.controllers.PropertyController(bar, 'position', @(state)[state.time*110+100, canvas.height/2]);

    % Create a 4 second presentation and add the stimulus and controller.
    presentation = Presentation(4);
    presentation.addStimulus(bar);
    presentation.addController(barPositionController);

    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end
