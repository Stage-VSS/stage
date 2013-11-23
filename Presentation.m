classdef Presentation < handle
    
    properties
        canvas
        duration
    end
    
    properties (SetAccess = private)
        stimuli
        controllers
    end
    
    methods
        
        function obj = Presentation(canvas, duration)
            obj.canvas = canvas;
            obj.duration = duration;
        end
        
        function addStimulus(obj, stimulus)
            obj.stimuli{end + 1} = stimulus;
        end
        
        function addController(obj, handle, parameterName, funcHandle)
            obj.controllers{end + 1} = {handle, parameterName, funcHandle};
        end
        
        function play(obj)            
            % Initialize all stimuli.
            for i = 1:length(obj.stimuli)
                obj.stimuli{i}.init(obj.canvas);
            end            
            
            frameTimer = FrameTimer();
            
            frame = 0;
            pattern = 0;
            time = 0;
            start = tic;
            while time < obj.duration
                obj.canvas.clear();
                
                % Call controllers.
                state.frame = frame;
                state.pattern = pattern;
                state.time = time;
                for i = 1:length(obj.controllers)
                    controller = obj.controllers{i};
                    handle = controller{1};
                    param = controller{2};
                    func = controller{3};

                    handle.(param) = func(state);
                end

                % Draw stimuli.
                for i = 1:length(obj.stimuli)
                    obj.stimuli{i}.draw();
                end
                
                % Flip back and front buffers.
                obj.canvas.window.flip();
                frameTimer.tick();
                
                frame = frame + 1;
                time = toc(start);
            end
            
            disp(['Longest Frame: ' num2str(frameTimer.longestFrameDuration)]);
        end
        
    end
    
end

