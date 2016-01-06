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
            obj.server.interruptFcn = @obj.onInterrupt;
        end
        
        function start(obj, port)
            if nargin < 2
                port = 5678;
            end            
            disp(['Serving on port: ' num2str(port)]);
            disp('To exit press shift + escape while the Stage window has focus');
            obj.server.start(port);
        end
        
    end
    
    methods (Access = private)
        
        function onClientConnected(obj, connection) %#ok<INUSL>
            disp(['Client connected from ' connection.getHostName()]);
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
        
        function onInterrupt(obj)
            window = obj.canvas.window;
            
            window.pollEvents();
            escState = window.getKeyState(GLFW.GLFW_KEY_ESCAPE);
            shiftState = window.getKeyState(GLFW.GLFW_KEY_LEFT_SHIFT);
            if escState == GLFW.GLFW_PRESS && shiftState == GLFW.GLFW_PRESS
                obj.server.requestStop();
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
                case 'clearMemory'
                    obj.onEventClearMemory(connection, event);                    
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
        
        function onEventClearMemory(obj, connection, event) %#ok<INUSL,INUSD>
            connection.clearData();
            
            memory = inmem('-completenames');
            for i = 1:length(memory)
                [package, name] = appbox.packageName(memory{i});
                if ~isempty(package)
                    package = [package '.']; %#ok<AGROW>
                end
                if exist([package name], 'class')
                    clear(name);
                end
            end
            
            connection.sendEvent(netbox.Event('ok'));
        end
        
    end
    
end

