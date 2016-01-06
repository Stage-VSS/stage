classdef Client < handle
    
    properties (Access = private)
        client
    end
    
    methods
        
        function obj = Client()
            obj.client = netbox.Client();
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
        
        function disconnect(obj)
            obj.client.disconnect();
        end
        
        % Plays a given presentation on the remote canvas. This method will return immediately. While the presentation 
        % plays remotely, further attempts to interface with the server will block until the presentation completes.
        function play(obj, presentation)
            e = netbox.Event('play', presentation);
            obj.sendReceive(e);
        end
        
        % Gets information about the last remotely played presentation.
        function i = getPlayInfo(obj)
            e = netbox.Event('getPlayInfo');
            i = obj.sendReceive(e);
        end
        
    end
    
    methods (Access = protected)
        
        function varargout = sendReceive(obj, event)
            obj.client.sendEvent(event);
            e = obj.client.receiveEvent();
            
            switch e.name
                case 'ok'
                    varargout = e.arguments;
                case 'error'
                    rethrow(e.arguments{1});
                otherwise
                    error('Unknown response');
            end
        end
        
    end
    
end

