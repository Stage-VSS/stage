classdef Viewer < handle

    properties (Access = private)
        canvas
        presentation
        compositor
        frameRate
        frame
    end

    properties (Access = private, Dependent)
        timestamp
    end

    methods

        function obj = Viewer(canvas, presentation, compositor, frameRate)
            if nargin < 3
                compositor = stage.core.Compositor();
            end

            if nargin < 4
                frameRate = canvas.window.monitor.refreshRate;
            end

            obj.canvas = canvas;
            obj.presentation = presentation;
            obj.compositor = compositor;
            obj.frameRate = frameRate;
            obj.frame = 0;

            obj.init();
        end

        function init(obj)
            obj.compositor.init(obj.canvas);

            stimuli = obj.presentation.stimuli;
            for i = 1:length(stimuli)
                stimuli{i}.init(obj.canvas);
            end
        end

        function seek(obj, time)
            obj.frame = ceil(time * obj.frameRate);
        end

        function data = getImage(obj, time)
            obj.seek(time);
            data = obj.nextImage();
        end

        function data = nextImage(obj)
            if obj.timestamp >= obj.presentation.duration
                data = [];
                return;
            end

            obj.canvas.setClearColor(obj.presentation.backgroundColor);
            obj.canvas.clear();

            state.frame = obj.frame;
            state.frameRate = obj.frameRate;
            state.time = obj.timestamp;
            obj.compositor.drawFrame(obj.presentation.stimuli, obj.presentation.controllers, state);
            data = im2frame(obj.canvas.getPixelData());

            obj.frame = obj.frame + 1;
        end

        function t = get.timestamp(obj)
            t = obj.frame / obj.frameRate;
        end

    end

end
