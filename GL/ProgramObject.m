classdef ProgramObject < handle
    
    properties (SetAccess = private)
        handle
    end
    
    properties (Access = private)
        canvas
    end
    
    methods
        
        function obj = ProgramObject(canvas)
            obj.canvas = canvas;
            canvas.makeCurrent();
            
            obj.handle = glCreateProgram();
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
            obj.canvas.makeCurrent();
            l = glGetUniformLocation(obj.handle, name);            
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

