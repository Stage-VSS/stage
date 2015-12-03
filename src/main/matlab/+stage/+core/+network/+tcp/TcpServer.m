classdef TcpServer < handle

    events
        ClientConnected
        ClientDisconnected
        EventReceived
        TimedOut
    end

    properties (Access = private)
        stopRequested
    end

    methods

        % Starts listening for connections and serving clients. This method will block the serving Matlab session.
        function start(obj, port)
            if nargin < 2
                port = 5678;
            end

            obj.stopRequested = false;
            socket = [];

            while ~obj.stopRequested
                if isempty(socket) || socket.isClosed
                    socket = java.net.ServerSocket(port);
                    socket.setSoTimeout(10);
                    closeSocket = onCleanup(@()socket.close());
                end

                try
                    client = stage.core.network.tcp.TcpClient(socket.accept());
                catch x
                    if isa(x.ExceptionObject, 'java.net.SocketTimeoutException')
                        notify(obj, 'TimedOut');
                        continue;
                    else
                        rethrow(x);
                    end
                end

                delete(closeSocket);

                notify(obj, 'ClientConnected', stage.core.network.tcp.TcpEventData(client));
                obj.serve(client);

                client.close();
            end
        end

        function requestStop(obj)
            obj.stopRequested = true;
        end

        function serve(obj, client)
            client.setReceiveTimeout(10);

            while ~obj.stopRequested
                try
                    value = client.receive();
                catch x
                    if strcmp(x.identifier, 'TcpClient:ReceiveTimeout')
                        notify(obj, 'TimedOut');
                        continue;
                    else
                        rethrow(x);
                    end
                end

                if ~iscell(value)
                    value = {value};
                end

                if length(value) == 1 && isscalar(value{1}) && value{1} == -1
                    notify(obj, 'ClientDisconnected', stage.core.network.tcp.TcpEventData(client));
                    break;
                end

                notify(obj, 'EventReceived', stage.core.network.tcp.TcpEventData(client, value));
            end
        end

    end

end
