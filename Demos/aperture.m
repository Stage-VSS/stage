function aperture()
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Read an image from file.
    imagesDir = fullfile(fileparts(mfilename('fullpath')), 'Images');
    butterflyImage = imread(fullfile(imagesDir, 'butterfly.jpg'));
    
    % Create an image stimulus from the image matrix.
    butterfly = Image(butterflyImage);
    butterfly.size = [size(butterflyImage, 2), size(butterflyImage, 1)];
    butterfly.position = canvas.size / 2;
    
    % Create an aperture (masked rectangle) stimulus to sit on top of the image stimulus.
    aperture = Rectangle();
    aperture.color = 0;
    aperture.size = [500, 500];
    mask = Mask.createCircularAperture(0.4);
    aperture.setMask(mask);
    
    % Create a 7 second presentation.
    presentation = Presentation(7);
    
    % Add the stimuli to the presentation.
    presentation.addStimulus(butterfly);
    presentation.addStimulus(aperture);
    
    % Define the aperture's x and y position as a function of time.
    xFunc = @(state)canvas.width / 2 + cos(state.time) * 30;
    yFunc = @(state)canvas.height / 2 + sin(state.time) * 30;
    presentation.addController(aperture, 'position', @(state)[xFunc(state), yFunc(state)]);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end