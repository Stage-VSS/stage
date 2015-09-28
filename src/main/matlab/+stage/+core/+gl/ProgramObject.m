classdef ProgramObject < handle

    properties (SetAccess = private)
        handle
        canvas
    end

    properties (Access = private)
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
            try
                l = obj.uniformLocationCache(name);
                return;
            catch
                % Do nothing. This is faster than checking for the key first.
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

        function setUniformfv(obj, location, vector, count)
            if nargin < 4
                count = 1;
            end

            obj.canvas.makeCurrent();

            size = floor(numel(vector) / count);
            switch size
                case 1
                    glUniform1fv(location, count, vector);
                case 2
                    glUniform2fv(location, count, vector);
                case 3
                    glUniform3fv(location, count, vector);
                case 4
                    glUniform4fv(location, count, vector);
                otherwise
                    error('Size too large');
            end
        end

        function delete(obj)
            if isvalid(obj.canvas)
                obj.canvas.makeCurrent();
                glDeleteProgram(obj.handle);
            end
        end

    end

    methods (Static)

        function program = createAndLink(canvas, shaders)
            program = stage.core.gl.ProgramObject(canvas);

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
