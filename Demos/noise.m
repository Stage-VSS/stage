function noise()
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Create the noise image matrix.
    noiseMatrix = uint8(rand(200, 200) * 255);
    
    % Create the noise stimulus.
    noise = Image(noiseMatrix);
    noise.position = canvas.size / 2;
    noise.size = [200, 200];
    
    % Create a 5 second presentation.
    presentation = Presentation(5);
    
    % Add the noise stimulus to the presentation.
    presentation.addStimulus(noise);
    
    % Define the noise's x and y texture shift properties as functions of time.
    presentation.addController(noise, 'shiftX', @(state)state.time * 0.5);
    presentation.addController(noise, 'shiftY', @(state)state.time * 0.5);
    
    % Set the noise texture to repeat in the s (i.e. x) and t (i.e. y) coordinate as it is shifted.
    noise.setWrapModeS(GL.REPEAT); % x
    noise.setWrapModeT(GL.REPEAT); % y
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end