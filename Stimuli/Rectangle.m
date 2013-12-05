classdef Rectangle < Stimulus
    
    properties
        position = [0, 0]   % [x, y]
        size = [100, 100]   % [width, height]
        orientation = 0     % degrees
        color = [1 1 1]
        opacity = 1
    end
    
    properties (Access = private)
        vbo
        vao
    end
    
    methods
        
        function init(obj, canvas)
            init@Stimulus(obj, canvas);
            
            vertexData = [-1  1  0  1 ...
                          -1 -1  0  1 ...
                           1  1  0  1 ...
                           1 -1  0  1];
                     
            obj.vbo = VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);
            
            obj.vao = VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 0, 0);
        end
        
        function draw(obj)
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
            
            obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c);
            
            modelView.pop();
        end
        
    end
    
end