classdef Server < handle
    
    properties (Access = private)
        server
        canvas
    end
    
    methods
        
        function obj = Server(canvas)
            obj.server = netbox.Server();
            obj.canvas = canvas;
            
            obj.server.clientConnectedFcn = @obj.onClientConnected;
            obj.server.clientDisconnectedFcn = @obj.onClientDisconnected;
            obj.server.eventReceivedFcn = @obj.onEventReceived;
        end
        
        function start(obj)
            disp('Serving...');
            disp('To exit press ctrl + c');
            obj.server.start();
        end
        
    end
    
    methods (Access = private)
        
        function onClientConnected(obj, connection) %#ok<INUSD>
            disp('Client connected');
        end
        
        function onClientDisconnected(obj, connection) %#ok<INUSD>
            disp('Client disconnected');
        end
        
        function onEventReceived(obj, connection, event)
            try
                obj.dispatchEvent(connection, event);
            catch x
                connection.sendEvent(netbox.Event('error', x));
            end
        end
        
    end
    
    methods (Access = protected)
        
        function dispatchEvent(obj, connection, event)            
            switch event.name
                case 'play'
                    obj.onEventPlay(connection, event);
                case 'getPlayInfo'
                    obj.onEventGetPlayInfo(connection, event);
            end
        end
        
        function onEventPlay(obj, connection, event)
            presentation = event.arguments{1};
            
            connection.sendEvent(netbox.Event('ok'));
            
            try
                info = presentation.play(obj.canvas);
            catch x
                info = x;
            end
            connection.setData('playInfo', info);
        end
        
        function onEventGetPlayInfo(obj, connection, event) %#ok<INUSL,INUSD>
            info = connection.getData('playInfo');
            connection.sendEvent(netbox.Event('ok', info));
        end
        
    end
    
end

