function movies()
    % Open a window in windowed-mode and grab it's canvas.
    window = Window([640, 480], false);
    canvas = window.canvas;
    
    % Grab the canvas size so we can center the stimulus.
    width = canvas.size(1);
    height = canvas.size(2);
    
    % Create a few movie stimuli.
    moviesDir = fullfile(fileparts(mfilename('fullpath')), 'Movies');
    
    boxing1Movie = Movie(fullfile(moviesDir, 'boxing1.mpg'));
    boxing1Movie.size = [320, 240];
    boxing1Movie.position = [width*1/4+20, height/2];
    boxing1Movie.setMask(Mask.createGaussianMask());
    
    boxing2Movie = Movie(fullfile(moviesDir, 'boxing2.mpg'));
    boxing2Movie.size = [320, 240];
    boxing2Movie.position = [width*3/4-20, height/2];
    boxing2Movie.setMask(Mask.createGaussianMask());
    
    % Create a 10 second presentation.
    duration = 10;
    presentation = Presentation(duration);
    
    % Add the stimuli to the presentation.
    presentation.addStimulus(boxing1Movie);
    presentation.addStimulus(boxing2Movie);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end