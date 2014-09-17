% A player that draws each frame during the inter-frame interval.

classdef RealtimePlayer < Player
    
    methods
        
        function obj = RealtimePlayer(presentation)
            obj = obj@Player(presentation);
        end
        
        function info = play(obj, canvas)
            flipTimer = FlipTimer();
            
            obj.compositor.init(canvas);
            
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
            
            frame = 0;
            frameDuration = 1 / canvas.window.monitor.refreshRate;
            time = frame * frameDuration;
            while time < obj.presentation.duration
                canvas.clear();
                
                obj.compositor.drawFrame(stimuli, controllers, frame, frameDuration, time);
                
                canvas.window.flip();
                flipTimer.tick();
                
                canvas.window.pollEvents();
                
                frame = frame + 1;
                time = frame * frameDuration;
            end
            
            try %#ok<TRYNC>
                setNormalPriority();
            end
            
            info.flipDurations = flipTimer.flipDurations;
        end
        
    end
    
end