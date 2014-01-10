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
        % secondary monitor for the window. The optional refreshRate argument is ignored for windowed mode.
        %
        % Typical usage:
        % % Windowed mode
        % window = Window([640, 480], false);
        %
        % % Fullscreen mode on primary monitor
        % window = Window();
        function obj = Window(size, fullscreen, monitor, refreshRate)
            if nargin < 1
                size = [640, 480];
            end
            if nargin < 2
                fullscreen = true;
            end
            if nargin < 3
                monitor = Monitor(1);
            end
            if nargin < 4
                refreshRate = 60;
            end
            
            glfwInit();
            
            glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MAJOR, 3);
            glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MINOR, 2);
            glfwWindowHint(GLFW.GLFW_OPENGL_FORWARD_COMPAT, GL.TRUE);
            glfwWindowHint(GLFW.GLFW_OPENGL_PROFILE, GLFW.GLFW_OPENGL_CORE_PROFILE);
            glfwWindowHint(GLFW.GLFW_RESIZABLE, GL.FALSE);
            glfwWindowHint(GLFW.GLFW_REFRESH_RATE, refreshRate);
            
            if fullscreen
                obj.handle = glfwCreateWindow(size(1), size(2), 'Stage', monitor.handle, []);
            else
                obj.handle = glfwCreateWindow(size(1), size(2), 'Stage', [], []);
            end
            
            if ~obj.handle
                glfwTerminate();
                error('Unable to create window. Verify your drivers support OpenGL 3.2+.');
            end
            
            obj.monitor = monitor;
            obj.canvas = Canvas(obj);
            
            glfwSwapInterval(1);
            glfwSetInputMode(obj.handle, GLFW.GLFW_CURSOR, GLFW.GLFW_CURSOR_HIDDEN);
        end
        
        function s = get.size(obj)
            [w, h] = glfwGetWindowSize(obj.handle);
            s = [w, h];
        end
        
        function flip(obj)
            glfwSwapBuffers(obj.handle);
        end
        
        function delete(obj)
            if ~isempty(obj.handle)
                delete(obj.canvas);
                
                % FIXME: Why is Matlab throwing 'Unexpected unknown exception from MEX file..' here?
                try
                    glfwDestroyWindow(obj.handle);
                catch
                    glfwDestroyWindow(obj.handle);
                end
            end
        end
        
    end
    
end