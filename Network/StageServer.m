% A single-client server that allows remote access to a Stage Window.

classdef StageServer < handle
    
    properties (Access = private)
        tcpServer
        window
        playInfo
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
        end
        
        % Creates a window and starts serving clients. All arguments are passed through to the Window constructor. This
        % method will block the current Matlab session until all clients are disconnected and Matlab receives a break
        % command (Ctrl+C).
        function start(obj, varargin)
            obj.window = Window(varargin{:});
            close = onCleanup(@()delete(obj.window));
            
            disp(['Serving on port: ' num2str(obj.tcpServer.port)]);
            obj.tcpServer.start();
        end
        
        function onClientConnected(obj, src, data) %#ok<INUSL>
            rhost = data.client.socket.getInetAddress().getHostName();
            rport = data.client.socket.getPort();
            disp(['Serving connection from ' char(rhost) ':' num2str(rport)]);
            
            obj.playInfo = [];
        end
        
        function onClientDisconnected(obj, src, data) %#ok<INUSD>
            disp('Client disconnected');
            
            % FIXME: Is there a better way to clear class definitions?
            warning('off', 'MATLAB:ClassInstanceExists');
            clear classes;
            warning('on', 'MATLAB:ClassInstanceExists');
        end
        
        function onEventReceived(obj, src, data) %#ok<INUSL>           
            client = data.client;
            value = data.value;
            
            switch value{1}
                case NetEvents.GET_WINDOW_SIZE
                    try
                        client.send(NetEvents.OK, obj.window.size);
                    catch x
                        client.send(NetEvents.ERROR, x);
                    end
                    
                case NetEvents.SET_CANVAS_COLOR
                    try
                        color = value{2};
                        obj.window.canvas.setClearColor(color);
                        obj.window.canvas.clear();
                        obj.window.flip();
                        client.send(NetEvents.OK);
                    catch x
                        client.send(NetEvents.ERROR, x);
                    end
                    
                case NetEvents.PLAY
                    client.send(NetEvents.OK);
                    try
                        presentation = value{2};
                        obj.playInfo = presentation.play(obj.window.canvas);
                    catch x
                        obj.playInfo = x;
                    end
                    
                case NetEvents.GET_PLAY_INFO
                    client.send(NetEvents.OK, obj.playInfo);
                    
                otherwise
                    x = MException('Stage:StageServer', 'Unknown event');
                    client.send(NetEvents.ERROR, x);
            end
        end
        
    end
    
end