classdef Ellipse < Stimulus
    
    properties
        position = [0, 0]
        radiusX = 100;
        radiusY = 100;
        orientation = 0
        color = [1 1 1]
        opacity = 1
    end
    
    properties (SetAccess = private)
        numSides
    end
    
    properties (Access = private)
        vbo
        vao
    end
    
    methods
        
        function obj = Ellipse(numSides)
            if nargin < 1
                numSides = 51;
            end
            obj.numSides = numSides;
        end
        
        function init(obj, canvas)
            init@Stimulus(obj, canvas);
            
            angles = (0:obj.numSides)/obj.numSides * 2 * pi;
            vertices = zeros(1, (obj.numSides + 1) * 4);
            vertices(1:4:end) = cos(angles);
            vertices(2:4:end) = sin(angles);
            vertices(4:4:end) = 1;
            
            center = [0 0 0 1];
            vertices = [center vertices];
                    
            obj.vbo = VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertices), GL.STATIC_DRAW);
            
            obj.vao = VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 0, 0);
        end
        
        function draw(obj)
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

