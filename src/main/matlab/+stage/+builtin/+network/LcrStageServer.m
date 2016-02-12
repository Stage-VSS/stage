classdef LcrStageServer < stage.builtin.network.StageServer

    properties (Access = private)
        lightCrafter
    end
    
    methods
        
        function obj = LcrStageServer(port)
            if nargin < 1
                port = 5678;
            end
            obj@stage.builtin.network.StageServer(port)
        end
        
    end

    methods (Access = protected)

        function willStart(obj)
            import stage.builtin.extras.Lcr4500;
            
            willStart@stage.builtin.network.StageServer(obj);

            monitor = obj.canvas.window.monitor;
            monitor.setGamma(1);

            obj.lightCrafter = Lcr4500(monitor);
            obj.lightCrafter.connect();

            % Set LEDs to enable automatically.
            obj.lightCrafter.setLedEnables(true, true, true, true);

            obj.lightCrafter.setMode('pattern');
            obj.lightCrafter.setPatternAttributes(Lcr4500.MAX_PATTERN_BIT_DEPTH, 'white', 1);

            if monitor.resolution == Lcr4500.NATIVE_RESOLUTION
                % Stretch the projection matrix to account for the LightCrafter diamond pixel screen.
                window = obj.canvas.window;
                obj.canvas.projection.setIdentity();
                obj.canvas.projection.orthographic(0, window.size(1)*2, 0, window.size(2));
            end
        end

        function didStop(obj)
            didStop@stage.builtin.network.StageServer(obj);

            obj.lightCrafter.disconnect();
        end

        function onEventGetLcrPatternAttributes(obj, connection, event) %#ok<INUSD>
            [bitDepth, color, numPatterns] = obj.lightCrafter.getPatternAttributes();
            connection.sendEvent(netbox.NetEvent('ok', {bitDepth, color, numPatterns}));
        end

        function onEventSetLcrPatternAttributes(obj, connection, event)
            bitDepth = event.arguments{1};
            color = event.arguments{2};
            numPatterns = event.arguments{3};

            if isempty(numPatterns)
                numPatterns = obj.lightCrafter.maxNumPatternsForBitDepth(bitDepth);
            end

            [cBitDepth, cColor, cNumPatterns] = obj.lightCrafter.getPatternAttributes();
            if bitDepth == cBitDepth && strncmpi(color, cColor, length(color)) && numPatterns == cNumPatterns
                connection.sendEvent(netbox.NetEvent('ok'));
                return;
            end

            if bitDepth ~= cBitDepth || numPatterns ~= cNumPatterns
                connection.removeData('player');
            end

            obj.lightCrafter.setPatternAttributes(bitDepth, color, numPatterns);
            connection.sendEvent(netbox.NetEvent('ok'));
        end

        function onEventGetLcrLedCurrents(obj, connection, event) %#ok<INUSD>
            [red, green, blue] = obj.lightCrafter.getLedCurrents();
            connection.sendEvent(netbox.NetEvent('ok', {red, green, blue}));
        end

        function onEventSetLcrLedCurrents(obj, connection, event)
            red = event.arguments{1};
            green = event.arguments{2};
            blue = event.arguments{3};

            obj.lightCrafter.setLedCurrents(red, green, blue);
            connection.sendEvent(netbox.NetEvent('ok'));
        end

        function onEventGetLcrLedEnables(obj, connection, event) %#ok<INUSD>
            [auto, red, green, blue] = obj.lightCrafter.getLedEnables();
            connection.sendEvent(netbox.NetEvent('ok', {auto, red, green, blue}));
        end

        function onEventSetLcrLedEnables(obj, connection, event)
            auto = event.arguments{1};
            red = event.arguments{2};
            green = event.arguments{3};
            blue = event.arguments{4};

            obj.lightCrafter.setLedEnables(auto, red, green, blue);
            connection.sendEvent(netbox.NetEvent('ok'));
        end

        function onEventGetLcrCurrentPatternRate(obj, connection, event) %#ok<INUSD>
            rate = obj.lightCrafter.currentPatternRate();
            connection.sendEvent(netbox.NetEvent('ok'), rate);
        end

        function onEventGetCanvasSize(obj, connection, event) %#ok<INUSD>
            size = obj.canvas.size;
            if obj.canvas.window.monitor.resolution == stage.builtin.extras.Lcr4500.NATIVE_RESOLUTION
                % Stretch for diamond pixel layout.
                size(1) = size(1) * 2;
            end

            connection.sendEvent(netbox.NetEvent('ok', size));
        end

        function onEventPlay(obj, connection, event)
            presentation = event.arguments{1};
            prerender = event.arguments{2};

            % Replace presentation background color with a background rectangle.
            background = stage.builtin.stimuli.Rectangle();
            background.color = presentation.backgroundColor;
            background.position = obj.canvas.size/2;
            background.size = obj.canvas.size;
            if obj.canvas.window.monitor.resolution == stage.builtin.extras.Lcr4500.NATIVE_RESOLUTION
                background.position(1) = background.position(1)*2;
                background.size(1) = background.size(1)*2;
            end

            presentation.insertStimulus(1, background);
            presentation.setBackgroundColor(0);

            if prerender
                player = stage.builtin.players.PrerenderedPlayer(presentation);
            else
                player = stage.builtin.players.RealtimePlayer(presentation);
            end

            [bitDepth, ~, nPatterns] = obj.lightCrafter.getPatternAttributes();
            renderer = stage.builtin.renderers.LcrPatternRenderer(nPatterns, bitDepth);

            obj.canvas.setRenderer(renderer);
            resetRenderer = onCleanup(@()obj.canvas.resetRenderer());

            compositor = stage.builtin.compositors.LcrPatternCompositor();
            compositor.bindPatternRenderer(renderer);

            player.setCompositor(compositor);
            connection.setData('player', player);

            % Unlock client to allow async operations during play.
            connection.sendEvent(netbox.NetEvent('ok'));

            try
                info = player.play(obj.canvas);
            catch x
                info = x;
            end
            connection.setData('playInfo', info);
        end

    end

end
