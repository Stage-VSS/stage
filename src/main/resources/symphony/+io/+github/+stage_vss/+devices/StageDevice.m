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
            
            obj.client = stage.core.network.StageClient();
            obj.client.connect(host, port);
        end
        
        function close(obj)
            obj.client.disconnect();
        end
        
    end
    
end

