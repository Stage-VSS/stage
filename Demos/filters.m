function filters()
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Create a movie stimulus.
    moviesDir = fullfile(fileparts(mfilename('fullpath')), 'Movies');
    boxingMovie = Movie(fullfile(moviesDir, 'boxing.mpg'));
    boxingMovie.size = [320, 240];
    boxingMovie.position = canvas.size / 2;
    
    % Assign an edge-emphasizing filter. The fspecial() function may also be used to create kernel matrices if the Image 
    % Processing Toolbox is available.
    kernel = [-1 -1 -1; ...
              -1  8 -1; ...
              -1 -1 -1];
    edgeEmphasizingFilter = Filter(kernel);
    boxingMovie.setFilter(edgeEmphasizingFilter);
    
    % Create a 12 second presentation.
    duration = 12;
    presentation = Presentation(duration);
    
    % Add the stimulus to the presentation.
    presentation.addStimulus(boxingMovie);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end