classdef BasicClient < handle
    
    properties (SetAccess = private)
        client
    end
    
    methods
        
        function obj = BasicClient(client)
            obj.client = client;
        end
        
        function disconnect(obj)
            obj.client.disconnect();
        end
        
        % Gets the remote canvas size.
        function s = getCanvasSize(obj)
            e = netbox.Event('getCanvasSize');
            s = obj.client.sendReceiveEvent(e);
        end
        
        % Sets the remote canvas clear color. 
        function setCanvasClearColor(obj, color)
            e = netbox.Event('setCanvasClearColor', color);
            obj.client.sendReceiveEvent(e);
        end
        
        % Gets the remote monitor refresh rate.
        function r = getMonitorRefreshRate(obj)
            e = netbox.Event('getMonitorRefreshRate');
            r = obj.client.sendReceiveEvent(e);
        end
        
        % Gets the remote monitor resolution.
        function r = getMonitorResolution(obj)
            e = netbox.Event('getMonitorResolution');
            r = obj.client.sendReceiveEvent(e);
        end
        
        % Gets the remote monitor red, green, and blue gamma ramp.
        function [red, green, blue] = getMonitorGammaRamp(obj)
            e = netbox.Event('getMonitorGammaRamp');
            [red, green, blue] = obj.client.sendReceiveEvent(e);
        end
        
        % Sets the remote monitor gamma ramp from the given red, green, and blue lookup tables. The tables should have 
        % length of 256 and values that range from 0 to 65535.
        function setMonitorGammaRamp(obj, red, green, blue)
            e = netbox.Event('setMonitorGammaRamp', {red, green, blue});
            obj.client.sendReceiveEvent(e);
        end
        
        % Plays a given presentation on the remote canvas. This method will return immediately. While the presentation 
        % plays remotely, further attempts to interface with the server will block until the presentation completes.
        function play(obj, presentation, prerender)
            if nargin < 3
                prerender = false;
            end
            e = netbox.Event('play', {presentation, prerender});
            obj.client.sendReceiveEvent(e);
        end
        
        % Replays the last played presentation on the remote canvas.
        function replay(obj)
            e = netbox.Event('replay');
            obj.client.sendReceiveEvent(e);
        end
        
        % Gets information about the last remotely played (or replayed) presentation.
        function i = getPlayInfo(obj)
            e = netbox.Event('getPlayInfo');
            i = obj.client.sendReceiveEvent(e);
        end
        
        % Clears the current connection data and class definitions from the server.
        function clearMemory(obj)
            e = netbox.Event('clearMemory');
            obj.client.sendReceiveEvent(e);
        end
        
    end
    
end

