classdef StageClient < handle
    
    properties
        tcpClient
    end
    
    methods
        
        function obj = StageClient()
            obj.tcpClient = TcpClient();
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
        
        function s = getWindowSize(obj)
            obj.tcpClient.send(NetEvents.GET_WINDOW_SIZE);
            response = obj.getResponse();
            s = response{1};
        end
        
        function setCanvasColor(obj, color)
            obj.tcpClient.send(NetEvents.SET_CANVAS_COLOR, color);
            obj.getResponse();
        end
        
        % Requests that the connected server play the given presentation. This method does not wait for a response and
        % returns immediately. getResponse must be called manually.
        function play(obj, presentation)
            obj.tcpClient.send(NetEvents.PLAY, presentation);
        end
        
        function r = getResponse(obj, timeOut)
            if nargin < 2
                timeOut = 5000;
            end
            
            obj.tcpClient.setReceiveTimeout(timeOut);
            r = obj.tcpClient.receive();
            
            if ~isempty(r) && strcmp(r{1}, NetEvents.ERROR)
                rethrow(r{2});
            end
        end
        
    end
    
end