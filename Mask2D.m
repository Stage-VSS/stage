classdef Mask2D < handle
    
    properties (SetAccess = private)
        texture
    end
    
    properties (Access = private)
        type
        resolution
    end
    
    methods
        
        function obj = Mask2D(type, resolution)
            if nargin < 1
                type = 'gaussian';
            end
            
            if nargin < 2
                resolution = 256;
            end
            
            if ~strcmp(type, 'gaussian') && ~strcmp(type, 'circle')
                error('Unknown type');
            end
            
            obj.type = type;
            obj.resolution = resolution;
        end
        
        function init(obj, canvas)
            res = obj.resolution;
            
            step = 2 / (res - 1);
            [x, y] = meshgrid(-1:step:1, -1:step:1);
            distanceGrid = sqrt(x.^2 + y.^2);
            
            mask = zeros(res, res, 4, 'uint8');
            
            switch obj.type
                case 'gaussian'
                    sigma = 1/3;
                    mask(:, :, 4) = exp(-distanceGrid.^2 / (2 * sigma^2)) * 255;
                case 'circle'
                    mask(:, :, 4) = (distanceGrid <= 1) * 255;
            end
            
            obj.texture = TextureObject(canvas, 2);
            obj.texture.setImage(mask);
        end
        
    end
    
end