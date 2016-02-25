classdef StageDevice < symphonyui.core.Device
    
    properties (Access = protected)
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
            
            cobj = Symphony.Core.UnitConvertingExternalDevice(['Stage@' host], 'Unspecified', Symphony.Core.Measurement(0, symphonyui.core.Measurement.UNITLESS));
            obj@symphonyui.core.Device(cobj);
            obj.cobj.MeasurementConversionTarget = symphonyui.core.Measurement.UNITLESS;
            
            obj.stageClient = stage.core.network.StageClient();
            obj.stageClient.connect(host, port);
            
            obj.addConfigurationSetting('canvasSize', obj.stageClient.getCanvasSize(), 'isReadOnly', true);
            obj.addConfigurationSetting('monitorRefreshRate', obj.stageClient.getMonitorRefreshRate(), 'isReadOnly', true);
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
        
        function play(obj, presentation, prerender)
            if nargin < 3
                prerender = false;
            end
            if prerender
                player = stage.builtin.players.PrerenderedPlayer(presentation);
            else
                player = stage.builtin.players.RealtimePlayer(presentation);
            end
            obj.stageClient.play(player);
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

