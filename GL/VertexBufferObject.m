classdef VertexBufferObject < handle
    
    properties (SetAccess = private)
        handle
    end
    
    properties (Access = private)
        canvas
    end
    
    methods
        
        function obj = VertexBufferObject(canvas, target, data, usage)
            obj.canvas = canvas;
            canvas.makeCurrent();
            
            vbo = glGenBuffers(1);
            glBindBuffer(target, vbo);          
            switch class(data)
                case 'uint8'
                    size = 1;
                case 'int16'
                    size = 2;
                case 'single'
                    size = 4;
                otherwise
                    error('Unknown data class');
            end
            glBufferData(target, length(data) * size, data, usage)
            glBindBuffer(target, 0);
            
            obj.handle = vbo;
        end
        
        function delete(obj)
            obj.canvas.makeCurrent();
            glDeleteBuffers(1, obj.handle);
        end
        
    end
    
end

