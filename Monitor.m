% Represents a physical display attached to the computer.

classdef Monitor < handle
    
    properties (SetAccess = private)
        refreshRate     % Refresh rate (Hz)
        resolution      % Resolution [width, height] (pixels)
        name            % Human-readable monitor name
        handle          % GLFW monitor handle
    end
    
    methods
        
        % Constructs a monitor for the display with the given display number. The primary display is number 1. Further
        % displays increment from there (2, 3, 4, etc).
        function obj = Monitor(number)
            if nargin < 1
                number = 1;
            end
            
            glfwInit();
            
            monitors = glfwGetMonitors();
            obj.handle = monitors(number);
        end
        
        function r = get.refreshRate(obj)
            r = obj.getRefreshRate();
        end
        
        function r = get.resolution(obj)
            mode = glfwGetVideoMode(obj.handle);
            r = [mode.width, mode.height];
        end
        
        function n = get.name(obj)
            n = glfwGetMonitorName(obj.handle);
        end
        
        % Sets a gamma ramp from the given gamma exponent.
        function setGamma(obj, gamma)
            glfwSetGamma(obj.handle, gamma);
        end
        
        % Sets a gamma ramp from the given red, green, and blue lookup tables. The tables should have length of 256 and
        % values that range from 0 to 65535.
        function setGammaRamp(obj, red, green, blue)
            % To row vector.
            red = red(:)';
            green = green(:)';
            blue = blue(:)';
            
            ramp.red = red;
            ramp.green = green;
            ramp.blue = blue;
            glfwSetGammaRamp(obj.handle, ramp);
        end
        
    end
    
    methods (Access = protected)
        
        % Allows overriding refresh rate getter.
        function r = getRefreshRate(obj)
            mode = glfwGetVideoMode(obj.handle);
            r = mode.refreshRate;
        end
        
    end
    
end