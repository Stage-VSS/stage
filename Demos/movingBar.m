function movingBar()
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Grab the canvas height for convenience.
    height = canvas.size(2);
    
    % Create the bar stimulus.
    bar = Rectangle();
    bar.size = [100, height];
    
    % Create a 4 second presentation.
    duration = 4;
    presentation = Presentation(duration);
    
    % Add the bar to the presentation.
    presentation.addStimulus(bar);
    
    % Define the bar's position property as a function of time.
    presentation.addController(bar, 'position', @(state)[state.time*200-50, height/2]);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end