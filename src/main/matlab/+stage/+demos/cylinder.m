function cylinder()
    import stage.core.*;
    
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    projection = stage.core.gl.MatrixStack();
    projection.perspective(90, canvas.width/canvas.height);
    canvas.setProjection(projection);
    
    cylinder = stage.builtin.stimuli.Cylinder();
    
    imagesDir = fullfile(fileparts(mfilename('fullpath')), 'Images');
    butterflyImage = imread(fullfile(imagesDir, 'butterfly.jpg'));
    cylinder.setImageMatrix(butterflyImage);
    
    cylinderAngularController = stage.builtin.controllers.PropertyController(cylinder, 'angularPosition', @(state)360*state.time/8);
    
    presentation = Presentation(4);
    presentation.addStimulus(cylinder);
    presentation.addController(cylinderAngularController);
    
    presentation.play(canvas);
end

