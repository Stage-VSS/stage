classdef BasicNetEventHandler < stage.core.network.NetEventHandler
    
    properties (Access = protected)
        data
    end
    
    methods
        
        function obj = BasicNetEventHandler(canvas)
            obj@stage.core.network.NetEventHandler(canvas);
        end
        
        function handleEvent(obj, event)
            import stage.core.network.NetEvents;
            
            client = event.client;
            value = event.value;
            
            try
                switch value{1}
                    case NetEvents.GET_CANVAS_SIZE
                        obj.onEventGetCanvasSize(client, value);
                    case NetEvents.SET_CANVAS_CLEAR_COLOR
                        obj.onEventSetCanvasClearColor(client, value);
                    case NetEvents.GET_MONITOR_REFRESH_RATE
                        obj.onEventGetMonitorRefreshRate(client, value);
                    case NetEvents.GET_MONITOR_RESOLUTION
                        obj.onEventGetMonitorResolution(client, value);
                    case NetEvents.GET_MONITOR_GAMMA_RAMP
                        obj.onEventGetMonitorGammaRamp(client, value);
                    case NetEvents.SET_MONITOR_GAMMA_RAMP
                        obj.onEventSetMonitorGammaRamp(client, value);
                    case NetEvents.PLAY_ASYNC
                        obj.onEventPlayAsync(client, value);
                    case NetEvents.GET_PLAY_INFO
                        obj.onEventGetPlayInfo(client, value);
                    case NetEvents.CLEAR_DATA
                        obj.onEventClearData(client, value);
                    otherwise
                        error('Stage:UnknownEvent', 'Unknown event');
                end
            catch x
                client.send(NetEvents.ERROR, x);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function onEventGetCanvasSize(obj, client, value) %#ok<INUSD>
            size = obj.canvas.size;
            client.send(stage.core.network.NetEvents.OK, size);
        end

        function onEventSetCanvasClearColor(obj, client, value)
            color = value{2};

            obj.canvas.setClearColor(color);
            client.send(stage.core.network.NetEvents.OK);
        end

        function onEventGetMonitorRefreshRate(obj, client, value) %#ok<INUSD>
            rate = obj.canvas.window.monitor.refreshRate;
            client.send(stage.core.network.NetEvents.OK, rate);
        end

        function onEventGetMonitorResolution(obj, client, value) %#ok<INUSD>
            resolution = obj.canvas.window.monitor.resolution;
            client.send(stage.core.network.NetEvents.OK, resolution);
        end

        function onEventGetMonitorGammaRamp(obj, client, value) %#ok<INUSD>
            [red, green, blue] = obj.canvas.window.monitor.getGammaRamp();
            client.send(stage.core.network.NetEvents.OK, red, green, blue);
        end

        function onEventSetMonitorGammaRamp(obj, client, value)
            red = value{2};
            green = value{3};
            blue = value{4};

            obj.canvas.window.monitor.setGammaRamp(red, green, blue);
            client.send(stage.core.network.NetEvents.OK);
        end

        function onEventPlayAsync(obj, client, value)
            presentation = value{2};
            
            % Unlock client to allow async operations during play.
            client.send(stage.core.network.NetEvents.OK);

            try
                obj.data.playInfo = presentation.play(obj.canvas);
            catch x
                obj.data.playInfo = x;
            end
        end

        function onEventGetPlayInfo(obj, client, value) %#ok<INUSD>
            info = obj.data.playInfo;
            client.send(stage.core.network.NetEvents.OK, info);
        end

        function onEventClearData(obj, client, value) %#ok<INUSD>
            obj.data = [];

            % Clear class definitions.
            memory = inmem;
            for i = 1:length(memory)
                if exist(memory{i}, 'class')
                    clear(memory{i});
                end
            end
            
            client.send(stage.core.network.NetEvents.OK);
        end
        
    end
    
end

