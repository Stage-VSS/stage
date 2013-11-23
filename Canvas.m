classdef Canvas < handle
    
    properties (SetAccess = private)
        window
        size
        projection
        modelView
    end
    
    properties (Access = private)
        defaultProgram
        
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
            
            vertShader = ShaderObject(obj, GL.VERTEX_SHADER, 'Shaders/PositionOnly.vert');
            vertShader.compile();
            
            fragShader = ShaderObject(obj, GL.FRAGMENT_SHADER, 'Shaders/UniformColor.frag');
            fragShader.compile();
            
            obj.defaultProgram = ProgramObject.createAndLink(obj, [vertShader, fragShader]);
            
            obj.resetProgram();
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
        
        function setProgram(obj, program)
            obj.makeCurrent();
                        
            projectionUni = program.getUniformLocation('projectionMatrix');
            if projectionUni == -1
                error('Program does not contain a projectionMatrix uniform');
            end
                       
            modelViewUni = program.getUniformLocation('modelViewMatrix');
            if modelViewUni == -1
                error('Program does not contain a modelViewMatrix uniform');
            end
            
            colorUni = program.getUniformLocation('color');
            if colorUni == -1
                error('Program does not contain a color uniform');
            end
            
            obj.projectionUniform = projectionUni;
            obj.modelViewUniform = modelViewUni;
            obj.colorUniform = colorUni;
            glUseProgram(program.handle);
        end
        
        function resetProgram(obj)
            obj.setProgram(obj.defaultProgram);
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
        
        function prepareToDraw(obj, color)
            obj.makeCurrent();
            glUniformMatrix4fv(obj.projectionUniform, 1, GL.FALSE, obj.projection.top());
            glUniformMatrix4fv(obj.modelViewUniform, 1, GL.FALSE, obj.modelView.top());
            glUniform4fv(obj.colorUniform, 1, color);
        end
        
        function drawArray(obj, array, mode, first, count, color)
            obj.prepareToDraw(color);
            
            glBindVertexArray(array.handle);
            glDrawArrays(mode, first, count);
            glBindVertexArray(0);
        end
        
    end
    
end

