classdef StageDevice < symphonyui.core.Device
    
    properties (Access = private)
        stage
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
            
            obj.stage = stage.core.network.StageClient();
            obj.stage.connect(host, port);
        end
        
        function close(obj)
            obj.stage.disconnect();
        end
        
        function s = getCanvasSize(obj)
            s = obj.stage.getCanvasSize();
        end
        
        function r = getMonitorRefreshRate(obj)
            r = obj.stage.getMonitorRefreshRate();
        end
        
        function r = getMonitorResolution(obj)
            r = obj.stage.getMonitorResolution();
        end
        
        function [red, green, blue] = getMonitorGammaRamp(obj)
            [red, green, blue] = obj.stage.getMonitorGammaRamp();
        end
        
        function setMonitorGammaRamp(obj, red, green, blue)
            obj.stage.setMonitorGammaRamp(red, green, blue);
        end
        
        function play(obj, presentation, prerender)
            if nargin < 3
                prerender = false;
            end
            obj.stage.play(presentation, prerender);
        end
        
        function replay(obj)
            obj.stage.replay();
        end
        
        function i = getPlayInfo(obj)
            i = obj.stage.getPlayInfo();
        end
        
        function clearMemory(obj)
           obj.stage.clearMemory();
        end
        
    end
    
end

