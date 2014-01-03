% This server has NO security features and should only be used on a trusted network. Only one client may be connected at
% a time.

classdef TcpServer < handle
    
    properties (SetAccess = private)
        port
    end
    
    events
        clientConnected
        clientDisconnected
        eventReceived
    end
    
    methods
        
        function obj = TcpServer(port)            
            if nargin < 1
                port = 5678;
            end
            
            obj.port = port;
        end
        
        % Starts listening for connections and serving clients. This method will block the serving Matlab session.
        function start(obj)
            socket = java.net.ServerSocket(obj.port);
            close = onCleanup(@()socket.close());            
            
            while true
                client = TcpClient(socket.accept());
                
                notify(obj, 'clientConnected', NetEventData(client));
                obj.serve(client);
            end
        end
        
        function serve(obj, client)
            while true
                try
                    value = client.receive();
                catch
                    notify(obj, 'clientDisconnected', NetEventData(client));
                    break;
                end
                
                if ~iscell(value)
                    value = {value};
                end
                
                notify(obj, 'eventReceived', NetEventData(client, value));
            end
        end
        
    end
    
end