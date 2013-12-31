% A TCP-based server enabling remote control of the serving Matlab session. The server recognizes three methods
% typically supplied by a connected TcpClient: EVAL, PUT, and GET.
%
% EVAL: Executes the supplied commands on the serving session.
% PUT: Assigns the supplied variable to the serving session's workspace.
% GET: Retrieves the variable with the supplied name from the serving session's workspace.
%
% This server has NO security features and should only be used on a trusted network. Only one client may be connected at
% a time.

classdef TcpServer < handle
    
    properties (SetAccess = private)
        port
    end
    
    methods
        
        function obj = TcpServer(port)            
            if nargin < 1
                port = 5678;
            end
            
            obj.port = port;
        end
        
        % Starts listening for connections and serving clients. This method will block the serving Matlab session until
        % execution is stopped via Ctrl+C or Ctrl+Break.
        function start(obj)
            socket = java.net.ServerSocket(obj.port);
            close = onCleanup(@()socket.close());            
            
            while true
                disp(['Awaiting connection on port: ' num2str(socket.getLocalPort())]);
                client = TcpClient(socket.accept());
                
                rhost = client.socket.getInetAddress().getHostName();
                rport = client.socket.getPort();
                disp(['Serving connection from ' char(rhost) ':' num2str(rport)]);
                
                obj.serve(client);
            end
        end
        
        function serve(obj, client)
            while true
                try
                    cmd = client.receive();
                catch
                    disp('Client disconnected');
                    break;
                end
                
                if ~iscell(cmd)
                    cmd = {cmd};
                end

                try
                    result = ['OK', obj.execute(cmd)];
                catch x
                    disp(['ERROR ', x.message]);
                    result = {'ERROR', x};
                end
                
                disp(result);
                client.send(result{:});
            end
        end
        
        function result = execute(obj, cmd) %#ok<INUSL>
            result = {};
            
            switch upper(cmd{1})
                case 'EVAL'
                    for i = 2:length(cmd)
                        disp(['EVAL ' cmd{i}]);
                        evalin('base', cmd{i});
                    end
                case 'PUT'
                    for i = 2:2:length(cmd)
                        disp(['PUT ' cmd{i}]);
                        assignin('base', cmd{i:i+1});
                    end
                case 'GET'
                    for i = 2:length(cmd)
                        disp(['GET ' cmd{i}]);
                        result{end + 1} = evalin('base', [cmd{i} ';']);
                    end 
                otherwise
                    error('Unknown command');
            end
        end
        
    end
    
end