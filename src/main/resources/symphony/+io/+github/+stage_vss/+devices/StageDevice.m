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
        
        function s = getCanvasSize(obj)
            s = obj.client.getCanvasSize();
        end
        
        function r = getMonitorRefreshRate(obj)
            r = obj.client.getMonitorRefreshRate();
        end
        
        function r = getMonitorResolution(obj)
            r = obj.client.getMonitorResolution();
        end
        
        function [red, green, blue] = getMonitorGammaRamp(obj)
            [red, green, blue] = obj.client.getMonitorGammaRamp();
        end
        
        function setMonitorGammaRamp(obj, red, green, blue)
            obj.client.setMonitorGammaRamp(red, green, blue);
        end
        
        function play(obj, presentation, prerender)
            if nargin < 3
                prerender = false;
            end
            obj.client.play(presentation, prerender);
        end
        
        function replay(obj)
            obj.client.replay();
        end
        
        function i = getPlayInfo(obj)
            i = obj.client.getPlayInfo();
        end
        
        function clearMemory(obj)
           obj.client.clearMemory();
        end
        
    end
    
end

