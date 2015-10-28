function aperture()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Read an image from file.
    imagesDir = fullfile(fileparts(mfilename('fullpath')), 'Images');
    butterflyImage = imread(fullfile(imagesDir, 'butterfly.jpg'));

    % Create an image stimulus from the image matrix.
    butterfly = stage.builtin.stimuli.Image(butterflyImage);
    butterfly.size = [size(butterflyImage, 2), size(butterflyImage, 1)];
    butterfly.position = canvas.size / 2;

    % Create an aperture (masked rectangle) stimulus to sit on top of the image stimulus.
    aperture = stage.builtin.stimuli.Rectangle();
    aperture.color = 0;
    aperture.size = [500, 500];
    mask = Mask.createCircularAperture(0.4);
    aperture.setMask(mask);

    % Create a controller to change the aperture's x and y position as a function of time.
    xFunc = @(state)canvas.width / 2 + cos(state.time) * 30;
    yFunc = @(state)canvas.height / 2 + sin(state.time) * 30;
    aperaturePositionController = stage.builtin.controllers.PropertyController(aperture, 'position', @(state)[xFunc(state), yFunc(state)]);

    % Create a 7 second presentation and add the stimuli and controller.
    presentation = Presentation(7);
    presentation.addStimulus(butterfly);
    presentation.addStimulus(aperture);
    presentation.addController(aperaturePositionController);

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
