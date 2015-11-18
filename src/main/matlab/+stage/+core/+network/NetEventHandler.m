classdef NetEventHandler < handle
    
    properties (Access = protected)
        canvas
    end
    
    methods
        
        function obj = NetEventHandler(canvas)
            obj.canvas = canvas;
        end
        
    end
    
    methods (Abstract)
        handleEvent(obj, event);
    end
    
end

