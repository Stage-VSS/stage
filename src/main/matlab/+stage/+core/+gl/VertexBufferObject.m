classdef VertexBufferObject < handle
    
    properties (SetAccess = private)
        target
        handle
        canvas
    end
    
    methods
        
        function obj = VertexBufferObject(canvas, target, data, usage)
            obj.canvas = canvas;
            canvas.makeCurrent();
            
            vbo = glGenBuffers(1);
            glBindBuffer(target, vbo); 
            size = classSize(class(data));
            glBufferData(target, length(data) * size, data, usage)
            glBindBuffer(target, 0);
            
            obj.target = target;
            obj.handle = vbo;
        end
        
        function uploadData(obj, data, offset)
            if nargin < 3
                offset = 0;
            end
            
            obj.canvas.makeCurrent();
            glBindBuffer(obj.target, obj.handle);
            size = classSize(class(data));
            glBufferSubData(obj.target, offset, length(data) * size, data);
            glBindBuffer(obj.target, 0);
        end
        
        function delete(obj)
            if isvalid(obj.canvas)
                obj.canvas.makeCurrent();
                glDeleteBuffers(1, obj.handle);
            end
        end
        
    end
    
end

function bytes = classSize(class)
    switch class
        case 'uint8'
            bytes = 1;
        case 'int16'
            bytes = 2;
        case 'single'
            bytes = 4;
        otherwise
            error('Unknown data class');
    end
end