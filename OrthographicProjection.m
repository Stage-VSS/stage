classdef OrthographicProjection < Projection
    
    methods
        
        function obj = OrthographicProjection(left, right, bottom, top, zClipNear, zClipFar)
            if nargin < 5
                zClipNear = -1;
            end
            
            if nargin < 6
                zClipFar = 1;
            end
            
            % http://www.opengl.org/sdk/docs/man2/xhtml/glOrtho.xml
            obj.matrix = [2/(right - left), 0,              0,                       -(right+left)/(right-left);
                          0,                2/(top-bottom), 0,                       -(top+bottom)/(top-bottom);
                          0,                0,              -2/(zClipFar-zClipNear), -(zClipFar+zClipNear)/(zClipFar-zClipNear);
                          0,                0,              0,                       1];
        end
        
    end
    
end

