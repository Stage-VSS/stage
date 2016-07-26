classdef FrameTracker < stage.core.Stimulus
    % A stimulus for monitoring the presentation frame rate with a photodiode. The stimulus will display a rectangle of
    % specified color every even frame and a rectangle of black every odd frame.
    
    properties
        position = [25, 25]     % Center position on the canvas [x, y] (pixels)
        size = [50, 50]         % Size [width, height] (pixels)
        color = [1, 1, 1]       % Fill color on even frames as a single intensity value or [R, G, B] (0 to 1)
    end

    properties (Access = private)
        vbo     % Vertex buffer object
        vao     % Vertex array object
        frame   % The current frame number starting at 0
    end

    methods

        function init(obj, canvas)
            init@stage.core.Stimulus(obj, canvas);

            vertexData = [-1  1  0  1 ...
                          -1 -1  0  1 ...
                           1  1  0  1 ...
                           1 -1  0  1];

            obj.vbo = stage.core.gl.VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);

            obj.vao = stage.core.gl.VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 0, 0);

            obj.frame = 0;
        end

    end

    methods (Access = protected)

        function performDraw(obj)
            modelView = obj.canvas.modelView;
            modelView.push();
            modelView.translate(obj.position(1), obj.position(2), 0);
            modelView.scale(obj.size(1) / 2, obj.size(2) / 2, 1);

            if mod(obj.frame, 2) == 0
                c = obj.color;
            else
                c = 0;
            end

            if length(c) == 1
                c = [c, c, c, 1];
            elseif length(c) == 3
                c = [c, 1];
            end

            obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c);
            obj.frame = obj.frame + 1;

            modelView.pop();
        end

    end

end
