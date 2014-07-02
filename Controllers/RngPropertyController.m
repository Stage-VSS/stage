% A property controller that stores and uses it's own random number generator (rng) settings.

classdef RngPropertyController < PropertyController
    
    properties
        seed
        generator
    end
    
    properties (Access = private)
        rngSettings
        needToUpdateRng
    end
    
    methods
        
        function obj = RngPropertyController(handle, propertyName, funcHandle)
            obj = obj@PropertyController(handle, propertyName, funcHandle);
            obj.seed = 0;
            obj.generator = 'twister';
            obj.needToUpdateRng = true;
        end
        
        function evaluate(obj, state)
            scurr = rng;
            if ~isempty(obj.rngSettings)
                rng(obj.rngSettings);
            end
            
            if obj.needToUpdateRng
                obj.updateRng();
            end
            
            evaluate@PropertyController(obj, state);
            
            obj.rngSettings = rng;
            rng(scurr);
        end
        
        function set.seed(obj, s)
            obj.seed = s;
            obj.needToUpdateRng = true; %#ok<MCSUP>
        end
        
        function set.generator(obj, g)
            obj.generator = g;
            obj.needToUpdateRng = true; %#ok<MCSUP>
        end
        
    end
    
    methods (Access = private)
        
        function updateRng(obj)
            rng(obj.seed, obj.generator);
            obj.needToUpdateRng = false;
        end
        
    end
    
end