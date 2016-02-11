classdef Server < handle
    
    properties (Access = private)
        server
        eventHandler
    end
    
    methods
        
        function obj = Server(eventHandler)
            obj.server = netbox.Server();
            obj.eventHandler = eventHandler;
            
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
            obj.eventHandler.handleEvent(connection, event);
        end
        
        function onInterrupt(obj)
            window = obj.eventHandler.canvas.window;
            
            window.pollEvents();
            escState = window.getKeyState(GLFW.GLFW_KEY_ESCAPE);
            shiftState = window.getKeyState(GLFW.GLFW_KEY_LEFT_SHIFT);
            if escState == GLFW.GLFW_PRESS && shiftState == GLFW.GLFW_PRESS
                obj.server.requestStop();
            end
        end
        
    end
    
end

