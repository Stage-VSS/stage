classdef FrameBufferObject < handle
    
    properties (SetAccess = private)
        target
        binding
        handle
        canvas
    end
    
    properties (Access = private)
        canvasBeingDestroyed
    end
    
    methods
        
        function obj = FrameBufferObject(canvas)
            obj.canvas = canvas;            
            canvas.makeCurrent();
            
            obj.target = GL.DRAW_FRAMEBUFFER;
            obj.handle = glGenFramebuffers(1);
            
            obj.canvasBeingDestroyed = addlistener(canvas, 'ObjectBeingDestroyed', @(e,d)obj.delete());
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
        
        function bindFrameBuffer(obj)
            obj.canvas.makeCurrent();
            
            glBindFramebuffer(GL.FRAMEBUFFER, obj.handle);
            glDrawBuffer(GL.COLOR_ATTACHMENT0);
            glReadBuffer(GL.COLOR_ATTACHMENT0);
        end
        
        function checkFrameBufferComplete(obj)
            obj.canvas.makeCurrent();
            
            lastBound = glGetIntegerv(obj.binding);
            glBindFramebuffer(obj.target, obj.handle);
            rebind = onCleanup(@()glBindFramebuffer(obj.target, lastBound));
            
            r = glCheckFramebufferStatus(GL.FRAMEBUFFER);
            if r ~= GL.FRAMEBUFFER_COMPLETE
                error('FrameBuffer is not complete');
            end
        end
        
        function delete(obj)
            obj.canvas.makeCurrent();
            glDeleteFramebuffers(1, obj.handle);
        end
        
    end
    
end

