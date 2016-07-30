classdef FrameTimingFigure < symphonyui.core.FigureHandler

    properties (SetAccess = private)
        device
    end

    properties (Access = private)
        axesHandle
        sweep
    end

    methods

        function obj = FrameTimingFigure(device)
            obj.device = device;

            obj.createUi();
        end

        function createUi(obj)
            obj.axesHandle = axes( ...
                'Parent', obj.figureHandle, ...
                'XTickMode', 'auto');
            xlabel(obj.axesHandle, 'flip');
            ylabel(obj.axesHandle, 'sec');

            obj.setTitle([obj.device.name ' Frame Timing']);
        end

        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
            title(obj.axesHandle, t);
        end

        function handleEpoch(obj, epoch) %#ok<INUSD>
            info = obj.device.getPlayInfo();
            if isa(info, 'MException')
                error(['Stage encountered an error during the presentation: ' info.message]);
            end
            durations = info.flipDurations;
            if numel(durations) > 0
                x = 1:numel(durations);
                y = durations;
            else
                x = [];
                y = [];
            end
            if isempty(obj.sweep)
                obj.sweep = line(x, y, 'Parent', obj.axesHandle);
            else
                set(obj.sweep, 'XData', x, 'YData', y);
            end
        end

    end

end
