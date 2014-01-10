classdef FrameTimer < handle
    
    properties (SetAccess = private)
        frameDurations
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
                obj.frameDurations(end + 1) = currentTime - obj.startTime;
                obj.startTime = currentTime;
            end
        end
        
    end
    
end

