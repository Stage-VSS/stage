% Abstract class for all presentation players.

classdef Player < handle
    
    properties (SetAccess = private)
        presentation
        compositor
    end
    
    methods
        
        % Constructs a player with a given presentation.
        function obj = Player(presentation)
            obj.presentation = presentation;
            obj.setCompositor(Compositor());
        end
        
        % Sets the compositor used to composite the presentation stimuli into frame images during playback.
        function setCompositor(obj, compositor)
            obj.compositor = compositor;
        end
        
        % Exports the presentation to a movie file. The VideoWriter frame rate and profile may optionally be provided. 
        % If the given profile specifies only one color channel, the red, green, and blue color channels of the 
        % presentation are averaged to produce the output video data.
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
        % Plays the presentation for its set duration.
        info = play(obj, canvas);
    end
    
end