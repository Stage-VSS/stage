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
        needToUpdateVertexBuffer
        needToUpdateTexture
    end
    
    methods
        
        function obj = Grating(type, resolution)
            if nargin < 1
                type = 'sine';
            end
            
            if nargin < 2
                resolution = 512;
            end
            
            if ~any(strcmp(type, {'sine', 'square', 'sawtooth'}))
                error('Unknown type');
            end
            
            obj.type = type;
            obj.resolution = resolution;
        end
        
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
            
            obj.vbo = VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.DYNAMIC_DRAW);
            
            obj.vao = VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 8*4, 0);
            obj.vao.setAttribute(obj.vbo, 1, 2, GL.FLOAT, GL.FALSE, 8*4, 4*4);
            obj.vao.setAttribute(obj.vbo, 2, 2, GL.FLOAT, GL.FALSE, 8*4, 6*4);
                        
            % TODO: Anything gained by making this a 1D texture?
            obj.texture = TextureObject(canvas, 2);
            obj.texture.setWrapModeS(GL.REPEAT);
            obj.texture.setImage(zeros(1, obj.resolution, 4, 'uint8'));
            
            obj.updateVertexBuffer();
            obj.updateTexture();
        end
        
        function draw(obj)
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
            
            if isempty(obj.mask)
                obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c, obj.texture);
            else
                obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c, obj.texture, obj.mask);
            end
            
            modelView.pop();
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
            switch obj.type
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