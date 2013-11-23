classdef FrameTimer < handle
    
    properties (SetAccess = private)
        longestFrameDuration
    end
    
    properties (Access = private)
        startTime
    end
    
    methods
        
        function obj = FrameTimer()
            obj.startTime = [];
            obj.longestFrameDuration = 0;
        end
        
        function tick(obj)
            currentTime = glfwGetTime();
            
            if isempty(obj.startTime)
                obj.startTime = currentTime;
            else
                duration = currentTime - obj.startTime;
                obj.longestFrameDuration = max(obj.longestFrameDuration, duration);
                obj.startTime = currentTime;
            end
        end
        
    end
    
end

