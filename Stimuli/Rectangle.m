classdef Rectangle < Stimulus
    
    properties
        position = [0, 0]   % [x, y]
        size = [100, 100]   % [width, height]
        orientation = 0     % degrees
        color = 1
        antiAliasing = true
    end
    
    methods
        
        function draw(obj)
            mglTransform('GL_MODELVIEW', 'glPushMatrix');
            mglTransform('GL_MODELVIEW', 'glTranslate', obj.position(1), obj.position(2), 0); 
            mglTransform('GL_MODELVIEW', 'glRotate', obj.orientation, 0, 0, 1);
            
            w = obj.size(1)/2;
            h = obj.size(2)/2;
            if length(obj.color) == 1
                r = obj.color;
                g = obj.color;
                b = obj.color;
            else
                r = obj.color(1);
                g = obj.color(2);
                b = obj.color(3);
            end
            if obj.antiAliasing
                aa = 1;
            else
                aa = 0;
            end
            
            mglQuad([-w; w; w; -w], [-h; -h; h; h], [r; g; b], aa);
            
            mglTransform('GL_MODELVIEW', 'glPopMatrix');
        end
        
    end
    
end