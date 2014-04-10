% A presentation represents a collection of visual stimuli to present over a set duration. It generally describes a 
% single experimental trial in Stage.

classdef Presentation < handle
    
    properties
        duration    % Play duration (seconds)
    end
    
    properties (SetAccess = private)
        stimuli
        controllers
    end
    
    methods
        
        % Constructs a presentation with a given duration in seconds.
        function obj = Presentation(duration)
            obj.duration = duration;
        end
        
        % Adds a stimulus to this presentation. Stimuli are layered in the order with which they are added; the first 
        % stimulus added is considered on the lowest layer (the layer farthest from the viewer) while the last stimulus 
        % added is considered on the highest layer (the layer closest to the viewer).
        function addStimulus(obj, stimulus)
            if ~isempty(obj.stimuli) && any(cellfun(@(c)c == stimulus, obj.stimuli))
                error('Presentation already contains the given stimulus');
            end
            
            obj.stimuli{end + 1} = stimulus;
        end
        
        % Adds a controller to this presentation. A controller associates an object's property with a given function. 
        % While the presentation plays the controller function is called and passed a struct containing information 
        % about the current state of playback (the current number of frames presented, the time elapsed since the start 
        % of the presentation, etc). The value returned by the function is assigned to the associated property.
        function addController(obj, handle, propertyName, funcHandle)
            if ~isprop(handle, propertyName)
                error(['The handle does not contain a property named ''' propertyName '''']);
            end
            
            if nargin(funcHandle) < 1
                error('The given function must have at least 1 input argument');
            end
            
            obj.controllers{end + 1} = {handle, propertyName, funcHandle};
        end
        
        % A convenience method to play this presentation with a RealtimePlayer.
        function info = play(obj, canvas)
            player = RealtimePlayer(obj);
            info = player.play(canvas);
        end
        
        % A convenience method to export this presentation to a movie file.
        function exportMovie(obj, canvas, filename, frameRate, profile)
            if nargin < 4
                frameRate = canvas.window.monitor.refreshRate;
            end
            
            if nargin < 5
                profile = 'Uncompressed AVI';
            end
            
            player = RealtimePlayer(obj);
            player.exportMovie(canvas, filename, frameRate, profile);
        end
        
    end
    
end