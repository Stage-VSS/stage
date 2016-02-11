classdef BasicClient < handle
    
    properties (Access = private)
        client
    end
    
    methods
        
        function obj = BasicClient(client)
            obj.client = client;
        end
        
        % Plays a given presentation on the remote canvas. This method will return immediately. While the presentation 
        % plays remotely, further attempts to interface with the server will block until the presentation completes.
        function play(obj, presentation)
            e = netbox.Event('play', presentation);
            obj.client.sendReceive(e);
        end
        
        % Gets information about the last remotely played presentation.
        function i = getPlayInfo(obj)
            e = netbox.Event('getPlayInfo');
            i = obj.client.sendReceive(e);
        end
        
        % Clears the current connection data and class definitions from the server.
        function clearMemory(obj)
            e = netbox.Event('clearMemory');
            obj.client.sendReceive(e);
        end
        
    end
    
end

