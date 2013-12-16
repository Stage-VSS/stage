% Represents a physical display attached to the computer.

classdef Monitor < handle
    
    properties (SetAccess = private)
        refreshRate
        resolution
        name
        handle
    end
    
    methods
        
        % Constructs a monitor for the display with the given display number. The primary display is number 1. Further
        % displays increment from there (2, 3, 4, etc.).
        function obj = Monitor(number)
            if nargin < 1
                number = 1;
            end
            
            glfwInit();
            
            monitors = glfwGetMonitors();
            obj.handle = monitors(number);
        end
        
        function r = get.refreshRate(obj)
            mode = glfwGetVideoMode(obj.handle);
            r = mode.refreshRate;
        end
        
        function r = get.resolution(obj)
            mode = glfwGetVideoMode(obj.handle);
            r = [mode.width, mode.height];
        end
        
        function n = get.name(obj)
            n = glfwGetMonitorName(obj.handle);
        end
        
        function setGamma(obj, gamma)
            glfwSetGamma(obj.handle, gamma);
        end
        
    end
    
end