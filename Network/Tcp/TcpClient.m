% A TCP-based client requiring Java 7.

classdef TcpClient < handle
    
    properties (SetAccess = private, Transient)
        socket
    end
    
    properties (Access = private)
        receiveTimeout
    end
    
    methods
        
        function obj = TcpClient(socket)
            if ~strncmpi(version('-java'), 'Java 1.7', 8)
                error('Java 7 required');
            end
            
            if nargin < 1
                socket = java.net.Socket();
            end
            
            obj.socket = socket;
            obj.receiveTimeout = 10000;
        end
        
        % Connects to the specified host ip on the specified port.
        function connect(obj, host, port)
            if nargin < 2
                host = 'localhost';
            end
            
            if nargin < 3
                port = 5678;
            end
            
            addr = java.net.InetSocketAddress(host, port);
            timeout = 10000;             
            obj.socket.connect(addr, timeout);
        end
        
        function close(obj)
            if ~obj.socket.isClosed
                try %#ok<TRYNC>
                    % Disconnect message.
                    obj.send(-1);
                end
                obj.socket.close();
            end
        end
        
        % Sets receive timeout in milliseconds.
        function setReceiveTimeout(obj, t)
            obj.receiveTimeout = t;
        end
        
        function send(obj, varargin)
            stream = java.io.ObjectOutputStream(obj.socket.getOutputStream());
            
            % Serialize
            temp = [tempname '.mat'];
            save(temp, 'varargin');
            file = java.io.File(temp);
            
            stream.writeObject(java.nio.file.Files.readAllBytes(file.toPath));
            delete(temp);
        end
        
        function result = receive(obj)
            in = obj.socket.getInputStream();
            
            start = tic;
            while in.available() == 0
                if toc(start) >= obj.receiveTimeout / 1e3
                    error('TcpClient:ReceiveTimeout', 'Receive timeout');
                end
            end
            
            stream = java.io.ObjectInputStream(in);
            
            result = stream.readObject();
            
            % Deserialize
            temp = [tempname '.mat'];
            fid = fopen(temp, 'w');
            fwrite(fid, typecast(result, 'uint8'));
            fclose(fid);
            s = load(temp);
            delete(temp);
            
            result = s.varargin;
        end
        
        function delete(obj)
            obj.close();
        end
        
    end
    
    methods (Static)
        
        function obj = loadobj(lobj)
            obj = lobj;
            obj.socket = java.net.Socket();
        end
        
    end
    
end