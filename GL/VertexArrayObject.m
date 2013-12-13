classdef VertexArrayObject < handle
    
    properties (SetAccess = private)
        handle
    end
    
    properties (Access = private)
        canvas
        canvasBeingDestroyed
    end
    
    methods
        
        function obj = VertexArrayObject(canvas)
            obj.canvas = canvas;
            canvas.makeCurrent();
            
            obj.handle = glGenVertexArrays(1);
            
            obj.canvasBeingDestroyed = addlistener(canvas, 'ObjectBeingDestroyed', @(e,d)obj.delete());
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
            obj.canvas.makeCurrent();
            glDeleteVertexArrays(1, obj.handle);
        end
        
    end
    
end

