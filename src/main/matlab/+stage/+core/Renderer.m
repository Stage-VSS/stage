classdef Renderer < handle
    % A renderer is responsible for drawing primitives on a canvas.
    
    properties (SetAccess = private)
        canvas
        projection  % Projection matrix stack
        modelView   % Model/View matrix stack
    end

    properties (Access = protected)
        defaultMask
    end

    methods

        function obj = Renderer(canvas)
            if nargin > 0
                obj.init(canvas);
            end

            obj.projection = stage.core.gl.MatrixStack();
            obj.modelView = stage.core.gl.MatrixStack();
        end

        function init(obj, canvas)
            obj.canvas = canvas;

            obj.defaultMask = stage.core.Mask(ones(2, 2, 'uint8') * 255);
            obj.defaultMask.init(canvas);
        end
        
        function drawArray(obj, array, mode, first, count, color, mask, texture, filter)
            % Renders primitives from the vertex array object data. Mask, texture, and filter may be set to empty.            
            if isempty(mask)
                mask = obj.defaultMask;
            end

            obj.canvas.makeCurrent();

            obj.setupProgram(color, mask, texture, filter);

            glBindVertexArray(array.handle);
            glDrawArrays(mode, first, count);
            glBindVertexArray(0);

            glBindTexture(mask.texture.target, 0);

            if ~isempty(texture)
                glBindTexture(texture.target, 0);
            end

            if ~isempty(filter)
                glBindTexture(filter.texture.target, 0);
            end
        end

    end

    methods (Access = protected)

        function setupProgram(obj, color, mask, texture, filter)
            if isempty(texture)
                program = obj.canvas.standardPrograms.primitiveProgram;
                obj.canvas.setProgram(program);

                glActiveTexture(GL.TEXTURE0);
                glBindTexture(mask.texture.target, mask.texture.handle);
            elseif isempty(filter)
                program = obj.canvas.standardPrograms.texturedPrimitiveProgram;
                obj.canvas.setProgram(program);

                glActiveTexture(GL.TEXTURE0);
                glBindTexture(texture.target, texture.handle);

                glActiveTexture(GL.TEXTURE1);
                glBindTexture(mask.texture.target, mask.texture.handle);
            else
                program = obj.canvas.standardPrograms.filteredTexturedPrimitiveProgram;
                obj.canvas.setProgram(program);

                glActiveTexture(GL.TEXTURE0);
                glBindTexture(texture.target, texture.handle);

                glActiveTexture(GL.TEXTURE1);
                glBindTexture(mask.texture.target, mask.texture.handle);

                glActiveTexture(GL.TEXTURE2);
                glBindTexture(filter.texture.target, filter.texture.handle);

                kernelSizeUniform = program.getUniformLocation('kernelSize');
                program.setUniformfv(kernelSizeUniform, filter.texture.size);

                texture0SizeUniform = program.getUniformLocation('texture0Size');
                program.setUniformfv(texture0SizeUniform, texture.size);
            end

            projectUniform = program.getUniformLocation('projectionMatrix');
            program.setUniformMatrix(projectUniform, obj.projection.top());

            modelUniform = program.getUniformLocation('modelViewMatrix');
            program.setUniformMatrix(modelUniform, obj.modelView.top());

            colorUniform = program.getUniformLocation('color0');
            program.setUniformfv(colorUniform, color);
        end

    end

end
