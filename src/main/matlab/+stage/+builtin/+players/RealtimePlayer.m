classdef RealtimePlayer < stage.core.Player
    % A player that draws each frame during the inter-frame interval.
    
    methods

        function obj = RealtimePlayer(presentation)
            obj = obj@stage.core.Player(presentation);
        end

        function info = play(obj, canvas)
            frameRate = canvas.window.monitor.refreshRate;
            flipTimer = stage.core.FlipTimer();

            obj.compositor.init(canvas);
            
            canvas.setClearColor(obj.presentation.backgroundColor);

            stimuli = obj.presentation.stimuli;
            controllers = obj.presentation.controllers;

            for i = 1:length(stimuli)
                stimuli{i}.init(canvas);

                % HACK: This appears to preload stimulus array data onto the graphics card, making subsequent calls to
                % draw() faster.
                v = stimuli{i}.visible;
                stimuli{i}.visible = true;
                stimuli{i}.draw();
                stimuli{i}.visible = v;
            end

            try %#ok<TRYNC>
                setMaxPriority();
            end
            cleanup = onCleanup(@resetPriority);
            function resetPriority()
                try %#ok<TRYNC>
                    setNormalPriority();
                end
            end

            frame = 0;
            time = frame / frameRate;
            while time < obj.presentation.duration
                canvas.clear();
                
                state.canvas = canvas;
                state.frame = frame;
                state.frameRate = frameRate;
                state.time = time;
                obj.compositor.drawFrame(stimuli, controllers, state);

                canvas.window.flip();
                flipTimer.tick();

                canvas.window.pollEvents();

                frame = frame + 1;
                time = frame / frameRate;
            end

            info.flipDurations = flipTimer.flipDurations;
        end

    end

end
