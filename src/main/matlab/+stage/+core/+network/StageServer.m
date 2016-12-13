classdef StageServer < handle
    
    properties (Access = protected)
        canvas
    end
    
    properties (Access = private)
        server
        port
    end
    
    methods
        
        function obj = StageServer(port)
            if nargin < 1
                port = 5678;
            end
            
            obj.server = netbox.Server();
            obj.port = port;
            
            addlistener(obj.server, 'ClientConnected', @obj.onClientConnected);
            addlistener(obj.server, 'ClientDisconnected', @obj.onClientDisconnected);
            addlistener(obj.server, 'EventReceived', @obj.onEventReceived);
            addlistener(obj.server, 'Interrupt', @obj.onInterrupt);
        end
        
        function start(obj, size, fullscreen, monitor, varargin)
            % Creates a window/canvas and starts serving clients. This method will block the current Matlab session 
            % until the shift and escape key are held while the window has focus.
            
            if nargin < 2
                size = [640, 480];
            end
            if nargin < 3
                fullscreen = true;
            end
            if nargin < 4
                monitor = stage.core.Monitor(1);
            end
            ip = inputParser();
            ip.addParameter('disableDwm', true);
            ip.parse(varargin{:});
            
            stop = onCleanup(@()obj.stop());
            
            window = stage.core.Window(size, fullscreen, monitor);
            obj.canvas = stage.core.Canvas(window, 'disableDwm', ip.Results.disableDwm);
            obj.canvas.clear();
            obj.canvas.window.flip();
            
            disp(['Serving on port: ' num2str(obj.port)]);
            disp('To exit press shift + escape while the Stage window has focus');
            obj.server.start(obj.port);
        end
        
        function stop(obj)
            % Automatically called when start completes.
            
            obj.server.requestStop();
            % TODO: Wait until tcpServer stops.
            
            delete(obj.canvas);
        end
        
    end
    
    methods (Access = protected)
        
        function onClientConnected(obj, ~, eventData) %#ok<INUSL>
            disp(['Client connected from ' eventData.connection.getHostName()]);
        end
        
        function onClientDisconnected(obj, ~, eventData) %#ok<INUSD>
            disp('Client disconnected');
        end
        
        function onInterrupt(obj, ~, ~)
            window = obj.canvas.window;
            
            window.pollEvents();
            escState = window.getKeyState(GLFW.GLFW_KEY_ESCAPE);
            shiftState = window.getKeyState(GLFW.GLFW_KEY_LEFT_SHIFT);
            if escState == GLFW.GLFW_PRESS && shiftState == GLFW.GLFW_PRESS
                obj.server.requestStop();
            end
        end
        
        function onEventReceived(obj, ~, eventData)
            connection = eventData.connection;
            event = eventData.event;
            
            try
                switch event.name
                    case 'getCanvasSize'
                        obj.onEventGetCanvasSize(connection, event);
                    case 'setCanvasProjectionIdentity'
                        obj.onEventSetCanvasProjectionIdentity(connection, event);
                    case 'setCanvasProjectionTranslate'
                        obj.onEventSetCanvasProjectionTranslate(connection, event);                        
                    case 'setCanvasProjectionOrthographic'
                        obj.onEventSetCanvasProjectionOrthographic(connection, event);
                    case 'resetCanvasProjection'
                        obj.onEventResetCanvasProjection(connection, event);
                    case 'setCanvasRenderer'
                        obj.onEventSetCanvasRenderer(connection, event);
                    case 'resetCanvasRenderer'
                        obj.onEventResetCanvasRenderer(connection, event);
                    case 'getMonitorRefreshRate'
                        obj.onEventGetMonitorRefreshRate(connection, event);
                    case 'getMonitorResolution'
                        obj.onEventGetMonitorResolution(connection, event);
                    case 'setMonitorGamma'
                        obj.onEventSetMonitorGamma(connection, event);
                    case 'getMonitorGammaRamp'
                        obj.onEventGetMonitorGammaRamp(connection, event);
                    case 'setMonitorGammaRamp'
                        obj.onEventSetMonitorGammaRamp(connection, event);
                    case 'play'
                        obj.onEventPlay(connection, event);
                    case 'replay'
                        obj.onEventReplay(connection, event);
                    case 'getPlayInfo'
                        obj.onEventGetPlayInfo(connection, event);
                    case 'clearMemory'
                        obj.onEventClearMemory(connection, event);
                    otherwise
                        error('Unknown event');
                end
            catch x
                connection.sendEvent(netbox.NetEvent('error', x));
            end
        end
        
        function onEventGetCanvasSize(obj, connection, event) %#ok<INUSD>
            size = obj.canvas.size;
            connection.sendEvent(netbox.NetEvent('ok', size));
        end
        
        function onEventSetCanvasProjectionIdentity(obj, connection, event) %#ok<INUSD>
            obj.canvas.projection.setIdentity();
            connection.sendEvent(netbox.NetEvent('ok'));
        end
        
        function onEventSetCanvasProjectionTranslate(obj, connection, event)
            x = event.arguments{1};
            y = event.arguments{2};
            z = event.arguments{3};
            
            obj.canvas.projection.translate(x, y, z);
            connection.sendEvent(netbox.NetEvent('ok'));
        end
        
        function onEventSetCanvasProjectionOrthographic(obj, connection, event)
            left = event.arguments{1};
            right = event.arguments{2};
            bottom = event.arguments{3};
            top = event.arguments{4};
            
            obj.canvas.projection.orthographic(left, right, bottom, top);
            connection.sendEvent(netbox.NetEvent('ok'));
        end
        
        function onEventResetCanvasProjection(obj, connection, event) %#ok<INUSD>
            obj.canvas.resetProjection();
            connection.sendEvent(netbox.NetEvent('ok'));
        end
        
        function onEventSetCanvasRenderer(obj, connection, event)
            renderer = event.arguments{1};
            
            obj.canvas.setRenderer(renderer);
            connection.sendEvent(netbox.NetEvent('ok'));
        end
        
        function onEventResetCanvasRenderer(obj, connection, event) %#ok<INUSD>
            obj.canvas.resetRenderer();
            connection.sendEvent(netbox.NetEvent('ok'));
        end
        
        function onEventGetMonitorRefreshRate(obj, connection, event) %#ok<INUSD>
            rate = obj.canvas.window.monitor.refreshRate;
            connection.sendEvent(netbox.NetEvent('ok', rate));
        end
        
        function onEventGetMonitorResolution(obj, connection, event) %#ok<INUSD>
            resolution = obj.canvas.window.monitor.resolution;
            connection.sendEvent(netbox.NetEvent('ok', resolution));
        end
        
        function onEventSetMonitorGamma(obj, connection, event)
            gamma = event.arguments{1};
            
            obj.canvas.window.monitor.setGamma(gamma);
            connection.sendEvent(netbox.NetEvent('ok'));
        end
        
        function onEventGetMonitorGammaRamp(obj, connection, event) %#ok<INUSD>
            [red, green, blue] = obj.canvas.window.monitor.getGammaRamp();
            connection.sendEvent(netbox.NetEvent('ok', {red, green, blue}));
        end
        
        function onEventSetMonitorGammaRamp(obj, connection, event)
            red = event.arguments{1};
            green = event.arguments{2};
            blue = event.arguments{3};
            
            obj.canvas.window.monitor.setGammaRamp(red, green, blue);
            connection.sendEvent(netbox.NetEvent('ok'));
        end
        
        function onEventPlay(obj, connection, event)
            player = event.arguments{1};
            
            connection.setData('player', player);
            
            % Unlock client to allow async operations during play.
            connection.sendEvent(netbox.NetEvent('ok'));
            
            try
                info = player.play(obj.canvas);
            catch x
                info = x;
            end
            connection.setData('playInfo', info);
        end
        
        function onEventReplay(obj, connection, event) %#ok<INUSD>
            if ~connection.isData('player');
                error('No player exists');
            end
            
            % Unlock client to allow async operations during play.
            connection.sendEvent(netbox.NetEvent('ok'));
            
            try
                player = connection.getData('player');
                info = player.play(obj.canvas);
            catch x
                info = x;
            end
            connection.setData('playInfo', info);
        end
        
        function onEventGetPlayInfo(obj, connection, event) %#ok<INUSD,INUSL>
            info = connection.getData('playInfo');
            connection.sendEvent(netbox.NetEvent('ok', info));
        end
        
        function onEventClearMemory(obj, connection, event) %#ok<INUSL,INUSD>
            connection.clearData();
            
            memory = inmem('-completenames');
            for i = 1:length(memory)
                % Don't bother clearing anything under the MATLAB root directory
                if strncmp(memory{i}, matlabroot, length(matlabroot))
                    continue;
                end
                [package, name] = appbox.packageName(memory{i});
                % Don't bother clearning anything under the stage package
                if strncmp(package, 'stage.', length('stage.'))
                    continue;
                end
                if ~isempty(package)
                    package = [package '.']; %#ok<AGROW>
                end
                if exist([package name], 'class')
                    clear(name);
                end
            end
            
            connection.sendEvent(netbox.NetEvent('ok'));
        end
        
    end
    
end

