classdef Image < Stimulus
    
    properties
        position = [0, 0]
        size = [100, 100]
        orientation = 0
        color = [1 1 1]
        opacity = 1
        shiftX = 0
        shiftY = 0
    end
    
    properties (Access = private)
        filename
        mask
        vbo
        vao
        texture
        needToUpdateVertexBuffer
    end
    
    methods
        
        function obj = Image(filename)            
            obj.filename = filename;
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
            
            obj.vbo = VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);
            
            obj.vao = VertexArrayObject(canvas);
            obj.vao.setAttribute(obj.vbo, 0, 4, GL.FLOAT, GL.FALSE, 8*4, 0);
            obj.vao.setAttribute(obj.vbo, 1, 2, GL.FLOAT, GL.FALSE, 8*4, 4*4);
            obj.vao.setAttribute(obj.vbo, 2, 2, GL.FLOAT, GL.FALSE, 8*4, 6*4);
            
            [image, ~, alpha] = imread(obj.filename);
            if ~isa(image, 'uint8')
                error('Unsupported image bitdepth');
            end
            
            if size(image, 3) == 1
                image(:, :, 2) = image(:, :, 1);
                image(:, :, 3) = image(:, :, 1);
            end
            
            if isempty(alpha)
                image(:, :, 4) = 255;
            else
                image(:, :, 4) = alpha;
            end
            
            obj.texture = TextureObject(canvas, 2);
            obj.texture.setWrapModeS(GL.REPEAT);
            obj.texture.setWrapModeT(GL.REPEAT);
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
            
            if isempty(obj.mask)
                obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c, obj.texture);
            else
                obj.canvas.drawArray(obj.vao, GL.TRIANGLE_STRIP, 0, 4, c, obj.texture, obj.mask);
            end
            
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