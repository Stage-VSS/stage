function movies()
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Get the full path of the Demos/Movies directory.
    moviesDir = fullfile(fileparts(mfilename('fullpath')), 'Movies');
    
    % Create a few movie stimuli.
    boxingMovie = Movie(fullfile(moviesDir, 'boxing.mpg'));
    boxingMovie.size = [320, 240];
    boxingMovie.position = [canvas.width*1/4+30, canvas.height/2];
    boxingMovie.setMask(Mask.createGaussianEnvelope());
    
    skatingMovie = Movie(fullfile(moviesDir, 'skating.mpg'));
    skatingMovie.size = [320, 240];
    skatingMovie.position = [canvas.width*3/4-30, canvas.height/2];
    skatingMovie.setMask(Mask.createGaussianEnvelope());
    
    % Create a 12 second presentation.
    presentation = Presentation(12);
    
    % Add the stimuli to the presentation.
    presentation.addStimulus(boxingMovie);
    presentation.addStimulus(skatingMovie);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end