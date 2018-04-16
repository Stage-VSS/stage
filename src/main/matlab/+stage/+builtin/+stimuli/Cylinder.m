classdef Cylinder < stage.core.Stimulus
    % A 3D cylinder stimulus. The cylinder is in reality a prism with a regular polygon base.
    
    properties
        position = [0, 0, 0]    % Center position in 3D space [x, y, z]
        radius = 1              % Radius
        height = 1
        angularPosition = 0
        orientation = 0
        color = [1, 1, 1]
        opacity = 1
        imageMatrix
    end
    
    properties (SetAccess = private)
        numSides    % Number of side of the regular polygon base
    end
    
    properties (Access = private)
        vbo     % Vertex buffer object
        vao     % Vertex array object
        texture
    end
    
    methods
        
        function obj = Cylinder(numSides)
            % Constructs a 3D cylinder stimulus with an optionally specified number of sides.
            
            if nargin < 1
                numSides = 51;
            end
            obj.numSides = numSides;
        end
        
        function setImageMatrix(obj, matrix)
            if ~isa(matrix, 'uint8') && ~isa(matrix, 'single')
                error('Matrix must be of class uint8 or single');
            end
            obj.imageMatrix = matrix;
        end
        
        function init(obj, canvas)
            init@stage.core.Stimulus(obj, canvas);
            
            i = (0:obj.numSides)/obj.numSides;
            angles = i * 2 * pi;
            vertexData = zeros(1, (obj.numSides + 1) * 6 * 2);
            vertexData(1:12:end) = cos(angles);
            vertexData(2:12:end) = -1;
            vertexData(3:12:end) = sin(angles);
            vertexData(4:12:end) = 1;
            vertexData(5:12:end) = i;
            vertexData(6:12:end) = 0;
            vertexData(7:12:end) = cos(angles);
            vertexData(8:12:end) = 1;
            vertexData(9:12:end) = sin(angles);
            vertexData(10:12:end) = 1;
            vertexData(11:12:end) = i;
            vertexData(12:12:end) = 1;
            
            obj.vbo = stage.core.gl.VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);

            obj.vao = stage.core.gl.VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 6*4, 0);
            obj.vao.setAttribute(obj.vbo, 1, 2, GL.FLOAT, GL.FALSE, 6*4, 4*4);
            
            image = obj.imageMatrix;
            if size(image, 3) == 1
                image = repmat(image, 1, 1, 3);
            end
            
            if ~isempty(image)
                obj.texture = stage.core.gl.TextureObject(canvas, 2);
                obj.texture.setImage(image);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function performDraw(obj)
            modelView = obj.canvas.modelView;
            modelView.push();
            modelView.translate(obj.position(1), obj.position(2), obj.position(3));
            modelView.rotate(obj.orientation, 0, 0, 1);
            modelView.rotate(obj.angularPosition, 0, -1, 0);
            modelView.scale(obj.radius, obj.height, 1);
            
            c = obj.color;
            if length(c) == 1
                c = [c, c, c, obj.opacity];
            elseif length(c) == 3
                c = [c, obj.opacity];
            end
            
            obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, (obj.numSides+1)*2, c, [], obj.texture);
            
            modelView.pop();
        end
        
    end
end

