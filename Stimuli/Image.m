% An arbitrary image stimulus.

classdef Image < Stimulus
    
    properties
        position = [0, 0]   % Center position on the canvas [x, y] (pixels)
        size = [100, 100]   % Size [width, height] (pixels)
        orientation = 0     % Orientation (degrees)
        color = [1, 1, 1]   % Color multiplier as single value or [R, G, B] (real number)
        opacity = 1         % Opacity (0 to 1)
        shiftX = 0          % Texture shift (scroll) on the x axes (real number; 0 being no shift, 1 being a complete shift)
        shiftY = 0          % Texture shift (scroll) on the y axes (real number; 0 being no shift, 1 being a complete shift)
    end
    
    properties (Access = private)
        matrix                      % Original image matrix
        minFilter                   % Texture minifying function
        magFilter                   % Texture magnification function
        mask                        % Stimulus mask
        filter                      % Stimulus filter
        vbo                         % Vertex buffer object
        vao                         % Vertex array object
        texture                     % Image texture
        needToUpdateVertexBuffer
    end
    
    methods
        
        % Constructs an image stimulus with the specified image matrix data. The image data must be provided as an 
        % M-by-N (grayscale), M-by-N-by-3 (truecolor), or M-by-N-by-4 (truecolor with alpha) matrix.
        %
        % Typical usage:
        % imageData = imread('my_cool_image.png');
        % image = Image(imageData);        
        function obj = Image(matrix)
            if ~isa(matrix, 'uint8')
                error('Matrix must be of class uint8');
            end
            
            obj.matrix = matrix;
            obj.minFilter = GL.LINEAR_MIPMAP_LINEAR;
            obj.magFilter = GL.LINEAR;
        end
        
        % Assigns a mask to the stimulus.
        function setMask(obj, mask)
            obj.mask = mask;
        end
        
        % Assigns a filter to the stimulus.
        function setFilter(obj, filter)
            obj.filter = filter;
        end
        
        % Sets the OpenGL minifying function for the image (GL.NEAREST, GL.LINEAR, GL.NEAREST_MIPMAP_NEAREST, etc).
        function setMinFilter(obj, filter)
            obj.minFilter = filter;
        end
        
        % Sets the OpenGL magnification function for the image (GL.NEAREST or GL.LINEAR).
        function setMagFilter(obj, filter)
            obj.magFilter = filter;
        end
        
        function init(obj, canvas)
            init@Stimulus(obj, canvas);
            
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
            
            obj.vbo = VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);
            
            obj.vao = VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 8*4, 0);
            obj.vao.setAttribute(obj.vbo, 1, 2, GL.FLOAT, GL.FALSE, 8*4, 4*4);
            obj.vao.setAttribute(obj.vbo, 2, 2, GL.FLOAT, GL.FALSE, 8*4, 6*4);
            
            image = obj.matrix;
            if size(image, 3) == 1
                image(:, :, 2) = image(:, :, 1);
                image(:, :, 3) = image(:, :, 1);
            end
            
            obj.texture = TextureObject(canvas, 2);
            obj.texture.setWrapModeS(GL.REPEAT);
            obj.texture.setWrapModeT(GL.REPEAT);
            obj.texture.setMinFilter(obj.minFilter);
            obj.texture.setMagFilter(obj.magFilter);
            obj.texture.setImage(image);
            obj.texture.generateMipmap();
            
            obj.updateVertexBuffer();
        end
        
        function draw(obj)
            if obj.needToUpdateVertexBuffer
                obj.updateVertexBuffer();
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
            
            obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c, obj.texture, obj.mask, obj.filter);
            
            modelView.pop();
        end
        
        function set.shiftX(obj, shiftX)
            obj.shiftX = shiftX;
            obj.needToUpdateVertexBuffer = true; %#ok<MCSUP>
        end
        
        function set.shiftY(obj, shiftY)
            obj.shiftY = shiftY;
            obj.needToUpdateVertexBuffer = true; %#ok<MCSUP>
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
        
    end
    
end