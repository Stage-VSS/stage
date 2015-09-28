% A client for interfacing with a remote StageServer.

classdef StageClient < handle

    properties (Access = private)
        tcpClient
    end

    methods

        function obj = StageClient(stageClient)
            if nargin >= 1 && ~isempty(stageClient)
                obj.tcpClient = stageClient.tcpClient;
            end
        end

        function connect(obj, host, port)
            if nargin < 2
                host = 'localhost';
            end
            if nargin < 3
                port = 5678;
            end

            obj.disconnect();
            client = stage.core.network.tcp.TcpClient();

            try
                client.connect(host, port);
            catch x
                error(['Unable to connect to Stage: ' x.message]);
            end

            obj.tcpClient = client;
        end

        function disconnect(obj)
            if isempty(obj.tcpClient)
                return;
            end

            obj.tcpClient.close();
            obj.tcpClient = [];
        end

        % Gets the remote canvas size.
        function s = getCanvasSize(obj)
            obj.sendEvent(stage.core.network.NetEvents.GET_CANVAS_SIZE);
            s = obj.getResponse();
        end

        % Sets the remote canvas clear color.
        function setCanvasClearColor(obj, color)
            obj.sendEvent(stage.core.network.NetEvents.SET_CANVAS_CLEAR_COLOR, color);
            obj.getResponse();
        end

        % Gets the remote monitor refresh rate.
        function r = getMonitorRefreshRate(obj)
            obj.sendEvent(stage.core.network.NetEvents.GET_MONITOR_REFRESH_RATE);
            r = obj.getResponse();
        end

        % Gets the remote monitor resolution.
        function r = getMonitorResolution(obj)
            obj.sendEvent(stage.core.network.NetEvents.GET_MONITOR_RESOLUTION);
            r = obj.getResponse();
        end

        % Gets the remote monitor red, green, and blue gamma ramp.
        function [red, green, blue] = getMonitorGammaRamp(obj)
            obj.sendEvent(stage.core.network.NetEvents.GET_MONITOR_GAMMA_RAMP);
            [red, green, blue] = obj.getResponse();
        end

        % Sets the remote monitor gamma ramp from the given red, green, and blue lookup tables. The tables should have
        % length of 256 and values that range from 0 to 65535.
        function setMonitorGammaRamp(obj, red, green, blue)
            obj.sendEvent(stage.core.network.NetEvents.SET_MONITOR_GAMMA_RAMP, red, green, blue);
            obj.getResponse;
        end

        % Plays a given presentation on the remote canvas. This method will return immediately. While the presentation
        % plays remotely, further attempts to interface with the server will block until the presentation completes.
        function play(obj, presentation, prerender)
            if nargin < 3
                prerender = false;
            end

            obj.sendEvent(stage.core.network.NetEvents.PLAY, presentation, prerender);
            obj.getResponse();
        end

        % Replays the last played presentation on the remote canvas.
        function replay(obj)
            obj.sendEvent(stage.core.network.NetEvents.REPLAY);
            obj.getResponse();
        end

        % Gets information about the last remotely played (or replayed) presentation.
        function i = getPlayInfo(obj)
            obj.sendEvent(stage.core.network.NetEvents.GET_PLAY_INFO);
            i = obj.getResponse();
        end

        % Clears the current session data and class definitions from the server.
        function clearSessionData(obj)
            obj.sendEvent(stage.core.network.NetEvents.CLEAR_SESSION_DATA);
            obj.getResponse();
        end

    end

    methods (Access = protected)

        function sendEvent(obj, varargin)
            if isempty(obj.tcpClient)
                error('Not connected');
            end

            obj.tcpClient.send(varargin{:});
        end

        function varargout = getResponse(obj)
            if isempty(obj.tcpClient)
                error('Not connected');
            end

            try
                r = obj.tcpClient.receive();
            catch x
                obj.disconnect();
                rethrow(x);
            end

            if strcmp(r{1}, stage.core.network.NetEvents.OK)
                if length(r) > 1
                    varargout = r(2:end);
                else
                    varargout = [];
                end
            elseif strcmp(r{1}, stage.core.network.NetEvents.ERROR)
                throw(r{2});
            else
                error('Unknown response code');
            end
        end

    end

end
