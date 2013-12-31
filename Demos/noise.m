function noise()
    % Open a window in windowed-mode and grab it's canvas.
    window = Window([640, 480], false);
    canvas = window.canvas;
    
    % Grab the canvas size so we can center the stimulus.
    width = canvas.size(1);
    height = canvas.size(2);
    
    % Create the noise stimulus.
    noiseMatrix = uint8(rand(200, 200) * 255);
    noise = Image(noiseMatrix);
    noise.position = [width/2, height/2];
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