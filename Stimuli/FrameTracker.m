classdef FrameTracker < Stimulus
    
    properties
        position = [25, 25]   % [x, y]
        size = [50, 50]       % [width, height]
        color = [1 1 1]
    end
    
    properties (Access = private)
        vbo
        vao
        frame
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
            
            obj.frame = 0;
        end
        
        function draw(obj)
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