classdef Presentation < handle
    
    properties
        viewports
        duration
    end
    
    properties (SetAccess = private)
        controllers
    end
    
    methods
        
        function obj = Presentation(viewports, duration)
            obj.viewports = viewports;
            obj.duration = duration;
        end
        
        function addController(obj, handle, parameterName, funcHandle)
            obj.controllers{end + 1} = {handle, parameterName, funcHandle};
        end
        
        function play(obj)
            % Get all screens
            screens = {};
            for i = 1:length(obj.viewports)
                s = obj.viewports{i}.screen;
                if ~any(cellfun(@(c)isequal(c, s), screens))
                    screens{end + 1} = s;
                end
            end
            
            frame = 0;
            time = 0;
            start = tic;
            while time < obj.duration
                % Call controllers
                state.time = time;
                state.frame = frame;
                for i = 1:length(obj.controllers)
                    controller = obj.controllers{i};
                    handle = controller{1};
                    param = controller{2};
                    func = controller{3};
                    
                    handle.(param) = func(state);
                end
                
                % Clear screens
                for i = 1:length(screens)
                    screens{i}.clear();
                end
                
                % Draw viewports
                for i = 1:length(obj.viewports)
                    obj.viewports{i}.draw();
                end
                
                % Flip buffers
                for i = 1:length(screens)
                    screens{i}.flip();
                end
                
                frame = frame + 1;
                time = toc(start);
            end
        end
        
    end
    
end

