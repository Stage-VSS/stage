% A single-client server that allows remote access to a Stage session.

classdef StageServer < handle
    
    properties (Access = protected)
        canvas
        sessionData
    end
    
    properties (Access = private)
        tcpServer
    end
    
    methods
        
        function obj = StageServer(port)
            if nargin < 1
                port = 5678;
            end
            
            obj.tcpServer = TcpServer(port);
            
            addlistener(obj.tcpServer, 'clientConnected', @obj.onClientConnected);
            addlistener(obj.tcpServer, 'clientDisconnected', @obj.onClientDisconnected);
            addlistener(obj.tcpServer, 'eventReceived', @obj.onEventReceived);
            addlistener(obj.tcpServer, 'timedOut', @obj.onTimedOut);
        end
        
        % Creates a window/canvas and starts serving clients. All arguments are passed through to the Window 
        % constructor. This method will block the current Matlab session until the shift and escape key are held while 
        % the window has focus.
        function start(obj, varargin)
            stop = onCleanup(@()obj.stop());
            
            window = Window(varargin{:});
            obj.canvas = Canvas(window);
            
            obj.willStart();
            
            disp(['Serving on port: ' num2str(obj.tcpServer.port)]);
            obj.tcpServer.start();
        end
        
        % Automatically called when start completes.
        function stop(obj)
            obj.tcpServer.requestStop();
            % TODO: Wait until tcpServer stops.
            
            delete(obj.canvas);
            
            obj.didStop();
        end
        
    end
    
    methods (Access = protected)
        
        function willStart(obj) %#ok<MANU>
            % Available for subclasses.
        end
        
        function didStop(obj) %#ok<MANU>
            % Available for subclasses.
        end
        
        function onClientConnected(obj, src, data) %#ok<INUSL>
            rhost = data.client.socket.getInetAddress().getHostName();
            rport = data.client.socket.getPort();
            disp(['Serving connection from ' char(rhost) ':' num2str(rport)]);
            
            obj.sessionData.player = [];
            obj.sessionData.playInfo = [];
        end
        
        function onClientDisconnected(obj, src, data) %#ok<INUSD>
            disp('Client disconnected');
            obj.clearSessionData();
        end
        
        function clearSessionData(obj)
            obj.sessionData = [];
            
            % Clear class definitions.
            memory = inmem;
            for i = 1:length(memory)
                if exist(memory{i}, 'class')
                    clear(memory{i});
                end
            end
        end
        
        function onEventReceived(obj, src, data) %#ok<INUSL>           
            client = data.client;
            value = data.value;
            
            try
                switch value{1}
                    case NetEvents.GET_CANVAS_SIZE
                        obj.onEventGetCanvasSize(client, value);
                    case NetEvents.SET_CANVAS_COLOR
                        obj.onEventSetCanvasColor(client, value);
                    case NetEvents.GET_MONITOR_REFRESH_RATE
                        obj.onEventGetMonitorRefreshRate(client, value);
                    case NetEvents.GET_MONITOR_RESOLUTION
                        obj.onEventGetMonitorResolution(client, value);
                    case NetEvents.SET_MONITOR_GAMMA_RAMP
                        obj.onEventSetMonitorGammaRamp(client, value);
                    case NetEvents.PLAY
                        obj.onEventPlay(client, value);
                    case NetEvents.REPLAY
                        obj.onEventReplay(client, value);
                    case NetEvents.GET_PLAY_INFO
                        obj.onEventGetPlayInfo(client, value);
                    case NetEvents.CLEAR_SESSION_DATA
                        obj.onEventClearSessionData(client, value);
                    otherwise
                        error('Stage:UnknownEvent', 'Unknown event');
                end
            catch x
                client.send(NetEvents.ERROR, x);
            end
        end
        
        function onEventGetCanvasSize(obj, client, value) %#ok<INUSD>
            size = obj.canvas.size;
            client.send(NetEvents.OK, size);
        end
        
        function onEventSetCanvasColor(obj, client, value)
            color = value{2};
            
            obj.canvas.setClearColor(color);
            obj.canvas.clear();
            obj.canvas.window.flip();
            client.send(NetEvents.OK);
        end
        
        function onEventGetMonitorRefreshRate(obj, client, value) %#ok<INUSD>
            rate = obj.canvas.window.monitor.refreshRate;
            client.send(NetEvents.OK, rate);
        end
        
        function onEventGetMonitorResolution(obj, client, value) %#ok<INUSD>
            resolution = obj.canvas.window.monitor.resolution;
            client.send(NetEvents.OK, resolution);
        end
        
        function onEventSetMonitorGammaRamp(obj, client, value)
            red = value{2};
            green = value{3};
            blue = value{4};
            
            obj.canvas.window.monitor.setGammaRamp(red, green, blue);
            client.send(NetEvents.OK);
        end
        
        function onEventPlay(obj, client, value)
            presentation = value{2};
            prerender = value{3};
            
            if prerender
                obj.sessionData.player = PrerenderedPlayer(presentation);
            else
                obj.sessionData.player = RealtimePlayer(presentation);
            end
            
            % Unlock client to allow async operations during play.
            client.send(NetEvents.OK);
            
            try
                obj.sessionData.playInfo = obj.sessionData.player.play(obj.canvas);
            catch x
                obj.sessionData.playInfo = x;
            end
        end
        
        function onEventReplay(obj, client, value) %#ok<INUSD>
            if isempty(obj.sessionData.player)
                error('No player exists');
            end
            
            % Unlock client to allow async operations during play.
            client.send(NetEvents.OK);
            
            try
                player = obj.sessionData.player;
                if ismethod(player, 'replay')
                    obj.sessionData.playInfo = player.replay(obj.canvas);
                else
                    obj.sessionData.playInfo = player.play(obj.canvas);
                end
            catch x
                obj.sessionData.playInfo = x;
            end
        end
        
        function onEventGetPlayInfo(obj, client, value) %#ok<INUSD>
            info = obj.sessionData.playInfo;
            client.send(NetEvents.OK, info);
        end
        
        function onEventClearSessionData(obj, client, value) %#ok<INUSD>
            obj.clearSessionData();
            client.send(NetEvents.OK);
        end
        
        function onTimedOut(obj, src, data) %#ok<INUSD>
            window = obj.canvas.window;
            
            window.pollEvents();
            escState = window.getKeyState(GLFW.GLFW_KEY_ESCAPE);
            shiftState = window.getKeyState(GLFW.GLFW_KEY_LEFT_SHIFT);
            if escState == GLFW.GLFW_PRESS && shiftState == GLFW.GLFW_PRESS
                obj.tcpServer.requestStop();
            end
        end
        
    end
    
end