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
    
    % Create an edge-emphasizing filter. The fspecial() function may also be used to create kernel matrices if the Image 
    % Processing Toolbox is available.
    kernel = [-1 -1 -1; ...
              -1  8 -1; ...
              -1 -1 -1];
    filter = Filter(kernel);
    
    % Assign the filter to the movie stimulus.
    boxingMovie.setFilter(filter);
    
    % Set the stimulus s (i.e. x) and t (i.e. y) coordinate wrap mode to determine the filter's edge handling.
    boxingMovie.setWrapModeS(GL.MIRRORED_REPEAT);
    boxingMovie.setWrapModeT(GL.MIRRORED_REPEAT);
    
    % Create a 12 second presentation.
    duration = 12;
    presentation = Presentation(duration);
    
    % Add the stimulus to the presentation.
    presentation.addStimulus(boxingMovie);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end