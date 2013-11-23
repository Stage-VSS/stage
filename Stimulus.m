classdef Stimulus < handle
    
    properties
        canvas
    end
    
    methods
        
        function init(obj, canvas)
            obj.canvas = canvas;
        end
        
    end
        
    methods (Abstract)
        draw(obj);
    end
    
end

