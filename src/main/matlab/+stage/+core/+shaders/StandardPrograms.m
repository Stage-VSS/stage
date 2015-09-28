classdef StandardPrograms < handle

    properties (SetAccess = private)
        primitiveProgram
        texturedPrimitiveProgram
        filteredTexturedPrimitiveProgram
    end

    methods

        function obj = StandardPrograms(canvas)
            obj.createPrimitiveProgram(canvas);
            obj.createTexturedPrimitiveProgram(canvas);
            obj.createFilteredTexturedPrimitiveProgram(canvas);
        end

    end

    methods (Access = private)

        function createPrimitiveProgram(obj, canvas)
            filePath = mfilename('fullpath');
            shadersDir = fileparts(filePath);

            vertShader = stage.core.gl.ShaderObject(canvas, GL.VERTEX_SHADER, fullfile(shadersDir, 'Primitive.vert'));
            vertShader.compile();

            fragShader = stage.core.gl.ShaderObject(canvas, GL.FRAGMENT_SHADER, fullfile(shadersDir, 'Primitive.frag'));
            fragShader.compile();

            program = stage.core.gl.ProgramObject.createAndLink(canvas, [vertShader, fragShader]);

            glUseProgram(program.handle);

            maskUni = program.getUniformLocation('mask');
            program.setUniform1i(maskUni, 0);

            glUseProgram(0);

            obj.primitiveProgram = program;
        end

        function createTexturedPrimitiveProgram(obj, canvas)
            filePath = mfilename('fullpath');
            shadersDir = fileparts(filePath);

            vertShader = stage.core.gl.ShaderObject(canvas, GL.VERTEX_SHADER, fullfile(shadersDir, 'TexturedPrimitive.vert'));
            vertShader.compile();

            fragShader = stage.core.gl.ShaderObject(canvas, GL.FRAGMENT_SHADER, fullfile(shadersDir, 'TexturedPrimitive.frag'));
            fragShader.compile();

            program = stage.core.gl.ProgramObject.createAndLink(canvas, [vertShader, fragShader]);

            glUseProgram(program.handle);

            texUni = program.getUniformLocation('texture0');
            program.setUniform1i(texUni, 0);

            maskUni = program.getUniformLocation('mask');
            program.setUniform1i(maskUni, 1);

            glUseProgram(0);

            obj.texturedPrimitiveProgram = program;
        end

        function createFilteredTexturedPrimitiveProgram(obj, canvas)
            filePath = mfilename('fullpath');
            shadersDir = fileparts(filePath);

            vertShader = stage.core.gl.ShaderObject(canvas, GL.VERTEX_SHADER, fullfile(shadersDir, 'FilteredTexturedPrimitive.vert'));
            vertShader.compile();

            fragShader = stage.core.gl.ShaderObject(canvas, GL.FRAGMENT_SHADER, fullfile(shadersDir, 'FilteredTexturedPrimitive.frag'));
            fragShader.compile();

            program = stage.core.gl.ProgramObject.createAndLink(canvas, [vertShader, fragShader]);

            glUseProgram(program.handle);

            texUni = program.getUniformLocation('texture0');
            program.setUniform1i(texUni, 0);

            maskUni = program.getUniformLocation('mask');
            program.setUniform1i(maskUni, 1);

            kernelUni = program.getUniformLocation('kernel');
            program.setUniform1i(kernelUni, 2);

            glUseProgram(0);

            obj.filteredTexturedPrimitiveProgram = program;
        end

    end

end
