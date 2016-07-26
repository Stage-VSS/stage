classdef Rectangle < stage.core.Stimulus
    % A filled rectangle stimulus.
    
    properties
        position = [0, 0]   % Center position on the canvas [x, y] (pixels)
        size = [100, 100]   % Size [width, height] (pixels)
        orientation = 0     % Orientation (degrees)
        color = [1, 1, 1]   % Fill color as single intensity value or [R, G, B] (0 to 1)
        opacity = 1         % Opacity (0 to 1)
    end

    properties (Access = private)
        mask    % Stimulus mask
        vbo     % Vertex buffer object
        vao     % Vertex array object
    end

    methods

        function init(obj, canvas)
            init@stage.core.Stimulus(obj, canvas);

            if ~isempty(obj.mask)
                obj.mask.init(canvas);
            end

            % Each vertex position is followed by a mask coordinate.
            vertexData = [-1  1  0  1,  0  1 ...
                          -1 -1  0  1,  0  0 ...
                           1  1  0  1,  1  1 ...
                           1 -1  0  1,  1  0];

            obj.vbo = stage.core.gl.VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);

            obj.vao = stage.core.gl.VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 6*4, 0);
            obj.vao.setAttribute(obj.vbo, 1, 2, GL.FLOAT, GL.FALSE, 6*4, 4*4);
        end
        
        function setMask(obj, mask)
            % Assigns a mask to the stimulus.
            obj.mask = mask;
        end

    end

    methods (Access = protected)

        function performDraw(obj)
            modelView = obj.canvas.modelView;
            modelView.push();
            modelView.translate(obj.position(1), obj.position(2), 0);
            modelView.rotate(obj.orientation, 0, 0, 1);
            modelView.scale(obj.size(1) / 2, obj.size(2) / 2, 1);

            c = obj.color;
            if length(c) == 1
                c = [c, c, c, obj.opacity];
            elseif length(c) == 3
                c = [c, obj.opacity];
            end

            obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c, obj.mask);

            modelView.pop();
        end

    end

end
