classdef Controller < handle
    % Abstract class for all controllers.
    
    methods (Abstract)
        evaluate(obj, state);
    end
    
end