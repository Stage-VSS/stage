classdef Monitor < handle
    
    properties (SetAccess = private)
        refreshRate
        resolution
        glfwMonitor
    end
    
    methods
        
        function obj = Monitor(number)
            monitors = glfwGetMonitors();
            obj.glfwMonitor = monitors(number);
        end
        
        function r = get.refreshRate(obj)
            mode = glfwGetVideoMode(obj.glfwMonitor);
            r = mode.refreshRate;
        end
        
        function r = get.resolution(obj)
            mode = glfwGetVideoMode(obj.glfwMonitor);
            r = [mode.width, mode.height];
        end
        
        function setGamma(obj, gamma)
            glfwSetGamma(obj.glfwMonitor, gamma);
        end
        
    end
    
end