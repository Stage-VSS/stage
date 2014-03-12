% The core object for presenting stimuli.

classdef Presentation < handle
    
    properties
        duration    % Play duration (seconds)
    end
    
    properties (SetAccess = private)
        stimuli
        controllers
    end
    
    methods
        
        % Constructs a presentation with the given duration in seconds.
        function obj = Presentation(duration)
            obj.duration = duration;
        end
        
        % Adds a stimulus to the presentation. By default stimuli are layered in the order with which they are added; 
        % the first stimulus added is on the lowest layer (the layer farthest from the viewer) while the last stimulus 
        % added is on the highest layer (the layer closest to the viewer). The presentation's compositor ultimately 
        % determines this behavior and may be specified by the user.
        function addStimulus(obj, stimulus)
            if ~isempty(obj.stimuli) && any(cellfun(@(c)c == stimulus, obj.stimuli))
                error('Presentation already contains the given stimulus');
            end
            
            obj.stimuli{end + 1} = stimulus;
        end
        
        % Adds a controller to the presentation. A controller associates an object's property with a given function. As 
        % each frame is presented, the given function will be called and passed a struct containing information about
        % the current state of the presentation (the current number of frames presented, the time elapsed since the 
        % start of the presentation, etc). The value returned by the function is assigned to the associated property.
        function addController(obj, handle, propertyName, funcHandle)
            if ~isprop(handle, propertyName)
                error(['The handle does not contain a property named ''' propertyName '''']);
            end
            
            if nargin(funcHandle) < 1
                error('The given function must have at least 1 input argument');
            end
            
            obj.controllers{end + 1} = {handle, propertyName, funcHandle};
        end
        
        % Plays the presentation for its set duration. If during playback the presentation fails to draw a new frame 
        % within the inter-frame interval, the prior frame will be presented for a longer period than expected and the
        % actual duration of the presentation will be extended.
        function info = play(obj, canvas)
            for i = 1:length(obj.stimuli)
                obj.stimuli{i}.init(canvas);
            end
            
            flipTimer = FlipTimer();
            refreshRate = canvas.window.monitor.refreshRate;
            
            frame = 0;
            frameDuration = 1 / refreshRate;
            time = frame * frameDuration;
            while time <= obj.duration
                canvas.clear();
                
                obj.drawFrame(frame, frameDuration, time);
                
                canvas.window.flip();
                flipTimer.tick();
                
                frame = frame + 1;
                time = frame * frameDuration;
            end
            
            info.flipDurations = flipTimer.flipDurations;
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
            
            for i = 1:length(obj.stimuli)
                obj.stimuli{i}.init(canvas);
            end
            
            frame = 0;
            frameDuration = 1 / frameRate;
            time = frame * frameDuration;
            while time <= obj.duration
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
            
            % Call controllers.
            for i = 1:length(obj.controllers)
                c = obj.controllers{i};
                handle = c{1};
                prop = c{2};
                func = c{3};

                handle.(prop) = func(state);
            end
            
            % Draw stimuli.
            for i = 1:length(obj.stimuli)
                obj.stimuli{i}.draw();
            end
        end
        
    end
    
end