classdef (Abstract) StageProtocol < symphonyui.core.Protocol
    
    methods (Abstract)
        p = createPresentation(obj);
    end
    
    methods
        
        function controllerDidStartHardware(obj)
            controllerDidStartHardware@symphonyui.core.Protocol(obj);
            obj.rig.getDevice('Stage').play(obj.createPresentation());
        end
        
        function tf = shouldContinuePreloadingEpochs(obj) %#ok<MANU>
            tf = false;
        end
        
        function tf = shouldWaitToContinuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared > obj.numEpochsCompleted || obj.numIntervalsPrepared > obj.numIntervalsCompleted;
        end
        
        function completeRun(obj)
            completeRun@symphonyui.core.Protocol(obj);
            obj.rig.getDevice('Stage').clearMemory();
        end
        
        function [tf, msg] = isValid(obj)
            [tf, msg] = isValid@symphonyui.core.Protocol(obj);
            if tf
                tf = ~isempty(obj.rig.getDevices('Stage'));
                msg = 'No stage';
            end
        end
        
    end
    
end

