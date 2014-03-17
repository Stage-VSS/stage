function images()
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Read a few images from file.
    imagesDir = fullfile(fileparts(mfilename('fullpath')), 'Images');
    butterflyImage = imread(fullfile(imagesDir, 'butterfly.jpg'));
    
    [horseImage, ~, horseAlpha] = imread(fullfile(imagesDir, 'horse.png'));
    horseImage(:, :, 4) = horseAlpha;
    
    % Create a few image stimuli.
    butterfly = Image(butterflyImage);
    butterfly.size = [size(butterflyImage, 2), size(butterflyImage, 1)];
    butterfly.position = canvas.size / 2;
    
    mask = Mask.createGaussianEnvelope();
    butterfly.setMask(mask);  
    
    darkHorse = Image(horseImage);
    darkHorse.size = [size(horseImage, 2), size(horseImage, 1)];
    darkHorse.color = 0;
    
    lightHorse = Image(horseImage);
    lightHorse.size = [-size(horseImage, 2)/2, size(horseImage, 1)/2];
    lightHorse.color = 1;
    
    % Create a 6 second presentation.
    presentation = Presentation(6);
    
    % Add the stimuli to the presentation.
    presentation.addStimulus(lightHorse);
    presentation.addStimulus(butterfly);
    presentation.addStimulus(darkHorse);
    
    % Define the horse positions as functions of time.
    presentation.addController(lightHorse, 'position', @(state)[canvas.width-state.time*75-100, canvas.height/2]);
    presentation.addController(darkHorse, 'position', @(state)[state.time*100, canvas.height/2-50]);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end