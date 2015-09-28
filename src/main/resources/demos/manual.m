function manual()
    % Open a window in windowed-mode and create a canvas.
    window = stage.core.Window([640, 480], false);
    canvas = stage.core.Canvas(window);

    % Create the spot stimulus.
    spot = stage.builtin.stimuli.Ellipse();
    spot.position = canvas.size/2;

    % Must init stimuli before drawing.
    spot.init(canvas);

    frame = 0;
    while frame < 300
        canvas.clear();

        spot.draw();
        canvas.window.flip();

        frame = frame + 1;
    end

    % Window automatically closes when the window object is deleted.
end
