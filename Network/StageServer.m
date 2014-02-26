% A single-client server that allows remote access to a Stage session.

classdef StageServer < handle
    
    properties (Access = private)
        tcpServer
        canvas
        sessionData
    end
    
    methods
        
        function obj = StageServer(port)
            if nargin < 1
                port = 5678;
            end
            
            obj.tcpServer = TcpServer(port);
            
            addlistener(obj.tcpServer, 'clientConnected', @obj.onClientConnected);
            addlistener(obj.tcpServer, 'clientDisconnected', @obj.onClientDisconnected);
            addlistener(obj.tcpServer, 'eventReceived', @obj.onEventReceived);
            addlistener(obj.tcpServer, 'timedOut', @obj.onTimedOut);
        end
        
        % Creates a window and starts serving clients. All arguments are passed through to the Window constructor. This
        % method will block the current Matlab session until all clients are disconnected and the escape key is held
        % while the window has focus.
        function start(obj, varargin)
            window = Window(varargin{:});
            obj.canvas = Canvas(window);
            close = onCleanup(@()delete(obj.canvas));
            
            disp(['Serving on port: ' num2str(obj.tcpServer.port)]);
            obj.tcpServer.start();
        end
        
        function onClientConnected(obj, src, data) %#ok<INUSL>
            rhost = data.client.socket.getInetAddress().getHostName();
            rport = data.client.socket.getPort();
            disp(['Serving connection from ' char(rhost) ':' num2str(rport)]);
            
            obj.sessionData.playInfo = [];
        end
        
        function onClientDisconnected(obj, src, data) %#ok<INUSD>
            disp('Client disconnected');
            
            obj.sessionData = [];
            
            % Clear class definitions.
            memory = inmem;
            for i = 1:length(memory)
                if exist(memory{i}, 'class')
                    clear(memory{i});
                end
            end
        end
        
        function onEventReceived(obj, src, data) %#ok<INUSL>           
            client = data.client;
            value = data.value;
            
            switch value{1}
                case NetEvents.GET_CANVAS_SIZE
                    try
                        client.send(NetEvents.OK, obj.canvas.size);
                    catch x
                        client.send(NetEvents.ERROR, x);
                    end
                case NetEvents.SET_CANVAS_COLOR
                    try
                        color = value{2};
                        obj.canvas.setClearColor(color);
                        obj.canvas.clear();
                        obj.canvas.window.flip();
                        client.send(NetEvents.OK);
                    catch x
                        client.send(NetEvents.ERROR, x);
                    end
                case NetEvents.PLAY
                    client.send(NetEvents.OK);
                    try
                        presentation = value{2};
                        obj.sessionData.playInfo = presentation.play(obj.canvas);
                    catch x
                        obj.sessionData.playInfo = x;
                    end                  
                case NetEvents.GET_PLAY_INFO
                    client.send(NetEvents.OK, obj.sessionData.playInfo);
                otherwise
                    x = MException('Stage:StageServer', 'Unknown event');
                    client.send(NetEvents.ERROR, x);
            end
        end
        
        function onTimedOut(obj, src, data) %#ok<INUSD>
            window = obj.canvas.window;
            
            window.pollEvents();
            escState = window.getKeyState(GLFW.GLFW_KEY_ESCAPE);
            if escState == GLFW.GLFW_PRESS
                obj.tcpServer.requestStop();
            end
        end
        
    end
    
end