classdef StageDevice < symphonyui.core.Device
    
    properties (SetAccess = private)
        client
    end
    
    methods
        
        function obj = StageDevice(host, port)
            if nargin < 1
                host = 'localhost';
            end
            if nargin < 2
                port = 5678;
            end
            
            cobj = Symphony.Core.UnitConvertingExternalDevice(['Stage@' host], 'Unspecified', Symphony.Core.Measurement(0, symphonyui.core.Measurement.NORMALIZED));
            obj@symphonyui.core.Device(cobj);
            
            obj.cobj.MeasurementConversionTarget = symphonyui.core.Measurement.NORMALIZED;
            
            c = stage.core.network.Client();
            c.connect(host, port);
            obj.client = stage.builtin.network.BasicClient(c);
        end
        
        function close(obj)
            obj.client.disconnect();
        end
        
    end
    
end

