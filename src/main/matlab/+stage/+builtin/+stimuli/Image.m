classdef Image < stage.core.Stimulus
    % An arbitrary image stimulus.
    
    properties
        position = [0, 0]   % Center position on the canvas [x, y] (pixels)
        size = [100, 100]   % Size [width, height] (pixels)
        orientation = 0     % Orientation (degrees)
        color = [1, 1, 1]   % Color multiplier as single value or [R, G, B] (real number)
        opacity = 1         % Opacity (0 to 1)
        shiftX = 0          % Texture shift (scroll) on the x axes (real number; 0 being no shift, 1 being a complete shift)
        shiftY = 0          % Texture shift (scroll) on the y axes (real number; 0 being no shift, 1 being a complete shift)
        imageMatrix         % Image data matrix (M-by-N grayscale, M-by-N-by-3 truecolor, M-by-N-by-4 truecolor with alpha)
    end

    properties (Access = private)
        mask                        % Stimulus mask
        filter                      % Stimulus filter
        minFunction                 % Texture minifying function
        magFunction                 % Texture magnification function
        wrapModeS                   % Wrap mode for texture coordinate s (i.e. x)
        wrapModeT                   % Wrap mode for texture coordinate t (i.e. y)
        vbo                         % Vertex buffer object
        vao                         % Vertex array object
        texture                     % Image texture
        needToUpdateVertexBuffer
        needToUpdateTexture
    end

    methods
        
        function obj = Image(matrix)
            % Constructs an image stimulus with the specified image matrix data. The image data must be provided as an
            % M-by-N (grayscale), M-by-N-by-3 (truecolor), or M-by-N-by-4 (truecolor with alpha) matrix.
            %
            % Typical usage:
            % imageData = imread('my_cool_image.png');
            % image = Image(imageData);
            
            if ~isa(matrix, 'uint8') && ~isa(matrix, 'single')
                error('Matrix must be of class uint8 or single');
            end

            obj.imageMatrix = matrix;
            obj.minFunction = GL.LINEAR_MIPMAP_LINEAR;
            obj.magFunction = GL.LINEAR;
            obj.wrapModeS = GL.REPEAT;
            obj.wrapModeT = GL.REPEAT;
        end
        
        function setMask(obj, mask)
            % Assigns a mask to the stimulus.
            obj.mask = mask;
        end
        
        function setFilter(obj, filter)
            % Assigns a filter to the stimulus.
            obj.filter = filter;
        end
        
        function setMinFunction(obj, func)
            % Sets the OpenGL minifying function for the image (GL.NEAREST, GL.LINEAR, GL.NEAREST_MIPMAP_NEAREST, etc).
            obj.minFunction = func;
        end
        
        function setMagFunction(obj, func)
            % Sets the OpenGL magnifying function for the image (GL.NEAREST or GL.LINEAR).
            obj.magFunction = func;
        end
        
        function setWrapModeS(obj, mode)
            % Sets the OpenGL S (i.e. X) coordinate wrap mode for the image (GL.CLAMP_TO_EDGE, GL.MIRRORED_REPEAT, GL.REPEAT, etc).
            obj.wrapModeS = mode;
        end
        
        function setWrapModeT(obj, mode)
            % Sets the OpenGL T (i.e. Y) coordinate wrap mode for the image (GL.CLAMP_TO_EDGE, GL.MIRRORED_REPEAT, GL.REPEAT, etc).
            obj.wrapModeT = mode;
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

            obj.vbo = stage.core.gl.VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);

            obj.vao = stage.core.gl.VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 8*4, 0);
            obj.vao.setAttribute(obj.vbo, 1, 2, GL.FLOAT, GL.FALSE, 8*4, 4*4);
            obj.vao.setAttribute(obj.vbo, 2, 2, GL.FLOAT, GL.FALSE, 8*4, 6*4);

            image = obj.imageMatrix;
            if size(image, 3) == 1
                image = repmat(image, 1, 1, 3);
            end

            obj.texture = stage.core.gl.TextureObject(canvas, 2);
            obj.texture.setWrapModeS(obj.wrapModeS);
            obj.texture.setWrapModeT(obj.wrapModeT);
            obj.texture.setMinFunction(obj.minFunction);
            obj.texture.setMagFunction(obj.magFunction);
            obj.texture.setImage(image);

            minFunc = obj.minFunction;
            if minFunc == GL.LINEAR_MIPMAP_LINEAR ...
                || minFunc == GL.LINEAR_MIPMAP_NEAREST ...
                || minFunc == GL.NEAREST_MIPMAP_NEAREST ...
                || minFunc == GL.NEAREST_MIPMAP_LINEAR ...

                obj.texture.generateMipmap();
            end

            obj.updateVertexBuffer();
        end

        function set.shiftX(obj, shiftX)
            obj.shiftX = shiftX;
            obj.needToUpdateVertexBuffer = true; %#ok<MCSUP>
        end

        function set.shiftY(obj, shiftY)
            obj.shiftY = shiftY;
            obj.needToUpdateVertexBuffer = true; %#ok<MCSUP>
        end

        function set.imageMatrix(obj, matrix)
            obj.imageMatrix = matrix;
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
            x = obj.shiftX;
            y = obj.shiftY;

            vertexData = [-1  1  0  1,  0+x  1+y,  0  1 ...
                          -1 -1  0  1,  0+x  0+y,  0  0 ...
                           1  1  0  1,  1+x  1+y,  1  1 ...
                           1 -1  0  1,  1+x  0+y,  1  0];

            obj.vbo.uploadData(single(vertexData));

            obj.needToUpdateVertexBuffer = false;
        end

        function updateTexture(obj)
            image = obj.imageMatrix;
            if size(image, 3) == 1
                image = repmat(image, 1, 1, 3);
            end

            obj.texture.setSubImage(image);

            minFunc = obj.minFunction;
            if minFunc == GL.LINEAR_MIPMAP_LINEAR ...
                || minFunc == GL.LINEAR_MIPMAP_NEAREST ...
                || minFunc == GL.NEAREST_MIPMAP_NEAREST ...
                || minFunc == GL.NEAREST_MIPMAP_LINEAR ...

                obj.texture.generateMipmap();
            end

            obj.needToUpdateTexture = false;
        end

    end

end
