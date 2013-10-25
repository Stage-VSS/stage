classdef TcpClient < handle
    
    properties (SetAccess = private)
        socket
    end
    
    methods
        
        function obj = TcpClient(socket)
            if nargin < 1
                socket = java.net.Socket();
            end
            obj.socket = socket;
        end
        
        function connect(obj, host, port)
            if nargin < 2
                host = 'localhost';
            end
            
            if nargin < 3
                port = 5678;
            end
            
            addr = java.net.InetSocketAddress(host, port);
            obj.socket.connect(addr);
        end
        
        function close(obj)
            obj.socket.close();
        end
        
        function setReceiveTimeout(obj, t)
            obj.socket.setSoTimeout(t);
        end
        
        function response = request(obj, varargin)
            obj.send(varargin{:});
            response = obj.receive();
        end
        
        function send(obj, varargin)
            stream = java.io.ObjectOutputStream(obj.socket.getOutputStream());
            
            % Serialize
            temp = [tempname '.mat'];
            save(temp, 'varargin');
            file = java.io.File(temp);
            bytes = java.nio.file.Files.readAllBytes(file.toPath);
            delete(temp);
            varargin = javaArray('java.lang.Byte', length(bytes));
            for j = 1:length(bytes)
                varargin(j) = java.lang.Byte(bytes(j));
            end

            stream.writeObject(varargin);
        end
        
        function result = receive(obj)
            stream = java.io.ObjectInputStream(obj.socket.getInputStream());
            
            result = stream.readObject();
            
            % Deserialize
            temp = [tempname '.mat'];
            file = java.io.FileOutputStream(temp);
            file.write(arrayfun(@(x)double(x), result));
            s = load(temp);
            delete(temp);
            
            result = s.varargin;
        end
        
        function delete(obj)
            obj.close();
        end
        
    end
    
end

