% A compositor is responsible for compositing a collection of stimuli into a single image and drawing the result onto a
% canvas.

classdef Compositor < handle
    
    properties (SetAccess = private)
        canvas
    end
    
    methods
        
        function setCanvas(obj, canvas)
            if canvas == obj.canvas
                return;
            end
            
            obj.canvas = canvas;
        end
        
        function drawFrame(obj, stimuli, controllers, frame, frameDuration, time)
            state.frame = frame;
            state.frameDuration = frameDuration;
            state.time = time;
            
            obj.callControllers(controllers, state);
            
            obj.drawStimuli(stimuli);
        end
        
    end
    
    methods (Access = protected)
        
        function callControllers(obj, controllers, state) %#ok<INUSL>
            for i = 1:length(controllers)
                c = controllers{i};
                handle = c{1};
                prop = c{2};
                func = c{3};

                handle.(prop) = func(state);
            end
        end
        
        function drawStimuli(obj, stimuli) %#ok<INUSL>
            for i = 1:length(stimuli)
                stimuli{i}.draw();
            end
        end
        
    end
    
end