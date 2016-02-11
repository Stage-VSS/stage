classdef (Abstract) EventHandler < handle
    
    properties (SetAccess = private)
        canvas
    end
    
    methods
        
        function obj = EventHandler(canvas)
            obj.canvas = canvas;
        end
        
        function handleEvent(obj, connection, event)
            try
                obj.onEvent(connection, event);
            catch x
                connection.sendEvent(netbox.Event('error', x));
            end
        end
        
    end
    
    methods (Abstract, Access = protected)
        onEvent(obj, connection, event);
    end
    
end

