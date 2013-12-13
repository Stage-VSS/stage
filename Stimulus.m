% Abstract class for all visual stimuli.

classdef Stimulus < handle
    
    properties (SetAccess = private)
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