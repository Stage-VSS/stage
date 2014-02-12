function noise()
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Create the noise stimulus.
    noiseMatrix = uint8(rand(200, 200) * 255);
    noise = Image(noiseMatrix);
    noise.position = canvas.size / 2;
    noise.size = [200, 200];
    
    % Create a 5 second presentation.
    duration = 5;
    presentation = Presentation(duration);
    
    % Add the noise stimulus to the presentation.
    presentation.addStimulus(noise);
    
    % Define the noise's x and y texture shift properties as functions of time.
    presentation.addController(noise, 'shiftX', @(state)state.time * 0.5);
    presentation.addController(noise, 'shiftY', @(state)state.time * 0.5);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end