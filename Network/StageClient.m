classdef StageClient < handle
    
    properties (Access = private)
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
            s = obj.getResponse();
        end
        
        function setCanvasColor(obj, color)
            obj.tcpClient.send(NetEvents.SET_CANVAS_COLOR, color);
            obj.getResponse();
        end
        
        function play(obj, presentation)
            obj.tcpClient.send(NetEvents.PLAY, presentation);
            obj.getResponse();
        end
        
        function i = getPlayInfo(obj)
            obj.tcpClient.send(NetEvents.GET_PLAY_INFO);
            i = obj.getResponse();
        end
        
    end
    
    methods (Access = private)
        
        function r = getResponse(obj)
            r = obj.tcpClient.receive();
            
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