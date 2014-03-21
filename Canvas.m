classdef Canvas < handle
    
    properties (SetAccess = private)
        window              % Window containing the canvas
        size                % Size of the canvas [width, height] (pixels)
        width               % Width of the canvas, for convenience (pixels)
        height              % Height of the canvas, for convenience (pixels)
        projection          % Projection matrix stack
        modelView           % Model/View matrix stack
        currentProgram      % Current shader program
        currentRenderer     % Current primitive renderer
    end
    
    properties (Access = private)
        defaultRenderer
        standardPrograms
        framebufferBound
        windowBeingDestroyed
    end
    
    methods
        
        function obj = Canvas(window)
            obj.window = window;
            obj.windowBeingDestroyed = addlistener(window, 'ObjectBeingDestroyed', @(e,d)obj.delete());
            
            obj.projection = MatrixStack();
            obj.projection.orthographic(0, window.size(1), 0, window.size(2));
            obj.modelView = MatrixStack();
            
            obj.defaultRenderer = Renderer();
            obj.resetRenderer();
            
            obj.standardPrograms = StandardPrograms(obj);
            obj.framebufferBound = false;
            obj.resetBlend();
            
            glfwSwapInterval(1);
        end
        
        function s = get.size(obj)
            s = obj.window.size;
        end
        
        function w = get.width(obj)
            w = obj.size(1);
        end
        
        function h = get.height(obj)
            h = obj.size(2);
        end
        
        function makeCurrent(obj)
            glfwMakeContextCurrent(obj.window.handle);
        end
        
        function setClearColor(obj, color)
            obj.makeCurrent();
            
            c = color;
            if length(c) == 1
                c = [c, c, c, 1];
            elseif length(c) == 3
                c = [c, 1];
            end
            glClearColor(c(1), c(2), c(3), c(4));
        end
        
        function clear(obj)
            obj.makeCurrent();
            glClear(GL.COLOR_BUFFER_BIT);
        end
        
        function setProgram(obj, program)
            if ischar(program)
                switch program
                    case 'primitive'
                        program = obj.standardPrograms.primitiveProgram;
                    case 'texturedPrimitive'
                        program = obj.standardPrograms.texturedPrimitiveProgram;
                    case 'filteredTexturedPrimitive'
                        program = obj.standardPrograms.filteredTexturedPrimitiveProgram;
                    otherwise
                        error('Unknown program name');
                end
            end
            
            if program == obj.currentProgram
                return;
            end
            
            obj.makeCurrent();
            glUseProgram(program.handle);
            obj.currentProgram = program;
        end
        
        function enableBlend(obj, src, dest)            
            obj.makeCurrent();
            glEnable(GL.BLEND);
            glBlendFunc(src, dest);
        end
        
        function disableBlend(obj)
            obj.makeCurrent();
            glDisable(GL.BLEND);
        end
        
        function resetBlend(obj)
            obj.enableBlend(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
        end
        
        % Gets image matrix of current framebuffer data. 
        function d = getPixelData(obj, permuteImage)
            if nargin < 2
                permuteImage = true;
            end
            
            obj.makeCurrent();
            
            if ~obj.framebufferBound
                glReadBuffer(GL.BACK);
            end
            
            d = glReadPixels(0, 0, obj.size(1), obj.size(2), GL.RGB, GL.UNSIGNED_BYTE);
            
            if permuteImage
                d = flipdim(permute(d, [3, 2, 1]), 1);
            end
        end
        
        function setFramebuffer(obj, drawBuffer)
            if drawBuffer.canvas ~= obj
                error('Buffer canvas must equal this canvas');
            end
            
            drawBuffer.checkFramebufferComplete();
            drawBuffer.bindFramebuffer();
            
            obj.framebufferBound = true;
        end
        
        function resetFramebuffer(obj)
            obj.makeCurrent();
            
            glBindFramebuffer(GL.FRAMEBUFFER, 0);
            glBindFramebuffer(GL.READ_FRAMEBUFFER, 0);
            
            glDrawBuffer(GL.BACK);
            glReadBuffer(GL.BACK);
            
            obj.framebufferBound = false;
        end
        
        function setRenderer(obj, renderer)
            obj.currentRenderer = renderer;
            obj.currentRenderer.setCanvas(obj);
        end
        
        function resetRenderer(obj)
            obj.setRenderer(obj.defaultRenderer);
        end
        
        function drawArray(obj, array, mode, first, count, color, mask, texture, filter)
            if nargin < 7
                mask = [];
            end
            
            if nargin < 8
                texture = [];
            end
            
            if nargin < 9
                filter = [];
            end
            
            obj.currentRenderer.projection.setMatrix(obj.projection.top());
            obj.currentRenderer.modelView.setMatrix(obj.modelView.top());
            
            obj.currentRenderer.drawArray(array, mode, first, count, color, mask, texture, filter);
        end
        
    end
    
end