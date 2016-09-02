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
        
        function s = getCanvasSize(obj)
            % Gets the remote canvas size.
            e = netbox.NetEvent('getCanvasSize');
            s = obj.sendReceive(e);
        end
        
        function setCanvasProjectionIdentity(obj)
            % Sets the remote canvas projection to identity matrix.
            e = netbox.NetEvent('setCanvasProjectionIdentity');
            obj.sendReceive(e);
        end
        
        function setCanvasProjectionTranslate(obj, x, y, z)
            % Translates the remote canvas projection
            e = netbox.NetEvent('setCanvasProjectionTranslate', {x, y, z});
            obj.sendReceive(e);
        end
        
        function setCanvasProjectionOrthographic(obj, left, right, bottom, top)
            % Sets the remote canvas projection orthographic.
            e = netbox.NetEvent('setCanvasProjectionOrthographic', {left, right, bottom, top});
            obj.sendReceive(e);
        end
        
        function resetCanvasProjection(obj)
            % Resets the remote canvas projection matrix.
            e = netbox.NetEvent('resetCanvasProjection');
            obj.sendReceive(e);
        end
        
        function setCanvasRenderer(obj, renderer)
            % Sets the remote canvas renderer.
            e = netbox.NetEvent('setCanvasRenderer', renderer);
            obj.sendReceive(e);
        end
        
        function resetCanvasRenderer(obj)
            % Resets the remote canvas renderer.
            e = netbox.NetEvent('resetCanvasRenderer');
            obj.sendReceive(e);
        end
        
        function r = getMonitorRefreshRate(obj)
            % Gets the remote monitor refresh rate.
            e = netbox.NetEvent('getMonitorRefreshRate');
            r = obj.sendReceive(e);
        end
        
        function setMonitorGamma(obj, gamma)
            % Sets the remote monitor gamma ramp from the given gamma exponent.
            e = netbox.NetEvent('setMonitorGamma', gamma);
            obj.sendReceive(e);
        end
        
        function r = getMonitorResolution(obj)
            % Gets the remote monitor resolution.
            e = netbox.NetEvent('getMonitorResolution');
            r = obj.sendReceive(e);
        end
        
        function [red, green, blue] = getMonitorGammaRamp(obj)
            % Gets the remote monitor red, green, and blue gamma ramp.
            e = netbox.NetEvent('getMonitorGammaRamp');
            [red, green, blue] = obj.sendReceive(e);
        end
        
        function setMonitorGammaRamp(obj, red, green, blue)
            % Sets the remote monitor gamma ramp from the given red, green, and blue lookup tables. The tables should 
            % have length of 256 and values that range from 0 to 65535.
            e = netbox.NetEvent('setMonitorGammaRamp', {red, green, blue});
            obj.sendReceive(e);
        end
        
        function play(obj, player)
            % Plays a given player on the remote canvas. This method will return immediately. While the player plays 
            % remotely, further attempts to interface with the server will block until the presentation completes.
            e = netbox.NetEvent('play', player);
            obj.sendReceive(e);
        end
        
        function replay(obj)
            % Replays the last played player on the remote canvas.
            e = netbox.NetEvent('replay');
            obj.sendReceive(e);
        end
        
        function i = getPlayInfo(obj)
            % Gets information about the last remotely played (or replayed) presentation.
            e = netbox.NetEvent('getPlayInfo');
            i = obj.sendReceive(e);
        end
        
        function clearMemory(obj)
            % Clears the current connection data and class definitions from the server.
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

