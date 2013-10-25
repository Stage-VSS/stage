classdef Screen < handle
    
    properties (SetAccess = private)
        number
        size
        background
    end
    
    methods
        
        function obj = Screen(number)
            obj.number = number;
            obj.background = 0;
            
            mglOpen(number);
            mglClearScreen(obj.background);
            mglFlush();
            mglClearScreen(obj.background);
            mglFlush();
        end
        
        function s = get.size(obj)
            s = [mglGetParam('screenWidth'), mglGetParam('screenHeight')];
        end
        
        % setBackground
        
        % setGamma
        
        function makeCurrent(obj)
            mglSwitchDisplay(obj.number);
        end
        
        function clear(obj)
            mglClearScreen(obj.background);
        end
        
        function flip(obj)
            mglFlush();
        end
        
        function close(obj)
            mglClose();
        end
        
%         function delete(obj)
%             obj.close();
%         end
        
    end
    
end

