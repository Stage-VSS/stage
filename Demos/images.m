function images()
    % Open a window in windowed-mode and grab it's canvas.
    window = Window([640, 480], false);
    canvas = window.canvas;
    
    % Grab the canvas size so we can center the stimulus.
    width = canvas.size(1);
    height = canvas.size(2);
    
    % Create a few image stimuli.
    imagesDir = fullfile(fileparts(mfilename('fullpath')), 'Images');
    
    butterflyImage = imread(fullfile(imagesDir, 'butterfly.jpg'));
    butterfly = Image(butterflyImage);
    butterfly.size = [size(butterflyImage, 2), size(butterflyImage, 1)];
    butterfly.position = [width/2, height/2];
    
    mask = Mask.createGaussianMask();
    butterfly.setMask(mask);
    
    [horseImage, ~, horseAlpha] = imread(fullfile(imagesDir, 'horse.png'));
    horseImage(:, :, 4) = horseAlpha;    
    
    darkHorse = Image(horseImage);
    darkHorse.size = [size(horseImage, 2), size(horseImage, 1)];
    darkHorse.color = 0;
    
    lightHorse = Image(horseImage);
    lightHorse.size = [-size(horseImage, 2)/2, size(horseImage, 1)/2];
    lightHorse.color = 1;
    
    % Create a 6 second presentation.
    duration = 6;
    presentation = Presentation(duration);
    
    % Add the stimuli to the presentation.
    presentation.addStimulus(lightHorse);
    presentation.addStimulus(butterfly);
    presentation.addStimulus(darkHorse);
    
    % Define the horse position's as functions of time.
    presentation.addController(lightHorse, 'position', @(state)[width-state.time*75-100, height/2]);
    presentation.addController(darkHorse, 'position', @(state)[state.time*100, height/2-50]);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end