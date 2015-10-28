function filters()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Get the full path of the Demos/Movies directory.
    moviesDir = fullfile(fileparts(mfilename('fullpath')), 'Movies');

    % Create a movie stimulus.
    boxingMovie = stage.builtin.stimuli.Movie(fullfile(moviesDir, 'boxing.mpg'));
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

    % Create a 12 second presentation and add the stimulus.
    presentation = Presentation(12);
    presentation.addStimulus(boxingMovie);

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
