classdef StageServer < handle
    
    properties (Access = private)
        tcpServer
    end
    
    methods
        
        function obj = StageServer(port)
            if nargin < 1
                obj.tcpServer = TcpServer();
            else
                obj.tcpServer = TcpServer(port);
            end
            
            addlistener(obj.tcpServer, 'clientConnected', @obj.onClientConnected);
            addlistener(obj.tcpServer, 'clientDisconnected', @obj.onClientDisconnected);
            addlistener(obj.tcpServer, 'eventReceived', @obj.onEventReceived);
        end
        
        function start(obj)
            disp(['Serving on port: ' num2str(obj.tcpServer.port)]);
            obj.tcpServer.start();
        end
        
        function onClientConnected(obj, src, data) %#ok<INUSL>
            rhost = data.client.socket.getInetAddress().getHostName();
            rport = data.client.socket.getPort();
            disp(['Serving connection from ' char(rhost) ':' num2str(rport)]);
        end
        
        function onClientDisconnected(obj, src, data) %#ok<INUSD>
            disp('Client disconnected');
        end
        
        function onEventReceived(obj, src, data) %#ok<INUSL>
            client = data.client;
            value = data.value;
            
            try
                result = {'OK', obj.process(value)};
            catch x
                result = {'ERROR', x};
            end
            
            disp(result);
            client.send(result{:});
        end
        
        function result = process(obj, value)
            result = {};
            
            switch upper(value{1})
                case 'PLAY'
                    disp('Playing...');
                    result{end + 1} = 'It played!';
                otherwise
                    error('Unknown event');
            end
        end
        
    end
    
end

