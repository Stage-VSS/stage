classdef Renderer < handle
    
    properties (SetAccess = private)
        canvas
    end
    
    methods
        
        function obj = Renderer(canvas)
            obj.canvas = canvas;
        end
        
    end
    
    methods (Abstract)
        drawArray(obj, array, mode, first, count, color, texture, mask);
    end
    
end