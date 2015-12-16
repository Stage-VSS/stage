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
            obj.setCompositor(stage.core.Compositor());
        end

        % Sets the compositor used to composite the presentation stimuli into frame images during playback.
        function setCompositor(obj, compositor)
            obj.compositor = compositor;
        end

        % Exports the presentation to a movie file. startTime and endTime will be adjusted to align to the
        % nearest frame, rounded down. The VideoWriter frame rate and profile may optionally be provided.
        % If the given profile specifies only one color channel, the red, green, and blue color channels of the
        % presentation are averaged to produce the output video data.
        function exportMovie(obj, canvas, filename, startTime, endTime, frameRate, profile)
            if nargin < 4
                startTime = 0;
            end
            
            if nargin < 5
                endTime = obj.presentation.duration;
            end
            
            if nargin < 6
                frameRate = canvas.window.monitor.refreshRate;
            end

            if nargin < 7
                profile = 'Uncompressed AVI';
            end

            writer = VideoWriter(filename, profile);
            writer.FrameRate = frameRate;
            writer.open();

            obj.compositor.init(canvas);

            stimuli = obj.presentation.stimuli;
            controllers = obj.presentation.controllers;

            for i = 1:length(stimuli)
                stimuli{i}.init(canvas);
            end
            
            startFrame = floor(startTime * frameRate);
            
            frame = startFrame;
            time = frame / frameRate;
            while time < endTime
                canvas.clear();

                obj.compositor.drawFrame(stimuli, controllers, frame, time);

                pixelData = canvas.getPixelData();
                if writer.ColorChannels == 1
                    pixelData = uint8(mean(pixelData, 3));
                end

                writer.writeVideo(pixelData);

                frame = frame + 1;
                time = frame / frameRate;
            end

            writer.close();
        end

        % Returns the presentation as a matrix of movie frames. startTime and endTime will be adjusted to align to the
        % nearest frame, rounded down.
        function data = getMovie(obj, canvas, startTime, endTime, frameRate)
            if nargin < 3
                startTime = 0;
            end
            
            if nargin < 4
                endTime = obj.presentation.duration;
            end
            
            if nargin < 5
                frameRate = canvas.window.monitor.refreshRate;
            end
            
            obj.compositor.init(canvas);

            stimuli = obj.presentation.stimuli;
            controllers = obj.presentation.controllers;

            for i = 1:length(stimuli)
                stimuli{i}.init(canvas);
            end
            
            startFrame = floor(startTime * frameRate);
            endFrame = ceil(endTime * frameRate);
            if endFrame - startFrame > 0
                data(endFrame - startFrame) = struct('cdata', [], 'colormap', []);
            else
                data = [];
            end
            
            frame = startFrame;
            time = frame / frameRate;
            while time < endTime
                canvas.clear();

                obj.compositor.drawFrame(stimuli, controllers, frame, time);

                data(frame - startFrame + 1) = im2frame(canvas.getPixelData());

                frame = frame + 1;
                time = frame / frameRate;
            end
        end
        
    end

    methods (Abstract)
        % Plays the presentation for its set duration.
        info = play(obj, canvas);
    end

end
