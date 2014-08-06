% A property controller that stores and uses it's own random number generator stream.

classdef RngPropertyController < PropertyController
    
    properties
        seed
        generator
    end
    
    properties (Access = private)
        stream
        needToUpdateStream
    end
    
    methods
        
        function obj = RngPropertyController(handle, propertyName, funcHandle)
            obj = obj@PropertyController(handle, propertyName, funcHandle);
            obj.seed = 0;
            obj.generator = 'mt19937ar';
            obj.needToUpdateStream = true;
        end
        
        function evaluate(obj, state)
            if obj.needToUpdateStream
                obj.updateStream();
            end
            
            s = RandStream.setGlobalStream(obj.stream);
            reset = onCleanup(@()RandStream.setGlobalStream(s));

            evaluate@PropertyController(obj, state);
        end
        
        function set.seed(obj, s)
            obj.seed = s;
            obj.needToUpdateStream = true; %#ok<MCSUP>
        end
        
        function set.generator(obj, g)
            obj.generator = g;
            obj.needToUpdateStream = true; %#ok<MCSUP>
        end
        
    end
    
    methods (Access = private)
        
        function updateStream(obj)
            obj.stream = RandStream(obj.generator, 'Seed', obj.seed);
            obj.needToUpdateStream = false;
        end
        
    end
    
end