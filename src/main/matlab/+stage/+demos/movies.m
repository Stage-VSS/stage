function movies()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Get the full path of the Demos/Movies directory.
    moviesDir = fullfile(fileparts(mfilename('fullpath')), 'Movies');

    % Create a few movie stimuli.
    boxingMovie = stage.builtin.stimuli.Movie(fullfile(moviesDir, 'boxing.mpg'));
    boxingMovie.size = [320, 240];
    boxingMovie.position = [canvas.width*1/4+30, canvas.height/2];
    boxingMovie.setMask(Mask.createGaussianEnvelope());

    skatingMovie = stage.builtin.stimuli.Movie(fullfile(moviesDir, 'skating.mpg'));
    skatingMovie.size = [320, 240];
    skatingMovie.position = [canvas.width*3/4-30, canvas.height/2];
    skatingMovie.setMask(Mask.createGaussianEnvelope());

    % Create a 12 second presentation and add the stimuli.
    presentation = Presentation(12);
    presentation.addStimulus(boxingMovie);
    presentation.addStimulus(skatingMovie);

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
