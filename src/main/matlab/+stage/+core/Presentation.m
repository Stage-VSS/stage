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

        % Adds a stimulus to this presentation. Stimuli are drawn in the order with which they are added.
        function addStimulus(obj, stimulus)
            if ~isempty(obj.stimuli) && any(cellfun(@(c)c == stimulus, obj.stimuli))
                error('Presentation already contains the given stimulus');
            end

            obj.stimuli{end + 1} = stimulus;
        end

        % Inserts a stimulus into a given index position in the stimuli list.
        function insertStimulus(obj, index, stimulus)
            if ~isempty(obj.stimuli) && any(cellfun(@(c)c == stimulus, obj.stimuli))
                error('Presentation already contains the given stimulus');
            end

            obj.stimuli = [obj.stimuli(1:index-1) {stimulus} obj.stimuli(index:end)];
        end

        % Adds a controller to this presentation.
        function addController(obj, controller)
            if ~isempty(obj.controllers) && any(cellfun(@(c)c == controller, obj.controllers))
                error('Presentation already contains the given controller');
            end

            obj.controllers{end + 1} = controller;
        end

        % A convenience method to play this presentation.
        function info = play(obj, canvas)
            player = stage.builtin.players.RealtimePlayer(obj);
            info = player.play(canvas);
        end

    end

end
