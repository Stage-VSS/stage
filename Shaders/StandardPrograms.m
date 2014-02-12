classdef StandardPrograms < handle
    
    properties (SetAccess = private)
        positionOnlyProgram
        singleTextureProgram
        singleFilterProgram
    end
    
    methods
        
        function obj = StandardPrograms(canvas)            
            obj.createPositionOnlyProgram(canvas);
            obj.createSingleTextureProgram(canvas);
            obj.createSingleFilterProgram(canvas);
        end
        
    end
    
    methods (Access = private)
        
        function createPositionOnlyProgram(obj, canvas)
            filePath = mfilename('fullpath');
            shadersDir = fileparts(filePath);
            
            vertShader = ShaderObject(canvas, GL.VERTEX_SHADER, fullfile(shadersDir, 'PositionOnly.vert'));
            vertShader.compile();
            
            fragShader = ShaderObject(canvas, GL.FRAGMENT_SHADER, fullfile(shadersDir, 'PositionOnly.frag'));
            fragShader.compile();
            
            obj.positionOnlyProgram = ProgramObject.createAndLink(canvas, [vertShader, fragShader]);
        end
        
        function createSingleTextureProgram(obj, canvas)
            filePath = mfilename('fullpath');
            shadersDir = fileparts(filePath);
            
            vertShader = ShaderObject(canvas, GL.VERTEX_SHADER, fullfile(shadersDir, 'SingleTexture.vert'));
            vertShader.compile();
            
            fragShader = ShaderObject(canvas, GL.FRAGMENT_SHADER, fullfile(shadersDir, 'SingleTexture.frag'));
            fragShader.compile();
            
            program = ProgramObject.createAndLink(canvas, [vertShader, fragShader]);
            
            glUseProgram(program.handle);
            
            texUni = program.getUniformLocation('texture0');
            program.setUniform1i(texUni, 0);
            
            maskUni = program.getUniformLocation('mask');
            program.setUniform1i(maskUni, 1);
            
            glUseProgram(0);
            
            obj.singleTextureProgram = program;
        end
        
        function createSingleFilterProgram(obj, canvas)
            filePath = mfilename('fullpath');
            shadersDir = fileparts(filePath);
            
            vertShader = ShaderObject(canvas, GL.VERTEX_SHADER, fullfile(shadersDir, 'SingleFilter.vert'));
            vertShader.compile();
            
            fragShader = ShaderObject(canvas, GL.FRAGMENT_SHADER, fullfile(shadersDir, 'SingleFilter.frag'));
            fragShader.compile();
            
            program = ProgramObject.createAndLink(canvas, [vertShader, fragShader]);
            
            glUseProgram(program.handle);
            
            texUni = program.getUniformLocation('texture0');
            program.setUniform1i(texUni, 0);
            
            maskUni = program.getUniformLocation('mask');
            program.setUniform1i(maskUni, 1);
            
            kernelUni = program.getUniformLocation('kernel');
            program.setUniform1i(kernelUni, 2);
            
            glUseProgram(0);
            
            obj.singleFilterProgram = program;
        end
        
    end
    
end