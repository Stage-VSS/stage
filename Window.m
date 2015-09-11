classdef Window < handle
    
    properties (SetAccess = private)
        monitor     % Monitor containing the window
        size        % Size [width, height] (pixels)
        handle      % GLFW window handle
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
        function obj = Window(size, fullscreen, monitor, varargin)
            if nargin < 1
                size = [640, 480];
            end
            if nargin < 2
                fullscreen = true;
            end
            if nargin < 3
                monitor = Monitor(1);
            end
            ip = inputParser();
            ip.addParameter('RefreshRate', 60);
            ip.addParameter('Visible', GL.TRUE);
            ip.parse(varargin{:});
            
            glfwInit();
            
            glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MAJOR, 3);
            glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MINOR, 2);
            glfwWindowHint(GLFW.GLFW_OPENGL_FORWARD_COMPAT, GL.TRUE);
            glfwWindowHint(GLFW.GLFW_OPENGL_PROFILE, GLFW.GLFW_OPENGL_CORE_PROFILE);
            glfwWindowHint(GLFW.GLFW_RESIZABLE, GL.FALSE);
            glfwWindowHint(GLFW.GLFW_REFRESH_RATE, ip.Results.RefreshRate);
            glfwWindowHint(GLFW.GLFW_VISIBLE, ip.Results.Visible);
            
            if fullscreen
                obj.handle = glfwCreateWindow(size(1), size(2), 'Stage', monitor.handle, []);
            else
                obj.handle = glfwCreateWindow(size(1), size(2), 'Stage', [], []);
            end
            
            if ~obj.handle
                error('Unable to create window. Verify your drivers support OpenGL 3.2+.');
            end
            
            obj.monitor = monitor;
            
            glfwSetInputMode(obj.handle, GLFW.GLFW_CURSOR, GLFW.GLFW_CURSOR_HIDDEN);
        end
        
        function s = get.size(obj)
            [w, h] = glfwGetWindowSize(obj.handle);
            s = [w, h];
        end
        
        % Swaps the front and back buffers of this window. 
        function flip(obj)
            glfwSwapBuffers(obj.handle);
        end
        
        % Processes keyboard and mouse events received by this window.
        function pollEvents(obj) %#ok<MANU>
            glfwPollEvents();
        end
        
        % Gets the last polled state of the specified keyboard key while this window had focus. See GLFW.m for key codes. 
        function s = getKeyState(obj, key)
            s = glfwGetKey(obj.handle, key);
        end
        
        function delete(obj)
            if obj.handle
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