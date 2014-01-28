% The core object for presenting stimuli.

classdef Presentation < handle
    
    properties
        duration
    end
    
    properties (SetAccess = private)
        stimuli
        controllers
    end
    
    methods
        
        % Constructs a presentation with the given duration.
        function obj = Presentation(duration)
            obj.duration = duration;
            obj.stimuli = {};
        end
        
        % Adds a stimulus to the presentation. Stimuli are layered in the order with which they are added; the first
        % stimulus added is on the lowest layer (the layer farthest from the viewer) while the last stimulus added is on
        % the highest layer (the layer closest to the viewer).
        function addStimulus(obj, stimulus)
            if any(cellfun(@(c)c == stimulus, obj.stimuli))
                error('Presentation already contains the given stimulus');
            end
            
            obj.stimuli{end + 1} = stimulus;
        end
        
        % Adds a controller to the presentation. A controller associates an object's property with a given function. 
        % With each frame presented, the presentation calls the given function and passes it a struct containing
        % information about the current state of the presentation (the current number of frames presented, the time
        % elapsed since the start of the presentation, etc). The presentation assigns the value returned by the function
        % to the associated property.
        function addController(obj, handle, propertyName, funcHandle)
            if ~isprop(handle, propertyName)
                error(['The handle does not contain a property named ''' propertyName '''']);
            end
            
            if nargin(funcHandle) < 1
                error('The given function must have at least 1 input argument');
            end
            
            obj.controllers{end + 1} = {handle, propertyName, funcHandle};
        end
        
        function info = play(obj, canvas)            
            % Initialize all stimuli.
            for i = 1:length(obj.stimuli)
                obj.stimuli{i}.init(canvas);
            end            
            
            frameTimer = FrameTimer();
            
            frame = 0;
            pattern = 0;
            time = 0;
            start = glfwGetTime();
            while time < obj.duration
                canvas.clear();
                
                % Call controllers.
                state.frame = frame;
                state.pattern = pattern;
                state.time = time;
                for i = 1:length(obj.controllers)
                    controller = obj.controllers{i};
                    handle = controller{1};
                    prop = controller{2};
                    func = controller{3};

                    handle.(prop) = func(state);
                end

                % Draw stimuli.
                for i = 1:length(obj.stimuli)
                    obj.stimuli{i}.draw();
                end
                
                % Flip back and front buffers.
                canvas.window.flip();
                frameTimer.tick();
                
                frame = frame + 1;
                time = glfwGetTime() - start;
            end
            
            % TODO: Add more playback information.
            info.frameDurations = frameTimer.frameDurations;
        end
        
    end
    
end