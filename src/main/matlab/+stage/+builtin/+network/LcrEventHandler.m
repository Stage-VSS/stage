classdef LcrEventHandler < stage.builtin.network.BasicEventHandler
    
    methods
        
        function obj = LcrEventHandler(canvas)
            obj@stage.builtin.network.BasicEventHandler(canvas);
        end
        
    end
    
    methods (Access = protected)
        
        function onEvent(obj, connection, event)
            switch event.name
                case 'getLcrPatternAttributes'
                    obj.onEventGetLcrPatternAttributes(client, value);
                case 'setLcrPatternAttributes'
                    obj.onEventSetLcrPatternAttributes(client, value);
                case 'getLcrLedCurrents'
                    obj.onEventGetLcrLedCurrents(client, value);
                case 'setLcrLedCurrents'
                    obj.onEventSetLcrLedCurrents(client, value);
                case 'getLcrLedEnables'
                    obj.onEventGetLcrLedEnables(client, value);
                case 'setLcrLedEnables'
                    obj.onEventSetLcrLedEnables(client, value);
                case 'getLcrCurrentPatternRate'
                    obj.onEventGetLcrCurrentPatternRate(client, value);
                otherwise
                    onEvent@stage.builtin.network.BasicEventHandler(obj, connection, event);                
            end 
        end
        
        
    end
    
end

