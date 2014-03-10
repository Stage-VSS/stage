% A Renderer is responsible for drawing primitives on a Canvas.

classdef Renderer < handle
    
    properties (Access = protected)
        canvas
        defaultMask
    end
    
    methods
        
        function setCanvas(obj, canvas)
            obj.canvas = canvas;
            
            obj.defaultMask = Mask(ones(2, 2, 'uint8') * 255);
            obj.defaultMask.init(canvas);
        end
        
        function drawArray(obj, array, mode, first, count, color, texture, mask, filter)
            if isempty(mask)
                mask = obj.defaultMask;
            end
            
            obj.canvas.makeCurrent();
            
            obj.setupProgram(color, texture, mask, filter);
            
            glBindVertexArray(array.handle);
            glDrawArrays(mode, first, count);
            glBindVertexArray(0);
            
            if ~isempty(texture)
                glBindTexture(texture.target, 0);
            end
            
            if ~isempty(filter)
                glBindTexture(filter.texture.target, 0);
            end
            
            glBindTexture(mask.texture.target, 0);
        end
        
    end
    
    methods (Access = protected)
        
        function setupProgram(obj, color, texture, mask, filter)            
            if isempty(texture)
                obj.canvas.setProgram('Primitive');
                
                glActiveTexture(GL.TEXTURE0);
                glBindTexture(mask.texture.target, mask.texture.handle);
            elseif isempty(filter)
                obj.canvas.setProgram('TexturedPrimitive');
                
                glActiveTexture(GL.TEXTURE0);
                glBindTexture(texture.target, texture.handle);
                
                glActiveTexture(GL.TEXTURE1);
                glBindTexture(mask.texture.target, mask.texture.handle);
            else
                obj.canvas.setProgram('FilteredTexturedPrimitive');
                
                glActiveTexture(GL.TEXTURE0);
                glBindTexture(texture.target, texture.handle);
                
                glActiveTexture(GL.TEXTURE1);
                glBindTexture(mask.texture.target, mask.texture.handle);

                glActiveTexture(GL.TEXTURE2);
                glBindTexture(filter.texture.target, filter.texture.handle);
                
                program = obj.canvas.currentProgram;
                
                kernelSizeUniform = program.getUniformLocation('kernelSize');
                program.setUniformfv(kernelSizeUniform, filter.texture.size);
                
                texture0SizeUniform = program.getUniformLocation('texture0Size');                
                program.setUniformfv(texture0SizeUniform, texture.size);
            end
            
            program = obj.canvas.currentProgram;
            
            projectUniform = program.getUniformLocation('projectionMatrix');
            program.setUniformMatrix(projectUniform, obj.canvas.projection.top());
            
            modelUniform = program.getUniformLocation('modelViewMatrix');
            program.setUniformMatrix(modelUniform, obj.canvas.modelView.top());
            
            colorUniform = program.getUniformLocation('color0');
            program.setUniformfv(colorUniform, color);
        end
        
    end
    
end