classdef Grating < Stimulus
    
    properties
        position = [0, 0]
        size = [100, 100]
        orientation = 0
        color = 1
        opacity = 1
        contrast = 1
        phase = 0           % degrees
        spatialFreq = 1/100 % cycles/pixels
    end
    
    properties (Access = private)
        type
        mask
        resolution
        vbo
        vao
        texture
    end
    
    methods
        
        function obj = Grating(type, mask, resolution)
            if nargin < 1
                type = 'sine';
            end
            
            if nargin < 2
                mask = [];
            end
            
            if nargin < 3
                resolution = 512;
            end
            
            if ~strcmp(type, 'sine') && ~strcmp(type, 'square')
                error('Unknown type');
            end
            
            obj.type = type;
            obj.mask = mask;
            obj.resolution = resolution;
        end
        
        function init(obj, canvas)
            init@Stimulus(obj, canvas);
            
            if ~isempty(obj.mask)
                obj.mask.init(canvas);
            end
            
            % Each vertex position is followed by a texture coordinate.
            vertexData = [-1  1  0  1,  0  1 ...
                          -1 -1  0  1,  0  0 ...
                           1  1  0  1,  1  1 ...
                           1 -1  0  1,  1  0];
            
            obj.vbo = VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);
            
            obj.vao = VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 6*4, 0);
            obj.vao.setAttribute(obj.vbo, 1, 2, GL.FLOAT, GL.FALSE, 6*4, 4*4);
            
            image = zeros(1, obj.resolution, 4, 'uint8');
            
            switch obj.type
                case 'sine'
                    width = obj.size(1);
                    step = width / obj.resolution;
                    pedestal = 0.5;
                    wave = sin(2 * pi * obj.spatialFreq * (0:step:width-step) + (obj.phase / 180 * pi)) * 0.5 * obj.contrast + pedestal;
                    wave = wave * 255;
                    image(:, :, 1:3) = [wave; wave; wave]';
                    image(:, :, 4) = 255;
                case 'square'
                    width = obj.size(1);
                    step = width / obj.resolution;
                    pedestal = 0.5;
                    wave = sin(2 * pi * obj.spatialFreq * (0:step:width-step) + (obj.phase / 180 * pi)) * 0.5 * obj.contrast + pedestal;
                    wave(wave > 0.5) = 1;
                    wave(wave <= 0.5) = 0;
                    wave = wave * 255;
                    image(:, :, 1:3) = [wave; wave; wave]';
                    image(:, :, 4) = 255;
            end
            
            % TODO: Anything gained by making this a 1D texture?
            obj.texture = TextureObject(canvas, 2);
            obj.texture.setWrapModeS(GL.REPEAT);
            obj.texture.setWrapModeT(GL.REPEAT);
            obj.texture.setImage(image);
        end
        
        function draw(obj)
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

