function movingBar()
    % Open a window in windowed-mode and grab it's canvas.
    window = Window([640, 480], false);
    canvas = window.canvas;
    
    % Create a 4 second presentation.
    duration = 4;
    presentation = Presentation(canvas, duration);
    
    % Grab the canvas height for convenience.
    height = canvas.size(2);
    
    % Create the bar stimulus.
    bar = Rectangle();
    bar.size = [100, height];
    
    % Add the bar to the presentation.
    presentation.addStimulus(bar);
    
    % Define the bar's position property as a function of time.
    presentation.addController(bar, 'position', @(state)[state.time*200-50, height/2]);
    
    % Play the presentation!
    presentation.play();
    
    % Window automatically closes when the window object is deleted.
end