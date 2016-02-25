classdef StageClient < handle
    
    properties (SetAccess = private)
        isConnected
    end
    
    properties (Access = private)
        client
    end
    
    methods
        
        function obj = StageClient()
            obj.client = netbox.Client();
        end
        
        function connect(obj, host, port)
            if nargin < 2
                host = 'localhost';
            end
            if nargin < 3
                port = 5678;
            end
            obj.client.connect(host, port);
        end
        
        function disconnect(obj)
            obj.client.disconnect();
        end
        
        function tf = get.isConnected(obj)
            tf = obj.client.isConnected;
        end
        
        % Gets the remote canvas size.
        function s = getCanvasSize(obj)
            e = netbox.NetEvent('getCanvasSize');
            s = obj.sendReceive(e);
        end
        
        % Sets the remote canvas projection to identity matrix.
        function setCanvasProjectionIdentity(obj)
            e = netbox.NetEvent('setCanvasProjectionIdentity');
            obj.sendReceive(e);
        end
        
        % Sets the remote canvas projection orthographic.
        function setCanvasProjectionOrthographic(obj, left, right, bottom, top)
            e = netbox.NetEvent('setCanvasProjectionOrthographic', {left, right, bottom, top});
            obj.sendReceive(e);
        end
        
        % Resets the remote canvas projection matrix.
        function resetCanvasProjection(obj)
            e = netbox.NetEvent('resetCanvasProjection');
            obj.sendReceive(e);
        end
        
        % Sets the remote canvas renderer.
        function setCanvasRenderer(obj, renderer)
            e = netbox.NetEvent('setCanvasRenderer', renderer);
            obj.sendReceive(e);
        end
        
        % Resets the remote canvas renderer.
        function resetCanvasRenderer(obj)
            e = netbox.NetEvent('resetCanvasRenderer');
            obj.sendReceive(e);
        end
        
        % Gets the remote monitor refresh rate.
        function r = getMonitorRefreshRate(obj)
            e = netbox.NetEvent('getMonitorRefreshRate');
            r = obj.sendReceive(e);
        end
        
        % Sets the remote monitor gamma ramp from the given gamma exponent.
        function setMonitorGamma(obj, gamma)
            e = netbox.NetEvent('setMonitorGamma', gamma);
            obj.sendReceive(e);
        end
        
        % Gets the remote monitor resolution.
        function r = getMonitorResolution(obj)
            e = netbox.NetEvent('getMonitorResolution');
            r = obj.sendReceive(e);
        end
        
        % Gets the remote monitor red, green, and blue gamma ramp.
        function [red, green, blue] = getMonitorGammaRamp(obj)
            e = netbox.NetEvent('getMonitorGammaRamp');
            [red, green, blue] = obj.sendReceive(e);
        end
        
        % Sets the remote monitor gamma ramp from the given red, green, and blue lookup tables. The tables should have 
        % length of 256 and values that range from 0 to 65535.
        function setMonitorGammaRamp(obj, red, green, blue)
            e = netbox.NetEvent('setMonitorGammaRamp', {red, green, blue});
            obj.sendReceive(e);
        end
        
        % Plays a given player on the remote canvas. This method will return immediately. While the player plays 
        % remotely, further attempts to interface with the server will block until the presentation completes.
        function play(obj, player)
            e = netbox.NetEvent('play', player);
            obj.sendReceive(e);
        end
        
        % Replays the last played player on the remote canvas.
        function replay(obj)
            e = netbox.NetEvent('replay');
            obj.sendReceive(e);
        end
        
        % Gets information about the last remotely played (or replayed) presentation.
        function i = getPlayInfo(obj)
            e = netbox.NetEvent('getPlayInfo');
            i = obj.sendReceive(e);
        end
        
        % Clears the current connection data and class definitions from the server.
        function clearMemory(obj)
            e = netbox.NetEvent('clearMemory');
            obj.sendReceive(e);
        end
        
    end
    
    methods (Access = protected)
        
        function varargout = sendReceive(obj, event)
            obj.client.sendEvent(event);
            e = obj.client.receiveEvent();
            
            switch e.name
                case 'ok'
                    varargout = e.arguments;
                case 'error'
                    rethrow(e.arguments{1});
                otherwise
                    error('Unknown response');
            end
        end
        
    end
    
end

