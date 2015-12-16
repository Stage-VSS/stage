% A compositor is responsible for compositing a collection of stimuli into a single image.

classdef Compositor < handle

    properties (SetAccess = private)
        canvas
    end

    methods

        function init(obj, canvas)
            obj.canvas = canvas;
        end

        % Composites a single frame from a collection of stimuli.
        function drawFrame(obj, stimuli, controllers, frame, time)
            state.canvas = obj.canvas;
            state.frame = frame;
            state.time = time;

            obj.evaluateControllers(controllers, state);

            obj.drawStimuli(stimuli);
        end

    end

    methods (Access = protected)

        function evaluateControllers(obj, controllers, state) %#ok<INUSL>
            for i = 1:length(controllers)
                controllers{i}.evaluate(state);
            end
        end

        function drawStimuli(obj, stimuli) %#ok<INUSL>
            for i = 1:length(stimuli)
                stimuli{i}.draw();
            end
        end

    end

end
