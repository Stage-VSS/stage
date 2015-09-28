% Abstract class for all controllers. 

classdef Controller < handle
    
    methods (Abstract)
        evaluate(obj, state);
    end
    
end