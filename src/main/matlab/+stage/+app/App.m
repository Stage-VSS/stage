classdef App < handle

    methods (Static)

        function n = name()
            n = 'Stage';
        end

        function d = description()
            d = 'Visual Stimulus System';
        end

        function v = version()
            v = '2.3.3.0'; % i.e. 2.3-r
        end

        function o = owner()
            o = 'Stage-VSS';
        end

        function r = repo()
            r = 'stage';
        end

    end

end
