classdef FullFieldNoise < symphonyui.core.Protocol
    
    properties
        amp                             % Output amplifier
        preTime = 500                   % Noise leading duration (ms)
        stimTime = 1000                 % Noise duration (ms)
        tailTime = 500                  % Noise trailing duration (ms)
        backgroundIntensity = 0.5       % Background light intensity (0-1)
        centerOffset = [0, 0]           % Noise [x, y] center offset (pixels)
        numberOfAverages = uint16(5)    % Number of epochs
        interpulseInterval = 0          % Duration between noise (s)
    end
    
    properties (Hidden)
        ampType
    end
    
    methods
        
        function onSetRig(obj)
            onSetRig@symphonyui.core.Protocol(obj);
            
            [obj.amp, obj.ampType] = obj.createDeviceNamesProperty('Amp');
        end
        
        function p = getPreview(obj, panel)
            p = io.github.stage_vss.previews.StagePreview(panel, @()obj.createNoisePresentation());
        end
        
        function prepareRun(obj)
            prepareRun@symphonyui.core.Protocol(obj);
            
            obj.showFigure('symphonyui.builtin.figures.ResponseFigure', obj.rig.getDevice(obj.amp));
            obj.showFigure('io.github.stage_vss.figures.FrameTimingFigure', obj.rig.getDevice('Stage'));
        end
        
        function p = createNoisePresentation(obj)
            p = stage.core.Presentation((obj.preTime + obj.stimTime + obj.tailTime) * 1e-3);
            
            noise = stage.builtin.stimuli.Rectangle();
            noise.size = [640, 480]*2;
            noise.position = [640, 480]/2 + obj.centerOffset;
            
            noiseColor = stage.builtin.controllers.PropertyController(noise, 'color', @(s)rand());
            
            p.setBackgroundColor(obj.backgroundIntensity);
            p.addStimulus(noise);
            p.addController(noiseColor);
            
            noiseVisible = stage.builtin.controllers.PropertyController(noise, 'visible', @(state)state.time >= obj.preTime * 1e-3 && state.time < (obj.preTime + obj.stimTime) * 1e-3);
            p.addController(noiseVisible);
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@symphonyui.core.Protocol(obj, epoch);
            
            device = obj.rig.getDevice(obj.amp);
            duration = (obj.preTime + obj.stimTime + obj.tailTime) / 1e3;
            epoch.addDirectCurrentStimulus(device, device.background, duration, obj.sampleRate);
            epoch.addResponse(device);
            
            device = obj.rig.getDevice('Stage');
            device.client.play(obj.createNoisePresentation());
        end
        
        function prepareInterval(obj, interval)
            prepareInterval@symphonyui.core.Protocol(obj, interval);
            
            device = obj.rig.getDevice(obj.amp);
            interval.addDirectCurrentStimulus(device, device.background, obj.interpulseInterval, obj.sampleRate);
        end
        
        function tf = shouldContinuePreloadingEpochs(obj) %#ok<MANU>
            tf = false;
        end
        
        function tf = shouldWaitToContinuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared > obj.numEpochsCompleted || obj.numIntervalsPrepared > obj.numIntervalsCompleted;
        end
        
        function tf = shouldContinuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < obj.numberOfAverages;
        end
        
        function tf = shouldContinueRun(obj)
            tf = obj.numEpochsCompleted < obj.numberOfAverages;
        end
        
        function completeRun(obj)
            completeRun@symphonyui.core.Protocol(obj);
            
            device = obj.rig.getDevice('Stage');
            device.client.clearMemory();
        end
        
        function [tf, msg] = isValid(obj)
            tf = ~isempty(obj.rig.getDevices('Stage'));
            msg = 'No stage';
        end
        
    end
    
end

