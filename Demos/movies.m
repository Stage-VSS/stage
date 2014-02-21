function movies()
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Grab the canvas size for convenience.
    width = canvas.size(1);
    height = canvas.size(2);
    
    % Create a few movie stimuli.
    moviesDir = fullfile(fileparts(mfilename('fullpath')), 'Movies');
    
    boxingMovie = Movie(fullfile(moviesDir, 'boxing.mpg'));
    boxingMovie.size = [320, 240];
    boxingMovie.position = [width*1/4+30, height/2];
    boxingMovie.setMask(Mask.createGaussianEnvelope());
    
    skatingMovie = Movie(fullfile(moviesDir, 'skating.mpg'));
    skatingMovie.size = [320, 240];
    skatingMovie.position = [width*3/4-30, height/2];
    skatingMovie.setMask(Mask.createGaussianEnvelope());
    
    % Create a 12 second presentation.
    duration = 12;
    presentation = Presentation(duration);
    
    % Add the stimuli to the presentation.
    presentation.addStimulus(boxingMovie);
    presentation.addStimulus(skatingMovie);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end