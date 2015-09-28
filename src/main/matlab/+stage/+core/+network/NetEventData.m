classdef NetEventData < event.EventData
    
    properties (SetAccess = private)
        client
        value
    end
    
    methods
        
        function obj = NetEventData(client, value)
            if nargin < 2
                value = [];
            end
            
            obj.client = client;
            obj.value = value;
        end
        
    end
    
end