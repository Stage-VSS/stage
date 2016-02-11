classdef BasicEventHandler < stage.core.network.EventHandler
    
    methods
        
        function obj = BasicEventHandler(canvas)
            obj@stage.core.network.EventHandler(canvas);
        end
        
    end
    
    methods (Access = protected)
        
        function onEvent(obj, connection, event)
            switch event.name
                case 'play'
                    obj.onEventPlay(connection, event);
                case 'getPlayInfo'
                    obj.onEventGetPlayInfo(connection, event);
                case 'clearMemory'
                    obj.onEventClearMemory(connection, event);
            end
        end
        
        function onEventPlay(obj, connection, event)
            presentation = event.arguments{1};
            
            connection.sendEvent(netbox.Event('ok'));
            
            try
                info = presentation.play(obj.canvas);
            catch x
                info = x;
            end
            connection.setData('playInfo', info);
        end
        
        function onEventGetPlayInfo(obj, connection, event) %#ok<INUSL,INUSD>
            info = connection.getData('playInfo');
            connection.sendEvent(netbox.Event('ok', info));
        end
        
        function onEventClearMemory(obj, connection, event) %#ok<INUSL,INUSD>
            connection.clearData();
            
            memory = inmem('-completenames');
            for i = 1:length(memory)
                [package, name] = appbox.packageName(memory{i});
                if ~isempty(package)
                    package = [package '.']; %#ok<AGROW>
                end
                if exist([package name], 'class')
                    clear(name);
                end
            end
            
            connection.sendEvent(netbox.Event('ok'));
        end
        
    end
    
end

