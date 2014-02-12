classdef Canvas < handle
    
    properties (SetAccess = private)
        window          % Window containing the canvas
        size            % Size of the canvas [width, height] (pixels)
        projection      % Projection matrix stack
        modelView       % Model/View matrix stack
        currentProgram  % Current shader program
    end
    
    properties (Access = private)
        defaultMask
        standardPrograms
        windowBeingDestroyed
    end
    
    methods
        
        function obj = Canvas(window)
            obj.window = window;
            obj.windowBeingDestroyed = addlistener(window, 'ObjectBeingDestroyed', @(e,d)obj.delete());
            
            obj.projection = MatrixStack();
            obj.projection.orthographic(0, window.size(1), 0, window.size(2));
            obj.modelView = MatrixStack();
            
            obj.defaultMask = Mask(ones(2, 2, 'uint8') * 255);
            obj.defaultMask.init(obj);
            
            obj.standardPrograms = StandardPrograms(obj);
            
            obj.resetBlend();
            
            glfwSwapInterval(1);
        end
        
        function s = get.size(obj)
            s = obj.window.size;
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
                    case 'Primitive'
                        program = obj.standardPrograms.primitiveProgram;
                    case 'TexturedPrimitive'
                        program = obj.standardPrograms.texturedPrimitiveProgram;
                    case 'FilteredTexturedPrimitive'
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
        function d = getPixelData(obj, mode)
            if nargin < 2
                mode = GL.FRONT;
            end
            
            obj.makeCurrent();
            glReadBuffer(mode);
            d = glReadPixels(0, 0, obj.size(1), obj.size(2), GL.RGB, GL.UNSIGNED_BYTE);
            d = imrotate(d, 90);
        end
        
        function drawArray(obj, array, mode, first, count, color, texture, mask, filter)
            if nargin < 7
                texture = [];
            end
            
            if nargin < 8 || isempty(mask)
                mask = obj.defaultMask;
            end
            
            if nargin < 9
                filter = [];
            end
            
            obj.makeCurrent();
            
            if isempty(texture)
                obj.setProgram('Primitive');
            elseif isempty(filter)
                obj.setProgram('TexturedPrimitive');
                
                glActiveTexture(GL.TEXTURE0);
                glBindTexture(texture.target, texture.handle);
                
                glActiveTexture(GL.TEXTURE1);
                glBindTexture(mask.texture.target, mask.texture.handle);
            else
                obj.setProgram('FilteredTexturedPrimitive');
                
                glActiveTexture(GL.TEXTURE0);
                glBindTexture(texture.target, texture.handle);
                
                glActiveTexture(GL.TEXTURE1);
                glBindTexture(mask.texture.target, mask.texture.handle);

                glActiveTexture(GL.TEXTURE2);
                glBindTexture(filter.texture.target, filter.texture.handle);                
            end
            
            program = obj.currentProgram;
            projectUniform = program.getUniformLocation('projectionMatrix');
            modelUniform = program.getUniformLocation('modelViewMatrix');
            colorUniform = program.getUniformLocation('color0');
            
            program.setUniformMatrix(projectUniform, obj.projection.top());
            program.setUniformMatrix(modelUniform, obj.modelView.top());
            program.setUniformfv(colorUniform, color);
            
            glBindVertexArray(array.handle);
            glDrawArrays(mode, first, count);
            glBindVertexArray(0);
            
            if ~isempty(texture)
                glBindTexture(texture.target, 0);
            end
            
            if ~isempty(filter)
                glBindTexture(filter.texture.target, 0);
            end
            
            glBindTexture(mask.texture.target, 0);
        end
        
    end
    
end