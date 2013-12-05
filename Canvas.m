classdef Canvas < handle
    
    properties (SetAccess = private)
        window
        size
        projection
        modelView
    end
    
    properties (Access = private)
        standardPrograms
        currentProgram
        
        projectionUniform
        modelViewUniform
        colorUniform
    end
    
    methods
        
        function obj = Canvas(window)
            obj.window = window;
            
            obj.projection = MatrixStack();
            obj.projection.orthographic(0, window.size(1), 0, window.size(2));
            obj.modelView = MatrixStack();
            
            obj.standardPrograms = StandardPrograms(obj);
            
            obj.resetBlend();
        end
        
        function s = get.size(obj)
            s = obj.window.size;
        end
        
        function makeCurrent(obj)
            glfwMakeContextCurrent(obj.window.glfwWindow);
        end
        
        function setClearColor(obj, color)
            obj.makeCurrent();
            c = color;
            glClearColor(c(1), c(2), c(3), c(4));
        end
        
        function clear(obj)
            obj.makeCurrent();
            glClear(GL.COLOR_BUFFER_BIT);
        end
        
        function setProgram(obj, programName)
            obj.makeCurrent();
            
            switch programName
                case 'PositionOnly'
                    program = obj.standardPrograms.positionOnlyProgram;
                case 'SingleTexture'
                    program = obj.standardPrograms.singleTextureProgram;
                otherwise
                    error('Unknown program name');
            end
            
            obj.projectionUniform = program.getUniformLocation('projectionMatrix');
            obj.modelViewUniform = program.getUniformLocation('modelViewMatrix');
            obj.colorUniform = program.getUniformLocation('color0');
            
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
        
        function drawArray(obj, array, mode, first, count, color, texture, mask)
            obj.makeCurrent();
            
            if nargin < 7
                obj.setProgram('PositionOnly');
            else
                obj.setProgram('SingleTexture');
                
                glActiveTexture(GL.TEXTURE0);
                glBindTexture(texture.target, texture.handle);
                
                if nargin >= 8
                    glActiveTexture(GL.TEXTURE1);
                    glBindTexture(mask.texture.target, mask.texture.handle);
                end
            end
            
            prog = obj.currentProgram;
            prog.setUniformMatrix(obj.projectionUniform, obj.projection.top());
            prog.setUniformMatrix(obj.modelViewUniform, obj.modelView.top());
            prog.setUniformfv(obj.colorUniform, color);
            
            glBindVertexArray(array.handle);
            glDrawArrays(mode, first, count);
            glBindVertexArray(0);
            
            if nargin > 6
                glBindTexture(texture.target, 0);
            end
        end
        
    end
    
end

