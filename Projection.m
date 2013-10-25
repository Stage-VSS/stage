classdef Projection < handle
    
    properties (SetAccess = protected)
        matrix
    end
    
    methods
        
        function apply(obj)
            mglTransform('GL_PROJECTION', 'glLoadMatrix', obj.matrix);
        end
        
    end
    
end