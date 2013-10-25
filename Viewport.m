classdef Viewport < handle
    
    properties
        size
        screen
        stimuli
        projection
    end
    
    methods
        
        function obj = Viewport(screen, stimuli)
            obj.size = screen.size;           
            obj.screen = screen;
            obj.stimuli = stimuli;
            obj.projection = OrthographicProjection(0, obj.size(1), 0, obj.size(2));
        end
        
        function makeCurrent(obj)            
            mglTransform('GL_PROJECTION', 'glViewport', 0, 0, obj.size(1), obj.size(2));
            obj.projection.apply();
        end
        
        function draw(obj)            
            obj.makeCurrent();
            for i = 1:length(obj.stimuli)
                obj.stimuli{i}.draw();
            end
        end
        
    end
    
end