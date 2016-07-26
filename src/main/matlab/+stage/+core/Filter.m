classdef Filter < handle
    % A convolution filter. Filters are generally applied to stimuli that support them via the setFilter() method of the
    % Stimulus. Edge handling is determined by the wrap mode of the stimulus.
    
    properties (SetAccess = private)
        canvas
        texture
    end

    properties (Access = private)
        kernel
    end

    methods
        
        function obj = Filter(kernel)
            % Constructs a filter from an M-by-N-by-1 convolution matrix (kernel).
            
            if ~ismatrix(kernel)
                error('Kernel must be a matrix');
            end

            obj.kernel = single(kernel);
        end

        function init(obj, canvas)
            obj.canvas = canvas;

            obj.texture = stage.core.gl.TextureObject(canvas, 2);
            obj.texture.setMinFunction(GL.NEAREST);
            obj.texture.setMagFunction(GL.NEAREST);
            obj.texture.setImage(obj.kernel);
        end

    end

end
