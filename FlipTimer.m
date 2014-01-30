% A timer for recording the duration between Window flips (buffer swaps). This class is used by Presentation.

classdef FlipTimer < handle
    
    properties (SetAccess = private)
        flipDurations
    end
    
    properties (Access = private)
        startTime
    end
    
    methods
        
        function tick(obj)
            currentTime = glfwGetTime();
            
            if isempty(obj.startTime)
                obj.startTime = currentTime;
            else
                obj.flipDurations(end + 1) = currentTime - obj.startTime;
                obj.startTime = currentTime;
            end
        end
        
    end
    
end