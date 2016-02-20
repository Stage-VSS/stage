classdef StageDevice < symphonyui.core.Device
    
    properties (Access = private)
        stageClient
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
            
            obj.stageClient = stage.core.network.StageClient();
            obj.stageClient.connect(host, port);
            
            obj.addConfigurationSetting('canvasSize', obj.stageClient.getCanvasSize(), 'isReadOnly', true);
            obj.addConfigurationSetting('monitorRefreshRate', obj.stageClient.getMonitorRefreshRate(), 'isReadOnly', true);
            obj.addConfigurationSetting('monitorResolution', obj.stageClient.getMonitorResolution(), 'isReadOnly', true);
        end
        
        function close(obj)
            obj.stageClient.disconnect();
        end
        
        function s = getCanvasSize(obj)
            s = obj.getConfigurationSetting('canvasSize');
        end
        
        function r = getMonitorRefreshRate(obj)
            r = obj.getConfigurationSetting('monitorRefreshRate');
        end
        
        function r = getMonitorResolution(obj)
            r = obj.getConfigurationSetting('monitorResolution');
        end
        
        function [red, green, blue] = getMonitorGammaRamp(obj)
            [red, green, blue] = obj.stageClient.getMonitorGammaRamp();
        end
        
        function setMonitorGammaRamp(obj, red, green, blue)
            obj.stageClient.setMonitorGammaRamp(red, green, blue);
        end
        
        function play(obj, presentation, prerender)
            if nargin < 3
                prerender = false;
            end
            obj.stageClient.play(presentation, prerender);
        end
        
        function replay(obj)
            obj.stageClient.replay();
        end
        
        function i = getPlayInfo(obj)
            i = obj.stageClient.getPlayInfo();
        end
        
        function clearMemory(obj)
           obj.stageClient.clearMemory();
        end
        
    end
    
end

