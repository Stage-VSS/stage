classdef FlipTimer < handle
    % A timer for recording the duration between window flips (buffer swaps). This class is generally used by 
    % presentation players.
    
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