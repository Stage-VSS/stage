classdef Movie < Stimulus
    
    properties
        position = [0, 0]   % Center position on the canvas [x, y] (pixels)
        size = [100, 100]   % Size [width, height] (pixels)
        orientation = 0     % Orientation (degrees)
        color = [1, 1, 1]   % Color multiplier as single value or [R, G, B] (real number)
        opacity = 1         % Opacity (0 to 1)
    end
    
    properties (Access = private)
        filename    % Movie filename
        mask        % Stimulus mask
        vbo         % Vertex buffer object
        vao         % Vertex array object
        texture     % Frame texture
        player      % Video player
    end
    
    methods
        
        % Constructs a movie stimulus using the movie with the specified filename. The filename should contain a
        % relative or complete file path if the movie is not in the current working directory.
        function obj = Movie(filename)            
            obj.filename = filename;
        end
        
        % Assigns a mask to the stimulus.
        function setMask(obj, mask)
            obj.mask = mask;
        end
        
        function init(obj, canvas)
            init@Stimulus(obj, canvas);
            
            if ~isempty(obj.mask)
                obj.mask.init(canvas);
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
            obj.player = VideoPlayer(source);
            
            obj.texture = TextureObject(canvas, 2);
            obj.texture.setImage(zeros(source.size(2), source.size(1), 3, 'uint8'));
        end
        
        function draw(obj)
            if ~obj.player.isPlaying
                obj.player.play();
            end
            
            frame = obj.player.getImage();
            if ~isempty(frame)
                obj.texture.setSubImage(frame);
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
            
            if isempty(obj.mask)
                obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c, obj.texture);
            else
                obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c, obj.texture, obj.mask);
            end
            
            modelView.pop();
        end
        
    end
    
end