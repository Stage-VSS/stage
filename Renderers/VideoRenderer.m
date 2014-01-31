classdef VideoRenderer < Renderer
    
    properties (Access = private)
        defaultMask
    end
    
    methods
        
        function obj = VideoRenderer(canvas)
            obj = obj@Renderer(canvas);
            
            obj.defaultMask = TextureObject(canvas, 2);
            obj.defaultMask.setImage(ones(1, 1, 4, 'uint8') * 255);
        end
        
        function drawArray(obj, array, mode, first, count, color, texture, mask)            
            obj.canvas.makeCurrent();
            
            if isempty(texture)
                obj.canvas.setProgram('PositionOnly');
            else
                obj.canvas.setProgram('SingleTexture');
                
                glActiveTexture(GL.TEXTURE0);
                glBindTexture(texture.target, texture.handle);
                
                glActiveTexture(GL.TEXTURE1);
                if isempty(mask)
                    glBindTexture(obj.defaultMask.target, obj.defaultMask.handle);
                else
                    glBindTexture(mask.texture.target, mask.texture.handle);
                end
            end
            
            program = obj.canvas.currentProgram;
            projectUniform = program.getUniformLocation('projectionMatrix');
            modelUniform = program.getUniformLocation('modelViewMatrix');
            colorUniform = program.getUniformLocation('color0');
            
            program.setUniformMatrix(projectUniform, obj.canvas.projection.top());
            program.setUniformMatrix(modelUniform, obj.canvas.modelView.top());
            program.setUniformfv(colorUniform, color);
            
            glBindVertexArray(array.handle);
            glDrawArrays(mode, first, count);
            glBindVertexArray(0);
            
            if ~isempty(texture)
                glBindTexture(texture.target, 0);
                if ~isempty(mask)
                    glBindTexture(obj.defaultMask.target, 0);
                else
                    glBindTexture(mask.texture.target, 0);
                end
            end
        end
        
    end
    
end