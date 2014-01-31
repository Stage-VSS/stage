classdef ProgramObject < handle
    
    properties (SetAccess = private)
        handle
    end
    
    properties (Access = private)
        canvas
        uniformLocationCache
    end
    
    methods
        
        function obj = ProgramObject(canvas)
            obj.canvas = canvas;
            canvas.makeCurrent();
            
            obj.handle = glCreateProgram();
            
            obj.uniformLocationCache = containers.Map();
        end
        
        function attach(obj, shader)
            obj.canvas.makeCurrent();
            glAttachShader(obj.handle, shader.handle);
        end
        
        function detach(obj, shader)
            obj.canvas.makeCurrent();
            glDetachShader(obj.handle, shader.handle);
        end
        
        function link(obj)
            obj.canvas.makeCurrent();
            
            glLinkProgram(obj.handle);
            status = glGetProgramiv(obj.handle, GL.LINK_STATUS);
            if status == GL.FALSE
                error('Error linking program');
            end
        end
        
        function l = getUniformLocation(obj, name)
            if obj.uniformLocationCache.isKey(name)
                l = obj.uniformLocationCache(name);
                return;
            end
            
            obj.canvas.makeCurrent();
            l = glGetUniformLocation(obj.handle, name);
            obj.uniformLocationCache(name) = l;
        end
        
        function setUniformMatrix(obj, location, matrix)
            obj.canvas.makeCurrent();
            % TODO: Finish.
            glUniformMatrix4fv(location, 1, GL.FALSE, matrix);
        end
        
        function setUniform1i(obj, location, value)
            obj.canvas.makeCurrent();
            glUniform1i(location, value);
        end
        
        function setUniformfv(obj, location, vector)
            obj.canvas.makeCurrent();
            % TODO: Finish.
            glUniform4fv(location, 1, vector);
        end
        
    end
    
    methods (Static)
        
        function program = createAndLink(canvas, shaders)
            program = ProgramObject(canvas);
            
            for i = 1:length(shaders)
                program.attach(shaders(i));
            end
            
            program.link();
            
            for i = 1:length(shaders)
                program.detach(shaders(i));
            end
        end
        
    end
    
end

