function movingSpot()
    import stage.core.*;

    % Open a window in windowed-mode and create a canvas. 'disableDwm' = false for demo only!
    window = Window([640, 480], false);
    canvas = Canvas(window, 'disableDwm', false);

    % Create the spot stimulus.
    spot = stage.builtin.stimuli.Ellipse();
    spot.position = canvas.size/2;

    function p = spotPosition(state) %#ok<INUSD>
        p = spot.position;

        if window.getKeyState(GLFW.GLFW_KEY_UP)
            p(2) = p(2) + 1;
        end
        if window.getKeyState(GLFW.GLFW_KEY_DOWN)
            p(2) = p(2) - 1;
        end
        if window.getKeyState(GLFW.GLFW_KEY_LEFT)
            p(1) = p(1) - 1;
        end
        if window.getKeyState(GLFW.GLFW_KEY_RIGHT)
            p(1) = p(1) + 1;
        end
    end

    % Create a controller to change the spot's position property depending on the currently pressed key.
    spotPositionController = stage.builtin.controllers.PropertyController(spot, 'position', @spotPosition);

    % Create a 10 second presentation and add the stimulus and controller.
    presentation = Presentation(10);
    presentation.addStimulus(spot);
    presentation.addController(spotPositionController);

    % Play the presentation on the canvas!
    presentation.play(canvas);

    % Window automatically closes when the window object is deleted.
end
