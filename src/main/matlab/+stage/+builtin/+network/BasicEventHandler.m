classdef BasicEventHandler < stage.core.network.EventHandler
    
    methods
        
        function obj = BasicEventHandler(canvas)
            obj@stage.core.network.EventHandler(canvas);
        end
        
    end
    
    methods (Access = protected)
        
        function onEvent(obj, connection, event)
            switch event.name
                case 'getCanvasSize'
                    obj.onEventGetCanvasSize(connection, event);
                case 'setCanvasClearColor'
                    obj.onEventSetCanvasClearColor(connection, event);
                case 'getMonitorRefreshRate'
                    obj.onEventGetMonitorRefreshRate(connection, event);
                case 'getMonitorResolution'
                    obj.onEventGetMonitorResolution(connection, event);
                case 'getMonitorGammaRamp'
                    obj.onEventGetMonitorGammaRamp(connection, event);
                case 'setMonitorGammaRamp'
                    obj.onEventSetMonitorGammaRamp(connection, event);
                case 'play'
                    obj.onEventPlay(connection, event);
                case 'replay'
                    obj.onEventReplay(connection, event);
                case 'getPlayInfo'
                    obj.onEventGetPlayInfo(connection, event);
                case 'clearMemory'
                    obj.onEventClearMemory(connection, event);
            end
        end
        
        function onEventGetCanvasSize(obj, connection, event) %#ok<INUSD>
            size = obj.canvas.size;
            connection.sendEvent(netbox.Event('ok', size));
        end
        
        function onEventSetCanvasClearColor(obj, connection, event)
            color = event.arguments{1};
            
            obj.canvas.setClearColor(color);
            connection.sendEvent(netbox.Event('ok'));
        end
        
        function onEventGetMonitorRefreshRate(obj, connection, event) %#ok<INUSD>
            rate = obj.canvas.window.monitor.refreshRate;
            connection.sendEvent(netbox.Event('ok', rate));
        end
        
        function onEventGetMonitorResolution(obj, connection, event) %#ok<INUSD>
            resolution = obj.canvas.window.monitor.resolution;
            connection.sendEvent(netbox.Event('ok', resolution));
        end
        
        function onEventGetMonitorGammaRamp(obj, connection, event) %#ok<INUSD>
            [red, green, blue] = obj.canvas.window.monitor.getGammaRamp();
            connection.sendEvent(netbox.Event('ok', {red, green, blue}));
        end
        
        function onEventSetMonitorGammaRamp(obj, connection, event)
            red = event.arguments{1};
            green = event.arguments{2};
            blue = event.arguments{3};
            
            obj.canvas.window.monitor.setGammaRamp(red, green, blue);
            connection.sendEvent(netbox.Event('ok'));
        end
        
        function onEventPlay(obj, connection, event)
            presentation = event.arguments{1};
            prerender = event.arguments{2};
            
            if prerender
                player = stage.builtin.players.PrerenderedPlayer(presentation);
            else
                player = stage.builtin.players.RealtimePlayer(presentation);
            end
            connection.setData('player', player);
            
            % Unlock client to allow async operations during play.
            connection.sendEvent(netbox.Event('ok'));
            
            try
                info = player.play(obj.canvas);
            catch x
                info = x;
            end
            connection.setData('playInfo', info);
        end
        
        function onEventReplay(obj, connection, event) %#ok<INUSD>
            if ~connection.isData('player');
                error('No player exists');
            end
            
            % Unlock client to allow async operations during play.
            connection.sendEvent(netbox.Event('ok'));
            
            try
                player = connection.getData('player');
                info = player.play(obj.canvas);
            catch x
                info = x;
            end
            connection.setData('playInfo', info);
        end
        
        function onEventGetPlayInfo(obj, connection, event) %#ok<INUSD,INUSL>
            info = connection.getData('playInfo');
            connection.sendEvent(netbox.Event('ok', info));
        end
        
        function onEventClearMemory(obj, connection, event) %#ok<INUSL,INUSD>
            connection.clearData();
            
            memory = inmem('-completenames');
            for i = 1:length(memory)
                [package, name] = appbox.packageName(memory{i});
                if ~isempty(package)
                    package = [package '.']; %#ok<AGROW>
                end
                if exist([package name], 'class')
                    clear(name);
                end
            end
            
            connection.sendEvent(netbox.Event('ok'));
        end
        
    end
    
end

