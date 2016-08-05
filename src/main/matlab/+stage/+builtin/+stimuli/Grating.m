classdef Grating < stage.core.Stimulus
    % A vertical grating stimulus.
    
    properties
        position = [0, 0]       % Center position on the canvas [x, y] (pixels)
        size = [100, 100]       % Size [width, height] (pixels)
        orientation = 0         % Orientation (degrees)
        color = [1, 1, 1]       % Peak color as single intensity value or [R, G, B] (0 to 1)
        opacity = 1             % Opacity (0 to 1)
        contrast = 1            % Scale factor for color values (-1 to 1, negative values invert the grating)
        phase = 0               % Phase offset (degrees)
        spatialFreq = 1/100     % Spatial frequency (cycles/pixels)
    end

    properties (Access = private)
        profile                     % Luminance profile wave ('sine', 'square', or 'sawtooth')
        mask                        % Stimulus mask
        filter                      % Stimulus filter
        resolution                  % Texture resolution
        vbo                         % Vertex buffer object
        vao                         % Vertex array object
        texture                     % Grating texture
        needToUpdateVertexBuffer
        needToUpdateTexture
    end

    methods
        
        function obj = Grating(profile, resolution)
            % Contructs a grating stimulus with an optionally specified luminance profile and texture resolution. The
            % profile may be 'sine', 'square', or 'sawtooth'.
            
            if nargin < 1
                profile = 'sine';
            end

            if nargin < 2
                resolution = 512;
            end

            if ~any(strcmp(profile, {'sine', 'square', 'sawtooth'}))
                error('Unknown profile');
            end

            obj.profile = profile;
            obj.resolution = resolution;
        end
        
        function setMask(obj, mask)
            % Assigns a mask to the stimulus.
            obj.mask = mask;
        end
        
        function setFilter(obj, filter)
            % Assigns a filter to the stimulus.
            obj.filter = filter;
        end

        function init(obj, canvas)
            init@stage.core.Stimulus(obj, canvas);

            if ~isempty(obj.mask)
                obj.mask.init(canvas);
            end

            if ~isempty(obj.filter)
                obj.filter.init(canvas);
            end

            % Each vertex position is followed by a texture coordinate and a mask coordinate.
            vertexData = [-1  1  0  1,  0  1,  0  1 ...
                          -1 -1  0  1,  0  0,  0  0 ...
                           1  1  0  1,  1  1,  1  1 ...
                           1 -1  0  1,  1  0,  1  0];

            obj.vbo = stage.core.gl.VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.DYNAMIC_DRAW);

            obj.vao = stage.core.gl.VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 8*4, 0);
            obj.vao.setAttribute(obj.vbo, 1, 2, GL.FLOAT, GL.FALSE, 8*4, 4*4);
            obj.vao.setAttribute(obj.vbo, 2, 2, GL.FLOAT, GL.FALSE, 8*4, 6*4);

            % TODO: Anything gained by making this a 1D texture?
            obj.texture = stage.core.gl.TextureObject(canvas, 2);
            obj.texture.setWrapModeS(GL.REPEAT);
            obj.texture.setImage(zeros(1, obj.resolution, 4, 'uint8'));

            obj.updateVertexBuffer();
            obj.updateTexture();
        end

        function set.size(obj, size)
            obj.size = size;
            obj.needToUpdateVertexBuffer = true; %#ok<MCSUP>
        end

        function set.phase(obj, phase)
            obj.phase = phase;
            obj.needToUpdateVertexBuffer = true; %#ok<MCSUP>
        end

        function set.spatialFreq(obj, freq)
            obj.spatialFreq = freq;
            obj.needToUpdateVertexBuffer = true; %#ok<MCSUP>
        end

        function set.contrast(obj, contrast)
            obj.contrast = contrast;
            obj.needToUpdateTexture = true; %#ok<MCSUP>
        end

    end

    methods (Access = protected)

        function performDraw(obj)
            if obj.needToUpdateVertexBuffer
                obj.updateVertexBuffer();
            end

            if obj.needToUpdateTexture
                obj.updateTexture();
            end

            modelView = obj.canvas.modelView;
            modelView.push();
            modelView.translate(obj.position(1), obj.position(2), 0);
            modelView.rotate(obj.orientation, 0, 0, 1);
            modelView.scale(obj.size(1) / 2, obj.size(2) / 2, 1);

            c = obj.color;
            if length(c) == 1
                c = [c, c, c, obj.opacity];
            elseif length(c) == 3
                c = [c, obj.opacity];
            end

            obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c, obj.mask, obj.texture, obj.filter);

            modelView.pop();
        end

    end

    methods (Access = private)

        function updateVertexBuffer(obj)
            nCycles = obj.size(1) * obj.spatialFreq;
            phaseShift = obj.phase / 360;

            vertexData = [-1  1  0  1,  0+phaseShift        1,  0  1 ...
                          -1 -1  0  1,  0+phaseShift        0,  0  0 ...
                           1  1  0  1,  nCycles+phaseShift  1,  1  1 ...
                           1 -1  0  1,  nCycles+phaseShift  0,  1  0];

            obj.vbo.uploadData(single(vertexData));

            obj.needToUpdateVertexBuffer = false;
        end

        function updateTexture(obj)
            switch obj.profile
                case 'sine'
                    wave = sin(linspace(0, 2*pi, obj.resolution));
                case 'square'
                    wave = sin(linspace(0, 2*pi, obj.resolution));
                    wave(wave >= 0) = 1;
                    wave(wave < 0) = -1;
                case 'sawtooth'
                    wave = linspace(-1, 1, obj.resolution);
            end

            wave = wave * obj.contrast;
            wave = (wave + 1) / 2 * 255;

            image = ones(1, obj.resolution, 4, 'uint8') * 255;
            image(:, :, 1:3) = [wave; wave; wave]';

            obj.texture.setSubImage(image);

            obj.needToUpdateTexture = false;
        end

    end

end
