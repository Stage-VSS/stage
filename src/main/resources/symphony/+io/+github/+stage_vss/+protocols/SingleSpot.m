classdef SingleSpot < symphonyui.core.Protocol
    
    properties
        amp                             % Output amplifier
        preTime = 50                    % Spot leading duration (ms)
        stimTime = 500                  % Spot duration (ms)
        tailTime = 50                   % Spot trailing duration (ms)
        spotIntensity = 1.0             % Spot light intensity (0-1)
        spotDiameter = 300              % Spot diameter size (pixels)
        backgroundIntensity = 0.5       % Background light intensity (0-1)
        centerOffset = [0, 0]           % Spot [x, y] center offset (pixels)
        numberOfAverages = uint16(5)    % Number of epochs
        interpulseInterval = 0          % Duration between spots (s)
    end
    
    properties (Hidden)
        ampType
    end
    
    properties (Access = private)
        stage
    end
    
    methods
        
        function onSetRig(obj)
            onSetRig@symphonyui.core.Protocol(obj);
            
            amps = appbox.firstNonEmpty(obj.rig.getDeviceNames('Amp'), {'(None)'});
            obj.amp = amps{1};
            obj.ampType = symphonyui.core.PropertyType('char', 'row', amps);
            
            stages = appbox.firstNonEmpty(obj.rig.getDeviceNames('Stage'), {[]});
            obj.stage = stages{1};
        end
        
        function p = getPreview(obj, panel)
            p = io.github.stage_vss.previews.StagePreview(panel, @()createPreviewStimuli(obj), @()obj.backgroundIntensity);
            function s = createPreviewStimuli(obj)
                s = {obj.spotStimulus()};
            end
        end
        
        function prepareRun(obj)
            prepareRun@symphonyui.core.Protocol(obj);
            
            obj.showFigure('symphonyui.builtin.figures.ResponseFigure', obj.rig.getDevice(obj.amp));
            
            device = obj.rig.getDevice(obj.stage);
            device.client.setCanvasClearColor(obj.backgroundIntensity);
        end
        
        function spot = spotStimulus(obj)
            spot = stage.builtin.stimuli.Ellipse();
            spot.color = obj.spotIntensity;
            spot.radiusX = obj.spotDiameter/2;
            spot.radiusY = obj.spotDiameter/2;
            spot.position = [640, 480]/2 + obj.centerOffset;
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@symphonyui.core.Protocol(obj, epoch);
            
            device = obj.rig.getDevice(obj.amp);
            duration = (obj.preTime + obj.stimTime + obj.tailTime) / 1e3;
            epoch.addDirectCurrentStimulus(device, device.background, duration, obj.sampleRate);
            epoch.addResponse(device);
            
            device = obj.rig.getDevice(obj.stage);
            presentation = stage.core.Presentation((obj.preTime + obj.stimTime + obj.tailTime) * 1e-3);
            presentation.addStimulus(obj.spotStimulus());
            device.client.play(presentation);
        end
        
        function prepareInterval(obj, interval)
            prepareInterval@symphonyui.core.Protocol(obj, interval);
            
            if obj.interpulseInterval > 0
                device = obj.rig.getDevice(obj.amp);
                interval.addDirectCurrentStimulus(device, device.background, obj.interpulseInterval, obj.sampleRate);
            end
        end
        
        function tf = shouldContinuePreparingEpochs(obj)
            tf = obj.numEpochsPrepared < obj.numberOfAverages;
        end
        
        function tf = shouldContinueRun(obj)
            tf = obj.numEpochsCompleted < obj.numberOfAverages;
        end
        
        function [tf, msg] = isValid(obj)
            tf = ~isempty(obj.stage);
            msg = 'No stage';
        end
        
    end
    
end

