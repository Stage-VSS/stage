classdef StageServer < handle
    
    properties (Access = private)
        tcpServer
        window
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
        
        % Creates a window and starts serving clients. All optional arguments are passed through to the Window 
        % constructor.
        function start(obj, varargin)
            obj.window = Window(varargin{:});
            
            disp(['Serving on port: ' num2str(obj.tcpServer.port)]);
            obj.tcpServer.start();
        end
        
        function onClientConnected(obj, src, data) %#ok<INUSL>
            rhost = data.client.socket.getInetAddress().getHostName();
            rport = data.client.socket.getPort();
            disp(['Serving connection from ' char(rhost) ':' num2str(rport)]);
        end
        
        function onClientDisconnected(obj, src, data) %#ok<INUSD>
            disp('Client disconnected');
        end
        
        function onEventReceived(obj, src, data) %#ok<INUSL>
            try
                result = obj.handleEvent(data);
            catch x
                result = {NetEvents.ERROR, x};
            end
            
            if ~iscell(result)
                result = {result};
            end
            
            disp(result{:});
            data.client.send(result{:});
        end
        
        function result = handleEvent(obj, data)
            value = data.value;
            result = {};
            
            switch value{1}
                case NetEvents.GET_WINDOW_SIZE
                    result = obj.window.size;
                case NetEvents.SET_CANVAS_COLOR
                    color = value{2};
                    obj.window.canvas.setClearColor(color);
                    obj.window.canvas.clear();
                    obj.window.flip();
                case NetEvents.PLAY
                    presentation = value{2};
                    result = presentation.play(obj.window.canvas);
                otherwise
                    error('Unknown event');
            end
        end
        
    end
    
end