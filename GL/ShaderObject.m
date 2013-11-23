classdef ShaderObject < handle
    
    properties (SetAccess = private)
        handle
    end
    
    properties (Access = private)
        canvas
    end
    
    methods
        
        function obj = ShaderObject(canvas, type, filename)
            obj.canvas = canvas;
            canvas.makeCurrent();
            
            [fid, err] = fopen(filename, 'rt');
            if fid == -1
                error(['Cannot open file: ' err]);
            end
            
            src = fread(fid);
            fclose(fid);

            shader = glCreateShader(type);
            if shader == 0
                error('Error occurred creating the shader object');
            end

            glShaderSource(shader, src);
            
            obj.handle = shader;
        end
        
        function compile(obj)
            obj.canvas.makeCurrent();
            glCompileShader(obj.handle);
            
            status = glGetShaderiv(obj.handle, GL.COMPILE_STATUS);
            if status == GL.FALSE
                error('Error compiling shader');
            end
        end
        
    end
    
end

