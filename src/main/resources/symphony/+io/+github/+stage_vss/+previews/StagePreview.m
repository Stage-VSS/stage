classdef StagePreview < symphonyui.core.ProtocolPreview
    
    properties
        createPresentationFcn
    end
    
    properties (Access = private)
        log
        canvas
        axes
    end
    
    methods
        
        function obj = StagePreview(panel, createPresentationFcn)
            obj@symphonyui.core.ProtocolPreview(panel);
            obj.createPresentationFcn = createPresentationFcn;
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.createUi();
        end
        
        function createUi(obj)
            window = stage.core.Window([640, 480], false, stage.core.Monitor(1), 'Visible', GL.FALSE);
            obj.canvas = stage.core.Canvas(window, 'DisableDwm', false);
            obj.axes = axes( ...
                'Parent', obj.panel, ...
                'Position', [0 0 1 1], ...
                'XColor', 'none', ...
                'YColor', 'none', ...
                'Color', 'none'); %#ok<CPROP>
            obj.update();
        end
        
        function update(obj)            
            try
                presentation = obj.createPresentationFcn();
            catch x
                cla(obj.axes);
                text(0.5, 0.5, 'Cannot create presentation', ...
                    'Parent', obj.axes, ...
                    'FontName', get(obj.panel, 'DefaultUicontrolFontName'), ...
                    'FontSize', get(obj.panel, 'DefaultUicontrolFontSize'), ...
                    'HorizontalAlignment', 'center');
                obj.log.debug(x.message, x);
                return;
            end
            
            player = stage.builtin.players.RealtimePlayer(presentation);
            
            data = player.getMovie(obj.canvas, presentation.duration/2);
            if isempty(data)
                cla(obj.axes);
                text(0.5, 0.5, 'Presentation has no frames', ...
                    'Parent', obj.axes, ...
                    'FontName', get(obj.panel, 'DefaultUicontrolFontName'), ...
                    'FontSize', get(obj.panel, 'DefaultUicontrolFontSize'), ...
                    'HorizontalAlignment', 'center', ...
                    'Units', 'normalized');
                return;
            end
            
            imshow(data(1).cdata, 'Parent', obj.axes);
            set(obj.axes, ...
                'Position', [0 0 1 1], ...
                'XColor', 'none', ...
                'YColor', 'none', ...
                'Color', 'none');
        end
        
    end
    
end

