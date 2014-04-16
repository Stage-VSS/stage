function checkerboard()
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Create an initial checkerboard image matrix.
    checkerboardMatrix = uint8(rand(10, 10) * 255);
    
    % Create the checkerboard stimulus.
    checkerboard = Image(checkerboardMatrix);
    checkerboard.position = canvas.size / 2;
    checkerboard.size = [200, 200];
    
    % Set the minifying and magnifying functions to form discrete stixels.
    checkerboard.setMinFunction(GL.NEAREST);
    checkerboard.setMagFunction(GL.NEAREST);
    
    % Create a 3 second presentation.
    presentation = Presentation(3);
    
    % Add the checkerboard stimulus to the presentation.
    presentation.addStimulus(checkerboard);
    
    % Change the checkerboard image matrix every frame.
    presentation.addController(checkerboard, 'imageMatrix', @(s)uint8(rand(10, 10) * 255));
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end