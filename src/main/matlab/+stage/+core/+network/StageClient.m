% A client for interfacing with a remote StageServer.

classdef StageClient < handle

    properties (Access = private)
        netClient
    end

    methods
        
        function obj = StageClient(netClient)
            if nargin < 1
                netClient = stage.core.network.tcp.TcpClient();
            elseif isa(netClient, 'stage.core.network.StageClient')
                netClient = netClient.netClient;
            end
            obj.netClient = netClient;
        end

        function connect(obj, host, port)
            if nargin < 2
                host = 'localhost';
            end
            if nargin < 3
                port = 5678;
            end
            obj.netClient.connect(host, port);
        end

        function close(obj)
            obj.netClient.close();
        end
        
        % Gets the remote canvas size.
        function s = getCanvasSize(obj)
            obj.sendEvent(stage.core.network.StageEvents.GET_CANVAS_SIZE);
            s = obj.getResponse();
        end
        
        % Sets the remote canvas clear color. 
        function setCanvasClearColor(obj, color)
            obj.sendEvent(stage.core.network.StageEvents.SET_CANVAS_CLEAR_COLOR, color);
            obj.getResponse();
        end
        
        % Gets the remote monitor refresh rate.
        function r = getMonitorRefreshRate(obj)
            obj.sendEvent(stage.core.network.StageEvents.GET_MONITOR_REFRESH_RATE);
            r = obj.getResponse();
        end
        
        % Gets the remote monitor resolution.
        function r = getMonitorResolution(obj)
            obj.sendEvent(stage.core.network.StageEvents.GET_MONITOR_RESOLUTION);
            r = obj.getResponse();
        end
        
        % Gets the remote monitor red, green, and blue gamma ramp.
        function [red, green, blue] = getMonitorGammaRamp(obj)
            obj.sendEvent(stage.core.network.StageEvents.GET_MONITOR_GAMMA_RAMP);
            [red, green, blue] = obj.getResponse();
        end
        
        % Sets the remote monitor gamma ramp from the given red, green, and blue lookup tables. The tables should have 
        % length of 256 and values that range from 0 to 65535.
        function setMonitorGammaRamp(obj, red, green, blue)
            obj.sendEvent(stage.core.network.StageEvents.SET_MONITOR_GAMMA_RAMP, red, green, blue);
            obj.getResponse;
        end
        
        % Plays a given presentation on the remote canvas. This method will return immediately. While the presentation 
        % plays remotely, further attempts to interface with the server will block until the presentation completes.
        function play(obj, presentation, prerender)
            if nargin < 3
                prerender = false;
            end
            
            obj.sendEvent(stage.core.network.StageEvents.PLAY, presentation, prerender);
            obj.getResponse();
        end
        
        % Replays the last played presentation on the remote canvas.
        function replay(obj)
            obj.sendEvent(stage.core.network.StageEvents.REPLAY);
            obj.getResponse();
        end
        
        % Gets information about the last remotely played (or replayed) presentation.
        function i = getPlayInfo(obj)
            obj.sendEvent(stage.core.network.StageEvents.GET_PLAY_INFO);
            i = obj.getResponse();
        end
        
        % Clears the server memory (i.e. last play info and class definitions).
        function clearMemory(obj)
            obj.sendEvent(stage.core.network.StageEvents.CLEAR_MEMORY);
            obj.getResponse();
        end
        
    end
    
    methods (Access = protected)

        function sendEvent(obj, event, varargin)
            obj.netClient.send(event, varargin{:});
        end

        function varargout = getResponse(obj)
            r = obj.netClient.receive();
            
            event = r{1};
            if strcmp(event, stage.core.network.StageEvents.ERROR)
                throw(r{2});
            end
            
            varargout = r(2:end);
        end

    end

end
