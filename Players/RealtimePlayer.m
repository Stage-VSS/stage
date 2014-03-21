% A player that draws each frame during the inter-frame interval.

classdef RealtimePlayer < Player
    
    methods
        
        function obj = RealtimePlayer(presentation)
            obj = obj@Player(presentation);
        end
        
        function info = play(obj, canvas)
            flipTimer = FlipTimer();
            
            for i = 1:length(obj.presentation.stimuli)
                obj.presentation.stimuli{i}.init(canvas);
            end
            
            try %#ok<TRYNC>
                setMaxPriority();
            end
            
            frame = 0;
            frameDuration = 1 / canvas.window.monitor.refreshRate;
            time = frame * frameDuration;
            while time <= obj.presentation.duration
                canvas.clear();
                
                obj.drawFrame(canvas, frame, frameDuration, time);
                
                canvas.window.flip();
                flipTimer.tick();
                
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