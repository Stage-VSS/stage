% A movie player stimulus capable of playing a wide variety of video formats (see libavcodec). Sound is not supported.

classdef Movie < Stimulus
    
    properties
        position = [0, 0]       % Center position on the canvas [x, y] (pixels)
        size = [100, 100]       % Size [width, height] (pixels)
        orientation = 0         % Orientation (degrees)
        color = [1, 1, 1]       % Color multiplier as single value or [R, G, B] (real number)
        opacity = 1             % Opacity (0 to 1)
    end
    
    properties (Access = private)
        filename        % Movie filename
        preloading      % Preloading setting
        frameByFrame    % Frame-by-frame playback setting
        mask            % Stimulus mask
        filter          % Stimulus filter
        minFunction     % Texture minifying function
        magFunction     % Texture magnification function
        wrapModeS       % Wrap mode for texture coordinate s (i.e. x)
        wrapModeT       % Wrap mode for texture coordinate t (i.e. y)
        vbo             % Vertex buffer object
        vao             % Vertex array object
        texture         % Frame texture
        player          % Video player
    end
    
    methods
        
        % Constructs a movie stimulus using the movie with the specified filename. The filename should contain a
        % relative or complete file path if the movie is not in the current working directory.
        function obj = Movie(filename)            
            obj.filename = filename;
            obj.preloading = false;
            obj.frameByFrame = false;
            obj.minFunction = GL.LINEAR;
            obj.magFunction = GL.LINEAR;
            obj.wrapModeS = GL.REPEAT;
            obj.wrapModeT = GL.REPEAT;
        end
        
        % Specifies if the entire movie should be loaded into memory during initialization. Preloading can improve
        % playback performance at the cost of increased initialization time and RAM usage.
        function setPreloading(obj, tf)
            obj.preloading = tf;
        end
        
        % Specifies if the movie should play frame-by-frame. In frame-by-frame mode the movie will advance one frame per 
        % draw irrespective of the movie's frame rate.
        function setFrameByFramePlayback(obj, tf)
            obj.frameByFrame = tf;
        end
        
        % Assigns a mask to the stimulus.
        function setMask(obj, mask)
            obj.mask = mask;
        end
        
        % Assigns a filter to the stimulus.
        function setFilter(obj, filter)
            obj.filter = filter;
        end
        
        % Sets the OpenGL minifying function for the movie (GL.NEAREST, GL.LINEAR, GL.NEAREST_MIPMAP_NEAREST, etc).
        function setMinFunction(obj, func)
            obj.minFunction = func;
        end
        
        % Sets the OpenGL magnification function for the movie (GL.NEAREST or GL.LINEAR).
        function setMagFunction(obj, func)
            obj.magFunction = func;
        end
        
        % Sets the OpenGL S (i.e. X) coordinate wrap mode for the movie (GL.CLAMP_TO_EDGE, GL.MIRRORED_REPEAT, GL.REPEAT, etc).
        function setWrapModeS(obj, mode)
            obj.wrapModeS = mode;
        end
        
        % Sets the OpenGL T (i.e. Y) coordinate wrap mode for the movie (GL.CLAMP_TO_EDGE, GL.MIRRORED_REPEAT, GL.REPEAT, etc).
        function setWrapModeT(obj, mode)
            obj.wrapModeT = mode;
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
            
            source = VideoSource(obj.filename);
            if obj.preloading
                source.preload();
            end
            obj.player = VideoPlayer(source);
            
            obj.texture = TextureObject(canvas, 2);
            obj.texture.setWrapModeS(obj.wrapModeS);
            obj.texture.setWrapModeT(obj.wrapModeT);
            obj.texture.setMinFunction(obj.minFunction);
            obj.texture.setMagFunction(obj.magFunction);
            obj.texture.setImage(zeros(source.size(2), source.size(1), 3, 'uint8'));
        end
        
        function draw(obj)            
            frame = obj.player.getImage();
            if ~isempty(frame)
                obj.texture.setSubImage(frame);
            end
            
            if ~obj.player.isPlaying
                obj.player.play(obj.frameByFrame);
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
        
    end
    
end