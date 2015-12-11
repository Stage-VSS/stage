% A single-client server that allows remote access to a Stage session.

classdef StageServer < handle
    
    properties (Access = private)
        canvas
        sessionData
        netServer
    end

    methods
        
        function obj = StageServer(canvas, netServer)
            if nargin < 2
                netServer = stage.core.network.tcp.TcpServer();
            end
            obj.canvas = canvas;
            obj.netServer = netServer;

            addlistener(obj.netServer, 'ClientConnected', @obj.onClientConnected);
            addlistener(obj.netServer, 'ClientDisconnected', @obj.onClientDisconnected);
            addlistener(obj.netServer, 'EventReceived', @obj.onEventReceived);
            addlistener(obj.netServer, 'TimedOut', @obj.onTimedOut);
        end
        
        function start(obj, port)
            if nargin < 2
                port = 5678;
            end
            
            stop = onCleanup(@()obj.stop());

            disp(['Serving on port: ' num2str(port)]);
            disp('To exit press shift + escape while the Stage window has focus');
            obj.netServer.start(port);
        end

        % Automatically called when start completes.
        function stop(obj)
            obj.netServer.requestStop();
        end

    end

    methods (Access = protected)
        
        function onClientConnected(obj, src, data) %#ok<INUSL>
            rhost = data.client.socket.getInetAddress().getHostName();
            rport = data.client.socket.getPort();
            disp(['Serving connection from ' char(rhost) ':' num2str(rport)]);
            
            obj.sessionData.player = [];
            obj.sessionData.playInfo = [];
        end
        
        function onClientDisconnected(obj, src, data) %#ok<INUSD>
            disp('Client disconnected');
        end
        
        function onEventReceived(obj, src, event) %#ok<INUSL>
            import stage.core.network.StageEvents;
            
            client = event.client;
            value = event.value;
            
            try
                switch value{1}
                    case StageEvents.GET_CANVAS_SIZE
                        obj.onEventGetCanvasSize(client, value);
                    case StageEvents.SET_CANVAS_CLEAR_COLOR
                        obj.onEventSetCanvasClearColor(client, value);
                    case StageEvents.GET_MONITOR_REFRESH_RATE
                        obj.onEventGetMonitorRefreshRate(client, value);
                    case StageEvents.GET_MONITOR_RESOLUTION
                        obj.onEventGetMonitorResolution(client, value);
                    case StageEvents.GET_MONITOR_GAMMA_RAMP
                        obj.onEventGetMonitorGammaRamp(client, value);
                    case StageEvents.SET_MONITOR_GAMMA_RAMP
                        obj.onEventSetMonitorGammaRamp(client, value);
                    case StageEvents.PLAY
                        obj.onEventPlay(client, value);
                    case StageEvents.REPLAY
                        obj.onEventReplay(client, value);
                    case StageEvents.GET_PLAY_INFO
                        obj.onEventGetPlayInfo(client, value);
                    case StageEvents.CLEAR_MEMORY
                        obj.onEventClearMemory(client, value);
                    otherwise
                        error('Stage:UnknownEvent', 'Unknown event');
                end
            catch x
                client.send(StageEvents.ERROR, x);
            end
        end

        function onEventGetCanvasSize(obj, client, value) %#ok<INUSD>
            size = obj.canvas.size;
            client.send(stage.core.network.StageEvents.OK, size);
        end
        
        function onEventSetCanvasClearColor(obj, client, value)
            color = value{2};
            
            obj.canvas.setClearColor(color);
            client.send(stage.core.network.StageEvents.OK);
        end
        
        function onEventGetMonitorRefreshRate(obj, client, value) %#ok<INUSD>
            rate = obj.canvas.window.monitor.refreshRate;
            client.send(stage.core.network.StageEvents.OK, rate);
        end
        
        function onEventGetMonitorResolution(obj, client, value) %#ok<INUSD>
            resolution = obj.canvas.window.monitor.resolution;
            client.send(stage.core.network.StageEvents.OK, resolution);
        end
        
        function onEventGetMonitorGammaRamp(obj, client, value) %#ok<INUSD>
            [red, green, blue] = obj.canvas.window.monitor.getGammaRamp();
            client.send(stage.core.network.StageEvents.OK, red, green, blue);
        end
        
        function onEventSetMonitorGammaRamp(obj, client, value)
            red = value{2};
            green = value{3};
            blue = value{4};
            
            obj.canvas.window.monitor.setGammaRamp(red, green, blue);
            client.send(stage.core.network.StageEvents.OK);
        end
        
        function onEventPlay(obj, client, value)
            presentation = value{2};
            prerender = value{3};
            
            if prerender
                obj.sessionData.player = stage.builtin.players.PrerenderedPlayer(presentation);
            else
                obj.sessionData.player = stage.builtin.players.RealtimePlayer(presentation);
            end
            
            % Unlock client to allow async operations during play.
            client.send(stage.core.network.StageEvents.OK);
            
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
            client.send(stage.core.network.StageEvents.OK);
            
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
            client.send(stage.core.network.StageEvents.OK, info);
        end
        
        function onEventClearMemory(obj, client, value) %#ok<INUSD>
            obj.sessionData = [];
            
            memory = inmem;
            for i = 1:length(memory)
                clear(memory{i});
            end
            
            client.send(stage.core.network.StageEvents.OK);
        end
        
        function onTimedOut(obj, src, event) %#ok<INUSD>
            window = obj.canvas.window;
            
            window.pollEvents();
            escState = window.getKeyState(GLFW.GLFW_KEY_ESCAPE);
            shiftState = window.getKeyState(GLFW.GLFW_KEY_LEFT_SHIFT);
            if escState == GLFW.GLFW_PRESS && shiftState == GLFW.GLFW_PRESS
                obj.netServer.requestStop();
            end
        end

    end

end
