classdef Window < handle
    
    properties (SetAccess = private)
        monitor
        size
        glfwWindow
    end
    
    methods
        
        function obj = Window(size, fullscreen, monitor)
            if nargin < 1
                size = [640, 480];
            end
            if nargin < 2
                fullscreen = true;
            end
            if nargin < 3
                monitor = Monitor(1);
            end
            
            glfwWindowHint(GLFW.GLFW_RESIZABLE, GL.FALSE);
            
            if fullscreen
                obj.glfwWindow = glfwCreateWindow(size(1), size(2), 'Stage', monitor.glfwMonitor, []);
            else
                obj.glfwWindow = glfwCreateWindow(size(1), size(2), 'Stage', [], []);
            end
            
            obj.monitor = monitor;            
            glfwSwapInterval(1);
        end
        
        function s = get.size(obj)
            [w, h] = glfwGetWindowSize(obj.glfwWindow);
            s = [w, h];
        end
        
        function flip(obj)
            glfwSwapBuffers(obj.glfwWindow);
        end
        
        function close(obj)
            glfwDestroyWindow(obj.glfwWindow);
        end
        
    end
    
end

