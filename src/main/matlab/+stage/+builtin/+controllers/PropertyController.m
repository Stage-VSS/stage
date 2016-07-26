classdef PropertyController < stage.core.Controller
    % A controller that associates an object's property with a given function. When this controller is evaluated, the
    % given function is called and the value it returns is assigned to the associated property.
    
    properties (Access = private)
        handles
        propertyName
        funcHandle
    end

    methods

        function obj = PropertyController(handles, propertyName, funcHandle)
            if ~iscell(handles)
                handles = {handles};
            end
            
            for i = 1:numel(handles)
                if ~isprop(handles{i}, propertyName)
                    error(['At least one handle does not contain a property named ''' propertyName '''']);
                end
            end

            if nargin(funcHandle) < 1
                error('The given function must have at least 1 input argument');
            end

            obj.handles = handles;
            obj.propertyName = propertyName;
            obj.funcHandle = funcHandle;
        end

        function evaluate(obj, state)
            state.handles = obj.handles;
            value = obj.funcHandle(state);
            
            for i = 1:numel(obj.handles)
                if ~isequal(value, obj.handles{i}.(obj.propertyName))
                    obj.handles{i}.(obj.propertyName) = value;
                end
            end
        end

    end

end
