classdef StagePreview < symphonyui.core.ProtocolPreview
    
    properties (SetAccess = private)
        createPresentationFcn
        windowSize
    end
    
    properties (Access = private)
        log
        canvas
        axes
    end
    
    methods
        
        function obj = StagePreview(panel, createPresentationFcn, varargin)
            obj@symphonyui.core.ProtocolPreview(panel);
            
            ip = inputParser();
            ip.addParameter('windowSize', [640, 480], @(x)isvector(x));
            ip.parse(varargin{:});
            
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.createPresentationFcn = createPresentationFcn;
            obj.windowSize = ip.Results.windowSize;
            
            obj.createUi();
        end
        
        function createUi(obj)
            window = stage.core.Window(obj.windowSize, false, stage.core.Monitor(1), 'Visible', GL.FALSE);
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
                    'HorizontalAlignment', 'center', ...
                    'Units', 'normalized');
                obj.log.debug(x.message, x);
                return;
            end
            
            viewer = stage.core.Viewer(obj.canvas, presentation);
            
            data = viewer.getImage(presentation.duration/2);
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
            
            img = imshow(data(1).cdata, 'Parent', obj.axes);
            set(img, 'ButtonDownFcn', @(h,d)obj.onSelectedPlay(viewer, d));
        end
        
        function onSelectedPlay(obj, viewer, ~)
            viewer.seek(0);
            img = viewer.nextImage();
            front = imshow(img.cdata, 'Parent', obj.axes);
            while ~isempty(img)
                back = front;
                front = image( ...
                    'Parent', obj.axes, ...
                    'CData', img.cdata);
                delete(back);
                drawnow('expose');
                img = viewer.nextImage();
            end
            set(front, 'ButtonDownFcn', @(h,d)obj.onSelectedPlay(viewer, d));
        end
        
    end
    
end

