% Abstract class for all visual stimuli. 

classdef Stimulus < handle
    
    % All stimulus properties with public set access should expect to be assigned during playback and behave 
    % appropriately. If a stimulus property must be set before initialization it should have private set access and be 
    % assigned in the constructor or a set[PropertyName]() method. This convention allows a user to quickly determine 
    % which properties are suitable for use in controllers.
    
    properties
        visible = true  % Stimulus visibility (true or false)
    end
    
    properties (SetAccess = private)
        canvas
    end
    
    methods
        
        % Initializes this stimulus for drawing on the given canvas. Must be called before using draw().
        function init(obj, canvas)
            obj.canvas = canvas;
        end
        
        % Draws a single instance of this stimulus onto the canvas.
        function draw(obj)
            if obj.visible
                obj.performDraw();
            end
        end
        
    end
        
    methods (Abstract, Access = protected)
        % The actual drawing implementation for the subclass.
        performDraw(obj);
    end
    
end