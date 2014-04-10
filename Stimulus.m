% Abstract class for all visual stimuli. 

classdef Stimulus < handle
    
    % All stimulus properties with public set access should expect to be assigned during playback and behave 
    % appropriately. If a stimulus property must be set before initialization it should have private set access and be 
    % assigned in the constructor or a set[PropertyName]() method. This convention allows a user to quickly determine 
    % which properties are suitable for use in controllers.
    
    properties (SetAccess = private)
        canvas
    end
    
    methods
        
        % Initializes this stimulus for drawing on the given canvas. Must be called before using draw().
        function init(obj, canvas)
            obj.canvas = canvas;
        end
        
    end
        
    methods (Abstract)
        % Draws a single instance of this stimulus onto the canvas.
        draw(obj);
    end
    
end