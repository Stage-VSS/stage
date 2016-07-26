classdef Player < handle
    % Abstract class for all presentation players.
    
    properties (SetAccess = private)
        presentation
        compositor
    end

    methods
        
        function obj = Player(presentation)
            % Constructs a player with a given presentation.
            obj.presentation = presentation;
            obj.setCompositor(stage.core.Compositor());
        end
        
        function setCompositor(obj, compositor)
            % Sets the compositor used to composite the presentation stimuli into frame images during playback.
            obj.compositor = compositor;
        end
        
        function exportMovie(obj, canvas, filename, frameRate, profile)
            % Exports the presentation to a movie file. The VideoWriter frame rate and profile may optionally be 
            % provided. If the given profile specifies only one color channel, the red, green, and blue color channels 
            % of the presentation are averaged to produce the output video data.
            
            if nargin < 4
                frameRate = canvas.window.monitor.refreshRate;
            end

            if nargin < 5
                profile = 'Uncompressed AVI';
            end

            writer = VideoWriter(filename, profile);
            writer.FrameRate = frameRate;
            writer.open();

            obj.compositor.init(canvas);

            canvas.setClearColor(obj.presentation.backgroundColor);
            
            stimuli = obj.presentation.stimuli;
            controllers = obj.presentation.controllers;

            for i = 1:length(stimuli)
                stimuli{i}.init(canvas);
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

                pixelData = canvas.getPixelData();
                if writer.ColorChannels == 1
                    pixelData = uint8(mean(pixelData, 3));
                end

                writer.writeVideo(pixelData);
                
                canvas.window.pollEvents();

                frame = frame + 1;
                time = frame / frameRate;
            end

            writer.close();
        end
        
    end

    methods (Abstract)
        % Plays the presentation for its set duration.
        info = play(obj, canvas);
    end

end
