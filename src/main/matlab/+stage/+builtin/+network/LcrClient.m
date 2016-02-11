classdef LcrClient < stage.builtin.network.BasicClient
    
    methods
        
        function obj = LcrClient(client)
            obj@stage.builtin.network.BasicClient(client);
        end
        
        % Gets the remote LightCrafter bit depth, color, and number of patterns.
        function [bitDepth, color, numPatterns] = getLcrPatternAttributes(obj)
            e = netbox.Event('getLcrPatternAttributes');
            [bitDepth, color, numPatterns] = obj.client.sendReceiveEvent(e);
        end
        
        % Sets the remote LightCrafter bit depth, color, and optionally number of patterns. If the number of patterns is
        % not specified the maximum number of patterns for the given bit depth will be used (i.e. the highest pattern
        % rate).
        function setLcrPatternAttributes(obj, bitDepth, color, numPatterns)
            if nargin < 4
                numPatterns = [];
            end
            e = netbox.Event('setLcrPatternAttributes', {bitDepth, color, numPatterns});
            obj.client.sendReceiveEvent(e);
        end
        
        % Gets the remote LightCrafter LED currents.
        function [red, green, blue] = getLcrLedCurrents(obj)
            e = netbox.Event('getLcrLedCurrents');
            [red, green, blue] = obj.client.sendReceiveEvent(e);
        end
        
        % Sets the remote LightCrafter LED currents.
        function setLcrLedCurrents(obj, red, green, blue)
            e = netbox.Event('setLcrLedCurrents', {red, green, blue});
            obj.client.sendReceiveEvent(e);
        end
        
        % Gets the remote LightCrafter LED enables state.
        function [auto, red, green, blue] = getLcrLedEnables(obj)
            e = netbox.Event('getLcrLedEnables');
            [auto, red, green, blue] = obj.client.sendReceiveEvent(e);
        end
        
        % Sets the remote LightCrafter LEDs to enabled/disabled.
        function setLcrLedEnables(obj, auto, red, green, blue)
            e = netbox.Event('setLcrLedEnables', {auto, red, green, blue});
            obj.client.sendReceiveEvent(e);
        end
        
        % Gets the current LightCrafter pattern rate.
        function r = getLcrCurrentPatternRate(obj)
            e = netbox.Event('getLcrCurrentPatternRate');
            r = obj.client.sendReceiveEvent(e);
        end
        
    end
    
end

