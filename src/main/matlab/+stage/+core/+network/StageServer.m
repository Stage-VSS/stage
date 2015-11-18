% A single-client server that allows remote access to a Stage session.

classdef StageServer < handle
    
    properties (Access = private)
        window
        eventHandler
        tcpServer
    end

    methods
        
        function obj = StageServer(window, eventHandler)
            obj.window = window;
            obj.eventHandler = eventHandler;
            obj.tcpServer = stage.core.network.tcp.TcpServer();

            addlistener(obj.tcpServer, 'ClientConnected', @obj.onClientConnected);
            addlistener(obj.tcpServer, 'ClientDisconnected', @obj.onClientDisconnected);
            addlistener(obj.tcpServer, 'EventReceived', @obj.onEventReceived);
            addlistener(obj.tcpServer, 'TimedOut', @obj.onTimedOut);
        end
        
        function start(obj, port)
            if nargin < 2
                port = 5678;
            end
            
            stop = onCleanup(@()obj.stop());

            disp(['Serving on port: ' num2str(port)]);
            disp('To exit press shift + escape while the Stage window has focus');
            obj.tcpServer.start(port);
        end

        % Automatically called when start completes.
        function stop(obj)
            obj.tcpServer.requestStop();
        end

    end

    methods (Access = protected)

        function onClientConnected(obj, src, event) %#ok<INUSL>
            rhost = event.client.socket.getInetAddress().getHostName();
            rport = event.client.socket.getPort();
            disp(['Serving connection from ' char(rhost) ':' num2str(rport)]);
        end

        function onClientDisconnected(obj, src, event) %#ok<INUSD>
            disp('Client disconnected');
        end

        function onEventReceived(obj, src, event) %#ok<INUSL>
            obj.eventHandler.handleEvent(event);
        end
        
        function onTimedOut(obj, src, event) %#ok<INUSD>
            obj.window.pollEvents();
            escState = obj.window.getKeyState(GLFW.GLFW_KEY_ESCAPE);
            shiftState = obj.window.getKeyState(GLFW.GLFW_KEY_LEFT_SHIFT);
            if escState == GLFW.GLFW_PRESS && shiftState == GLFW.GLFW_PRESS
                obj.tcpServer.requestStop();
            end
        end

    end

end
