% A client for interfacing with a remote StageServer.

classdef StageClient < handle
    
    properties (Access = private)
        tcpClient
    end
    
    methods
        
        function connect(obj, host, port)
            if nargin < 2
                host = 'localhost';
            end
            if nargin < 3
                port = 5678;
            end
            
            obj.disconnect();
            client = TcpClient();
            client.connect(host, port);
            
            obj.tcpClient = client;
        end
        
        function disconnect(obj)
            if isempty(obj.tcpClient)
                return;
            end
            
            obj.tcpClient.close();
            obj.tcpClient = [];
        end
        
        function delete(obj)
            obj.disconnect();
        end
        
        % Gets the remote canvas size.
        function s = getCanvasSize(obj)
            obj.sendEvent(NetEvents.GET_CANVAS_SIZE);
            s = obj.getResponse();
        end
        
        % Sets the remote canvas color. 
        function setCanvasColor(obj, color)
            obj.sendEvent(NetEvents.SET_CANVAS_COLOR, color);
            obj.getResponse();
        end
        
        % Plays a given presentation on the remote canvas. This method will return immediately. While the presentation 
        % plays remotely, further attempts to interface with the server will block until the presentation completes.
        function play(obj, presentation)
            obj.sendEvent(NetEvents.PLAY, presentation);
            obj.getResponse();
        end
        
        % Gets information about the last remotely played presentation.
        function i = getPlayInfo(obj)
            obj.sendEvent(NetEvents.GET_PLAY_INFO);
            i = obj.getResponse();
        end
        
    end
    
    methods (Access = protected)
        
        function sendEvent(obj, varargin)
            if isempty(obj.tcpClient)
                error('Not connected');
            end
            
            obj.tcpClient.send(varargin{:});
        end
        
        function r = getResponse(obj)
            if isempty(obj.tcpClient)
                error('Not connected');
            end
            
            try
                r = obj.tcpClient.receive();
            catch x
                obj.disconnect();
                rethrow(x);
            end
            
            if strcmp(r{1}, NetEvents.OK)
                if length(r) > 1
                    r = r{2:end};
                else
                    r = [];
                end
            elseif strcmp(r{1}, NetEvents.ERROR)
                throw(r{2});
            else
                error('Unknown response code');
            end
        end
        
    end
    
end