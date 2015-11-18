% A client for interfacing with a remote StageServer.

classdef StageClient < handle

    properties (Access = private)
        tcpClient
    end

    methods

        function connect(obj, host, port)
            if nargin < 2
                host = 'localhost';
            end
            if nargin < 3
                port = 5678;
            end

            obj.disconnect();
            client = stage.core.network.tcp.TcpClient();

            try
                client.connect(host, port);
            catch x
                error(['Unable to connect to Stage: ' x.message]);
            end

            obj.tcpClient = client;
        end

        function disconnect(obj)
            if isempty(obj.tcpClient)
                return;
            end

            obj.tcpClient.close();
            obj.tcpClient = [];
        end

        function sendEvent(obj, varargin)
            if isempty(obj.tcpClient)
                error('Not connected');
            end

            obj.tcpClient.send(varargin{:});
        end

        function varargout = getResponse(obj)
            if isempty(obj.tcpClient)
                error('Not connected');
            end

            try
                r = obj.tcpClient.receive();
            catch x
                obj.disconnect();
                rethrow(x);
            end

            if strcmp(r{1}, stage.core.network.NetEvents.OK)
                if length(r) > 1
                    varargout = r(2:end);
                else
                    varargout = [];
                end
            elseif strcmp(r{1}, stage.core.network.NetEvents.ERROR)
                throw(r{2});
            else
                error('Unknown response code');
            end
        end

    end

end
