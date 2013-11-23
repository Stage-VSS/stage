classdef Grating < Stimulus
    
    properties
        position = [0, 0]
        size = [100, 100]
        orientation = 0
        mask
        color = 1
        contrast = 1
        phase = 0           % degrees
        spatialFreq = 1/100 % cycles/pixels
        resolution = 512    % power of 2
    end
    
    properties (Access = private)
        texture
    end
    
    methods
        
        function init(obj)
            w = obj.size(1);
            inc = w / obj.resolution;
            image = sin(2 * pi * obj.spatialFreq * (0:inc:w-inc) + (obj.phase / 180 * pi)) * 0.5 * obj.contrast + 0.5;
            obj.texture = mglCreateTexture(image * 255);
        end
        
        function draw(obj)
            %mglTransform('GL_MODELVIEW', 'glPushMatrix');
            %mglTransform('GL_MODELVIEW', 'glTranslate', obj.position(1), obj.position(2), 0); 
            %mglTransform('GL_MODELVIEW', 'glRotate', obj.orientation, 0, 0, 1);
            
            mglBltTexture(obj.texture, [obj.position obj.size], 0, 0, obj.orientation);
            
            %mglTransform('GL_MODELVIEW', 'glPopMatrix');
        end
        
        function delete(obj)
            mglDeleteTexture(obj.texture);
        end
        
    end
    
end

