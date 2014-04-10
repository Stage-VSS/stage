% Abstract class for all presentation players.

classdef Player < handle
    
    properties (SetAccess = private)
        presentation
        compositor
    end
    
    methods
        
        function obj = Player(presentation)
            obj.presentation = presentation;
            obj.setCompositor(Compositor());
        end
        
        function setCompositor(obj, compositor)
            obj.compositor = compositor;
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
            
            obj.compositor.setCanvas(canvas);
            
            stimuli = obj.presentation.stimuli;
            controllers = obj.presentation.controllers;
            
            for i = 1:length(stimuli)
                stimuli{i}.init(canvas);
            end
            
            frame = 0;
            frameDuration = 1 / frameRate;
            time = frame * frameDuration;
            while time <= obj.presentation.duration
                canvas.clear();
                
                obj.compositor.drawFrame(stimuli, controllers, frame, frameDuration, time);
                
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
    
    methods (Abstract)
        info = play(obj, canvas);
    end
    
end