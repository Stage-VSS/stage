classdef VertexArrayObject < handle
    
    properties (SetAccess = private)
        handle
        canvas
    end
    
    methods
        
        function obj = VertexArrayObject(canvas)
            obj.canvas = canvas;
            canvas.makeCurrent();
            
            obj.handle = glGenVertexArrays(1);
        end
        
        function setAttribute(obj, buffer, index, size, type, normalized, stride, pointer)
            obj.canvas.makeCurrent();
            
            glBindVertexArray(obj.handle);
            glBindBuffer(GL.ARRAY_BUFFER, buffer.handle);
            glEnableVertexAttribArray(index);
            
            glVertexAttribPointer(index, size, type, normalized, stride, pointer);
            
            glBindBuffer(GL.ARRAY_BUFFER, 0);
            glBindVertexArray(0);
        end
        
        function delete(obj)
            if isvalid(obj.canvas)
                obj.canvas.makeCurrent();
                glDeleteVertexArrays(1, obj.handle);
            end
        end
        
    end
    
end

