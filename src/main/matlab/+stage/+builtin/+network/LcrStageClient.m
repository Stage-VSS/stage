classdef LcrStageClient < stage.builtin.network.StageClient
    
    methods
        
        % Gets the remote LightCrafter bit depth, color, and number of patterns.
        function [bitDepth, color, numPatterns] = getLcrPatternAttributes(obj)
            e = netbox.NetEvent('getLcrPatternAttributes');
            [bitDepth, color, numPatterns] = obj.sendReceive(e);
        end
        
        % Sets the remote LightCrafter bit depth, color, and optionally number of patterns. If the number of patterns is
        % not specified the maximum number of patterns for the given bit depth will be used (i.e. the highest pattern
        % rate).
        function setLcrPatternAttributes(obj, bitDepth, color, numPatterns)
            if nargin < 4
                numPatterns = [];
            end
            e = netbox.NetEvent('setLcrPatternAttributes', {bitDepth, color, numPatterns});
            obj.sendReceive(e);
        end
        
        % Gets the remote LightCrafter LED currents.
        function [red, green, blue] = getLcrLedCurrents(obj)
            e = netbox.NetEvent('getLcrLedCurrents');
            [red, green, blue] = obj.sendReceive(e);
        end
        
        % Sets the remote LightCrafter LED currents.
        function setLcrLedCurrents(obj, red, green, blue)
            e = netbox.NetEvent('setLcrLedCurrents', {red, green, blue});
            obj.sendReceive(e);
        end
        
        % Gets the remote LightCrafter LED enables state.
        function [auto, red, green, blue] = getLcrLedEnables(obj)
            e = netbox.NetEvent('getLcrLedEnables');
            [auto, red, green, blue] = obj.sendReceive(e);
        end
        
        % Sets the remote LightCrafter LEDs to enabled/disabled.
        function setLcrLedEnables(obj, auto, red, green, blue)
            e = netbox.NetEvent('setLcrLedEnables', {auto, red, green, blue});
            obj.sendReceive(e);
        end
        
        % Gets the current LightCrafter pattern rate.
        function r = getLcrCurrentPatternRate(obj)
            e = netbox.NetEvent('getLcrCurrentPatternRate');
            r = obj.sendReceive(e);
        end
        
    end
    
end

