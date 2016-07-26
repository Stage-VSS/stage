classdef Presentation < handle
    % A presentation represents a collection of visual stimuli to present over a set duration. It generally describes a
    % single experimental trial in Stage.
    
    properties
        duration    % Play duration (seconds)
    end

    properties (SetAccess = private)
        backgroundColor
        stimuli
        controllers
    end

    methods
        
        function obj = Presentation(duration)
            % Constructs a presentation with a given duration in seconds.
            obj.duration = duration;
            obj.backgroundColor = 0;
        end
        
        function setBackgroundColor(obj, color)
            % Sets the background color to use during the presentation as single intensity value or [R, G, B].
            obj.backgroundColor = color;
        end
        
        function addStimulus(obj, stimulus)
            % Adds a stimulus to this presentation. Stimuli are drawn in the order with which they are added.
            if ~isempty(obj.stimuli) && any(cellfun(@(c)c == stimulus, obj.stimuli))
                error('Presentation already contains the given stimulus');
            end

            obj.stimuli{end + 1} = stimulus;
        end
        
        function insertStimulus(obj, index, stimulus)
            % Inserts a stimulus into a given index position in the stimuli list.
            if ~isempty(obj.stimuli) && any(cellfun(@(c)c == stimulus, obj.stimuli))
                error('Presentation already contains the given stimulus');
            end

            obj.stimuli = [obj.stimuli(1:index-1) {stimulus} obj.stimuli(index:end)];
        end
        
        function addController(obj, controller)
            % Adds a controller to this presentation.
            if ~isempty(obj.controllers) && any(cellfun(@(c)c == controller, obj.controllers))
                error('Presentation already contains the given controller');
            end

            obj.controllers{end + 1} = controller;
        end
        
        function info = play(obj, canvas)
            % A convenience method to play this presentation.
            player = stage.builtin.players.RealtimePlayer(obj);
            info = player.play(canvas);
        end

    end

end
