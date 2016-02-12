function fastMovingBars(monitorNumber)
    import stage.core.*;
    import stage.builtin.extras.*;

    if nargin < 1
        monitorNumber = 2;
    end

    patternBitDepth = 8;
    patternColor = 'blue';

    % Set linear gamma.
    monitor = Monitor(monitorNumber);
    monitor.setGamma(1);
    
    % Setup the LightCrafter.
    lightCrafter = Lcr4500(monitor);
    lightCrafter.connect();
    lightCrafter.setMode('pattern');
    lightCrafter.setPatternAttributes(patternBitDepth, patternColor);

    % Open a window on the LightCrafter and create a canvas.
    window = Window(Lcr4500.NATIVE_RESOLUTION, true, monitor);
    canvas = Canvas(window);

    % Stretch the projection matrix to account for the LightCrafter diamond pixel screen.
    width = window.size(1) * 2;
    height = window.size(2);
    canvas.projection.setIdentity();
    canvas.projection.orthographic(0, width, 0, height);

    % Create a background stimulus (canvas.setClearColor should not be used in pattern mode).
    background = stage.builtin.stimuli.Rectangle();
    background.size = [width, height];
    background.position = [width, height] / 2;
    background.color = 0.1;

    % Create 2 bar stimuli.
    bar1 = stage.builtin.stimuli.Rectangle();
    bar1.size = [100, height];
    bar1.color = 0.7;

    bar2 = stage.builtin.stimuli.Rectangle();
    bar2.size = [100, height];
    bar2.color = 0.7;

    % Create controllers to change the bar positions as a function of time.
    bar1PositionController = stage.builtin.controllers.PropertyController(bar1, 'position', @(state)[sin(state.time*5)*width/2+width/2, height/2]);
    bar2PositionController = stage.builtin.controllers.PropertyController(bar2, 'position', @(state)[-sin(state.time*5)*width/2+width/2, height/2]);

    % Create a 3 second presentation.
    presentation = Presentation(3);

    % Add the stimuli to the presentation.
    presentation.addStimulus(background);
    presentation.addStimulus(bar1);
    presentation.addStimulus(bar2);
    presentation.addController(bar1PositionController);
    presentation.addController(bar2PositionController);

    % Create a pattern renderer for the canvas.
    [~, ~, nPatterns] = lightCrafter.getPatternAttributes();
    renderer = stage.builtin.renderers.LcrPatternRenderer(nPatterns, patternBitDepth);
    canvas.setRenderer(renderer);

    % Create a pattern compositor for the player.
    compositor = stage.builtin.compositors.LcrPatternCompositor();
    compositor.bindPatternRenderer(renderer);

    % Create a prerendered player.
    player = stage.builtin.players.PrerenderedPlayer(presentation);
    player.setCompositor(compositor);

    % Play the presentation on the canvas!
    player.play(canvas);

    % After playing the presentation once, it may be "replayed" to skip prerendering.
    player.replay(canvas);

    % Window automatically closes when the window object is deleted.
end
