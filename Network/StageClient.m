classdef StageClient < handle
    
    properties
        tcpClient
    end
    
    methods
        
        function obj = StageClient()
            obj.tcpClient = TcpClient();
            obj.tcpClient.setReceiveTimeout(5000);
        end
        
        function connect(obj, host, port)
            if nargin < 2
                obj.tcpClient.connect();
            elseif nargin < 3
                obj.tcpClient.connect(host);
            else
                obj.tcpClient.connect(host, port);
            end
        end
        
        function play(obj, presentation)
            obj.tcpClient.send('PLAY', presentation);
        end
        
    end
    
end