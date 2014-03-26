% A Compositor is responsible for arranging frames of a presentation.

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
        
        function drawFrame(obj, presentation, frame, frameDuration, time)
            state.frame = frame;
            state.frameDuration = frameDuration;
            state.time = time;
            
            obj.callControllers(presentation.controllers, state);
            
            obj.drawStimuli(presentation.stimuli);
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