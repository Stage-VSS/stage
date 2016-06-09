classdef App < handle
    
    methods (Static)
        
        function n = name()
            n = 'Stage';
        end
        
        function d = description()
            d = 'Visual Stimulus System';
        end
        
        function v = version()
            v = '2.0.3.2'; % i.e. 2.0-r2
        end
        
        function o = owner()
            o = 'Stage-VSS';
        end
        
        function r = repo()
            r = 'stage2';
        end
        
    end
    
end

