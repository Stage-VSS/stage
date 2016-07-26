classdef Monitor < handle
    % Represents a physical display attached to the computer.
    
    properties (SetAccess = private)
        refreshRate     % Refresh rate (Hz)
        resolution      % Resolution [width, height] (pixels)
        physicalSize    % Physical size of display area [width, height] (mm)
        name            % Human-readable monitor name
        handle          % GLFW monitor handle
    end
    
    properties
        getRefreshRateFcn   % Allows users to specify a non-default refresh rate function
    end
    
    methods (Static)
        
        function m = availableMonitors()
            glfwInit();
            
            handles = glfwGetMonitors();
            m = cell(1, numel(handles));
            for i = 1:numel(handles)
                m{i} = stage.core.Monitor(i);
            end
        end
        
    end
    
    methods
        
        function obj = Monitor(number)
            % Constructs a monitor for the display with the given display number. The primary display is number 1. 
            % Further displays increment from there (2, 3, 4, etc).
            
            if nargin < 1
                number = 1;
            end
            
            glfwInit();
            
            monitors = glfwGetMonitors();
            obj.handle = monitors(number);
            
            obj.getRefreshRateFcn = @defaultGetRefreshRateFcn;
        end
        
        function r = get.refreshRate(obj)
            r = obj.getRefreshRateFcn(obj);
        end

        function r = defaultGetRefreshRateFcn(obj)
            mode = glfwGetVideoMode(obj.handle);
            r = mode.refreshRate;
        end
        
        function r = get.resolution(obj)
            mode = glfwGetVideoMode(obj.handle);
            r = [mode.width, mode.height];
        end
        
        function s = get.physicalSize(obj)
            [w, h] = glfwGetMonitorPhysicalSize(obj.handle);
            s = [w, h];
        end
        
        function n = get.name(obj)
            n = glfwGetMonitorName(obj.handle);
        end
        
        function setGamma(obj, gamma)
            % Sets a gamma ramp from the given gamma exponent.
            glfwSetGamma(obj.handle, gamma);
        end
        
        function [red, green, blue] = getGammaRamp(obj)
            ramp = glfwGetGammaRamp(obj.handle);
            
            red = ramp.red;
            green = ramp.green;
            blue = ramp.blue;
        end
        
        function setGammaRamp(obj, red, green, blue)
            % Sets a gamma ramp from the given red, green, and blue lookup tables. The tables should have length of 256 
            % and values that range from 0 to 65535.
            
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
    
end