classdef Ellipse < stage.core.Stimulus
    % A filled ellipse stimulus. The ellipse is in reality a regular polygon with a large number of sides.
    
    properties
        position = [0, 0]   % Center position on the canvas [x, y] (pixels)
        radiusX = 100       % Radius on the x axes (pixels)
        radiusY = 100       % Radius on the y axes (pixels)
        orientation = 0     % Orientation (degrees)
        color = [1, 1, 1]   % Fill color as single intensity value or [R, G, B] (0 to 1)
        opacity = 1         % Opacity (0 to 1)
    end

    properties (SetAccess = private)
        numSides    % Number of sides of the regular polygon
    end

    properties (Access = private)
        vbo     % Vertex buffer object
        vao     % Vertex array object
    end

    methods
        
        function obj = Ellipse(numSides)
            % Constructs an ellipse stimulus with an optionally specified number of sides.
            
            if nargin < 1
                numSides = 51;
            end
            obj.numSides = numSides;
        end

        function init(obj, canvas)
            init@stage.core.Stimulus(obj, canvas);

            angles = (0:obj.numSides)/obj.numSides * 2 * pi;
            vertexData = zeros(1, (obj.numSides + 1) * 4);
            vertexData(1:4:end) = cos(angles);
            vertexData(2:4:end) = sin(angles);
            vertexData(4:4:end) = 1;

            center = [0 0 0 1];
            vertexData = [center vertexData];

            obj.vbo = stage.core.gl.VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);

            obj.vao = stage.core.gl.VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 0, 0);
        end

    end

    methods (Access = protected)

        function performDraw(obj)
            modelView = obj.canvas.modelView;
            modelView.push();
            modelView.translate(obj.position(1), obj.position(2), 0);
            modelView.rotate(obj.orientation, 0, 0, 1);
            modelView.scale(obj.radiusX, obj.radiusY, 1);

            c = obj.color;
            if length(c) == 1
                c = [c, c, c, obj.opacity];
            elseif length(c) == 3
                c = [c, obj.opacity];
            end

            obj.canvas.drawArray(obj.vao, GL.TRIANGLE_FAN, 0, obj.numSides+2, c);

            modelView.pop();
        end

    end

end
