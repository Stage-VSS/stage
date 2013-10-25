classdef RemoteStage
    
    properties
        client
    end
    
    methods
        
        function obj = RemoteStage()
            obj.client = TcpClient();
        end
        
        function connect(obj, host, port)
            if nargin < 2
                host = 'localhost';
            end
            
            if nargin < 3
                port = 5678;
            end
            
            obj.client.connect(host, port);
        end
        
        function screen = getScreen(obj, number)
            screen = Proxy(obj.client, ['screen' num2str(number)]);
        end
        
        function run(obj, presentation)
            
        end
        
    end
    
end

