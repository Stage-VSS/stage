% A client for interfacing with a remote StageServer.

classdef StageClient < handle
    
    properties (Access = private)
        tcpClient
    end
    
    methods
        
        % Constructs a client. If a host and/or port is provided the client will attempt to connect.
        function obj = StageClient(host, port)
            obj.tcpClient = TcpClient();
            obj.tcpClient.setReceiveTimeout(10000);
            
            if nargin > 1
                obj.connect(host, port);
            elseif nargin > 0
                obj.connect(host);
            end
        end
        
        function connect(obj, host, port)
            if nargin < 2
                host = 'localhost';
            end
            if nargin < 3
                port = 5678;
            end
            
            obj.tcpClient.connect(host, port);
        end
        
        % Gets the remote window size.
        function s = getWindowSize(obj)
            obj.tcpClient.send(NetEvents.GET_WINDOW_SIZE);
            s = obj.getResponse();
        end
        
        % Sets the remote canvas color. 
        function setCanvasColor(obj, color)
            obj.tcpClient.send(NetEvents.SET_CANVAS_COLOR, color);
            obj.getResponse();
        end
        
        % Plays a given presentation on the remote canvas. This method will return immediately. While the presentation 
        % plays remotely, further attempts to interface with the server will block until the presentation completes.
        function play(obj, presentation)
            obj.tcpClient.send(NetEvents.PLAY, presentation);
            obj.getResponse();
        end
        
        % Gets information about the last remotely played presentation.
        function i = getPlayInfo(obj)
            obj.tcpClient.send(NetEvents.GET_PLAY_INFO);
            i = obj.getResponse();
        end
        
    end
    
    methods (Access = private)
        
        function r = getResponse(obj)
            try
                r = obj.tcpClient.receive();
            catch x
                obj.tcpClient.close();
                rethrow(x);
            end
            
            if strcmp(r{1}, NetEvents.OK)
                if length(r) > 1
                    r = r{2:end};
                else
                    r = [];
                end
            elseif strcmp(r{1}, NetEvents.ERROR)
                rethrow(r{2});
            else
                error('Unknown response code');
            end
        end
        
    end
    
end