% A transparency (alpha) mask. Masks are generally applied to stimuli that support them via the setMask() method of the 
% Stimulus.

classdef Mask < handle
    
    properties (SetAccess = private)
        texture
    end
    
    properties (Access = private)
        matrix
    end
    
    methods
        
        % Constructs a mask from an M-by-N-by-1 matrix. A value of 0 is completely transparent. A value of 255 is
        % completely opaque.
        function obj = Mask(matrix)
            if ~isa(matrix, 'uint8')
                error('Matrix must be of class uint8');
            end
            
            if ~ismatrix(matrix)
                error('Matrix must be a matrix');
            end
            
            obj.matrix = matrix;
        end
        
        function init(obj, canvas)            
            obj.texture = TextureObject(canvas, 2);
            obj.texture.setImage(obj.matrix);
            obj.texture.generateMipmap();
        end
        
    end
    
    methods (Static)
        
        % Creates a circular envelope mask.
        function mask = createCircularEnvelope(resolution)
            if nargin < 1
                resolution = 512;
            end
            
            distanceMatrix = createDistanceMatrix(resolution);
            
            circle = uint8((distanceMatrix <= 1) * 255);
            mask = Mask(circle);
        end
        
        % Creates a gaussian envelope mask.
        function mask = createGaussianEnvelope(resolution)
            if nargin < 1
                resolution = 512;
            end
            
            distanceMatrix = createDistanceMatrix(resolution);
            
            sigma = 1/3;
            gaussian = uint8(exp(-distanceMatrix.^2 / (2 * sigma^2)) * 255);
            mask = Mask(gaussian);
        end
        
        % Creates a circular aperture mask with a given aperture size from 0 to 1.
        function mask = createCircularAperture(size, resolution)
            if nargin < 2
                resolution = 512;
            end
            
            distanceMatrix = createDistanceMatrix(resolution);
            aperture = uint8((distanceMatrix > size) * 255);
            mask = Mask(aperture);
        end
        
        % Creates a square aperture mask with a given aperture size from 0 to 1.
        function mask = createSquareAperture(size, resolution)
            if nargin < 2
                resolution = 512;
            end
            
            step = 2 / (resolution - 1);
            [xx, yy] = meshgrid(-1:step:1, -1:step:1);
            grid = max(abs(xx), abs(yy));
            aperture = uint8((grid > size) * 255);
            mask = Mask(aperture);
        end
        
    end
    
end

function m = createDistanceMatrix(size)
    step = 2 / (size - 1);
    [xx, yy] = meshgrid(-1:step:1, -1:step:1);
    m = sqrt(xx.^2 + yy.^2);
end