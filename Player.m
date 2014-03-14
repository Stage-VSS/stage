% Abstract class for all presentation players.

classdef Player < handle
    
    properties (SetAccess = private)
        presentation
    end
    
    methods
        
        function obj = Player(presentation)
            obj.presentation = presentation;
        end
        
        function exportMovie(obj, canvas, filename, frameRate, profile)
            if nargin < 4
                frameRate = canvas.window.monitor.refreshRate;
            end
            
            if nargin < 5
                profile = 'Uncompressed AVI';
            end
            
            writer = VideoWriter(filename, profile);
            writer.FrameRate = frameRate;
            writer.open();
            
            frame = 0;
            frameDuration = 1 / frameRate;
            time = frame * frameDuration;
            while time <= obj.presentation.duration
                canvas.clear();
                
                obj.drawFrame(frame, frameDuration, time);
                
                pixelData = canvas.getPixelData();
                if writer.ColorChannels == 1
                    pixelData = uint8(mean(pixelData, 3));
                end
                
                writer.writeVideo(pixelData);
                
                frame = frame + 1;
                time = frame * frameDuration;
            end
            
            writer.close();
        end
        
    end
    
    methods (Access = protected)
        
        function drawFrame(obj, frame, frameDuration, time)
            state.frame = frame;
            state.frameDuration = frameDuration;
            state.time = time;
            
            obj.callControllers(state);
            
            obj.drawStimuli();
        end
        
        function callControllers(obj, state)
            for i = 1:length(obj.presentation.controllers)
                c = obj.presentation.controllers{i};
                handle = c{1};
                prop = c{2};
                func = c{3};

                handle.(prop) = func(state);
            end
        end
        
        function drawStimuli(obj)
            for i = 1:length(obj.presentation.stimuli)
                obj.presentation.stimuli{i}.draw();
            end
        end
        
    end
    
    methods (Abstract)
        info = play(obj, canvas);
    end
    
end