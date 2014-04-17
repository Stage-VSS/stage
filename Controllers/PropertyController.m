classdef PropertyController < Controller
    
    properties (Access = private)
        handle
        propertyName
        funcHandle
    end
    
    methods
        
        function obj = PropertyController(handle, propertyName, funcHandle)
            if ~isprop(handle, propertyName)
                error(['The handle does not contain a property named ''' propertyName '''']);
            end
            
            if nargin(funcHandle) < 1
                error('The given function must have at least 1 input argument');
            end
            
            obj.handle = handle;
            obj.propertyName = propertyName;
            obj.funcHandle = funcHandle;
        end
        
        function evaluate(obj, state)
            value = obj.funcHandle(state);
            
            if ~isequal(value, obj.handle.(obj.propertyName))
                obj.handle.(obj.propertyName) = value;
            end
        end
        
    end
    
end