classdef FramebufferObject < handle
    
    properties (SetAccess = private)
        target
        binding
        handle
        canvas
    end
    
    methods
        
        function obj = FramebufferObject(canvas)
            obj.canvas = canvas;            
            canvas.makeCurrent();
            
            obj.target = GL.DRAW_FRAMEBUFFER;
            obj.handle = glGenFramebuffers(1);
        end
        
        function setTarget(obj, target)
            obj.target = target;
        end
        
        function b = get.binding(obj)
            if obj.target == GL.DRAW_FRAMEBUFFER
                b = GL.DRAW_FRAMEBUFFER_BINDING;
            else
                b = GL.READ_FRAMEBUFFER_BINDING;
            end
        end
        
        function attachColor(obj, attachmentIndex, texture, level)
            if nargin < 4
                level = 0;
            end
            
            obj.canvas.makeCurrent();
            
            lastBound = glGetIntegerv(obj.binding);
            glBindFramebuffer(obj.target, obj.handle);
            rebind = onCleanup(@()glBindFramebuffer(obj.target, lastBound));
            
            if texture.target == GL.TEXTURE_1D
                glFramebufferTexture1D(obj.target, GL.COLOR_ATTACHMENT0 + attachmentIndex, texture.target, texture.handle, level);
            elseif texture.target == GL.TEXTURE_2D
                glFramebufferTexture2D(obj.target, GL.COLOR_ATTACHMENT0 + attachmentIndex, texture.target, texture.handle, level);
            else
                error('Unsupported texture target');
            end
        end
        
        function bindFramebuffer(obj, writeOnly)
            obj.canvas.makeCurrent();
            
            if writeOnly
                glBindFramebuffer(GL.FRAMEBUFFER, obj.handle);
            else
                glBindFramebuffer(GL.READ_FRAMEBUFFER, obj.handle);
            end
            
            glDrawBuffer(GL.COLOR_ATTACHMENT0);
            glReadBuffer(GL.COLOR_ATTACHMENT0);
        end
        
        function checkFramebufferComplete(obj)
            obj.canvas.makeCurrent();
            
            lastBound = glGetIntegerv(obj.binding);
            glBindFramebuffer(obj.target, obj.handle);
            rebind = onCleanup(@()glBindFramebuffer(obj.target, lastBound));
            
            r = glCheckFramebufferStatus(GL.FRAMEBUFFER);
            if r ~= GL.FRAMEBUFFER_COMPLETE
                error('Framebuffer is not complete');
            end
        end
        
        function delete(obj)
            if isvalid(obj.canvas)
                obj.canvas.makeCurrent();
                glDeleteFramebuffers(1, obj.handle);
            end
        end
        
    end
    
end

