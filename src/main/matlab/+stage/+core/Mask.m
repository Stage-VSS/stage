classdef Mask < handle
    % A transparency (alpha) mask. Masks are generally applied to stimuli that support them via the setMask() method of
    % the Stimulus.

    properties (SetAccess = private)
        canvas
        texture
    end

    properties (Access = private)
        matrix
    end

    methods

        function obj = Mask(matrix)
            % Constructs a mask from an M-by-N-by-1 matrix. A value of 0 is completely transparent. A value of 255 is
            % completely opaque.

            if ~isa(matrix, 'uint8')
                error('Matrix must be of class uint8');
            end

            if ~ismatrix(matrix)
                error('Matrix must be a matrix');
            end

            obj.matrix = matrix;
        end

        function init(obj, canvas)
            obj.canvas = canvas;

            obj.texture = stage.core.gl.TextureObject(canvas, 2);
            obj.texture.setImage(obj.matrix);
            obj.texture.generateMipmap();
        end

    end

    methods (Static)

        function mask = createCircularEnvelope(resolution)
            % Creates a circular envelope mask.

            if nargin < 1
                resolution = 512;
            end

            distanceMatrix = createDistanceMatrix(resolution);

            circle = uint8((distanceMatrix <= 1) * 255);
            mask = stage.core.Mask(circle);
        end

        function mask = createGaussianEnvelope(resolution)
            % Creates a gaussian envelope mask.

            if nargin < 1
                resolution = 512;
            end

            distanceMatrix = createDistanceMatrix(resolution);

            sigma = 1/3;
            gaussian = uint8(exp(-distanceMatrix.^2 / (2 * sigma^2)) * 255);
            mask = stage.core.Mask(gaussian);
        end

        function mask = createCircularAperture(size, resolution)
            % Creates a circular aperture mask with a given aperture size from 0 to 1.

            if nargin < 2
                resolution = 512;
            end

            distanceMatrix = createDistanceMatrix(resolution);
            aperture = uint8((distanceMatrix > size) * 255);
            mask = stage.core.Mask(aperture);
        end

        function mask = createSquareAperture(size, resolution)
            % Creates a square aperture mask with a given aperture size from 0 to 1.

            if nargin < 2
                resolution = 512;
            end

            step = 2 / (resolution - 1);
            [xx, yy] = meshgrid(-1:step:1, -1:step:1);
            grid = max(abs(xx), abs(yy));
            aperture = uint8((grid > size) * 255);
            mask = stage.core.Mask(aperture);
        end

        function mask = createAnnulus(innerSize, outerSize, resolution)
            % Creates a annulus mask with a given inner and outer size from 0 to 1.

            if nargin < 3
                resolution = 512;
            end

            distanceMatrix = createDistanceMatrix(resolution);
            annulus = uint8((distanceMatrix > innerSize & distanceMatrix < outerSize) * 255);
            mask = stage.core.Mask(annulus);
        end

    end

end

function m = createDistanceMatrix(size)
    step = 2 / (size - 1);
    [xx, yy] = meshgrid(-1:step:1, -1:step:1);
    m = sqrt(xx.^2 + yy.^2);
end
