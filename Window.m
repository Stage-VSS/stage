classdef Window < handle
    
    properties (SetAccess = private)
        canvas
        monitor
        size
        handle
    end
    
    methods
        
        % Constructs a window with the optionally provided size. By default the window occupies the fullscreen of the
        % primary monitor but an optional fullscreen and monitor argument enable windowed mode and/or selection of a
        % secondary monitor for the window.
        %
        % Typical usage:
        % % Windowed mode
        % window = Window([640, 480], false);
        %
        % % Fullscreen mode on primary monitor
        % window = Window();
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
                obj.handle = glfwCreateWindow(size(1), size(2), 'Stage', monitor.handle, []);
            else
                obj.handle = glfwCreateWindow(size(1), size(2), 'Stage', [], []);
            end
            
            obj.monitor = monitor;            
            glfwSwapInterval(1);
            
            obj.canvas = Canvas(obj);
        end
        
        function s = get.size(obj)
            [w, h] = glfwGetWindowSize(obj.handle);
            s = [w, h];
        end
        
        function flip(obj)
            glfwSwapBuffers(obj.handle);
        end
        
        function close(obj)
            delete(obj.canvas);
            
            % FIXME: Why is Matlab throwing 'Unexpected unknown exception from MEX file..' here?
            try
                glfwDestroyWindow(obj.handle);
            catch
                glfwDestroyWindow(obj.handle);
            end
        end
        
        function delete(obj)
            obj.close();
        end
        
    end
    
end

