classdef MatlabMovie < Stimulus
    
    properties
        position = [0, 0]
        size = [100, 100]
        orientation = 0
        color = [1 1 1]
        opacity = 1
    end
    
    properties (Access = private)
        filename
        mask
        vbo
        vao
        texture
        video
        frameIndex
    end
    
    methods
        
        function obj = MatlabMovie(filename)            
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
            
            reader = VideoReader(obj.filename);
            obj.video = reader.read([1 reader.NumberOfFrames]);
            
            obj.frameIndex = 1;
            
            obj.texture = TextureObject(canvas, 2);
            obj.texture.setImage(obj.video(:,:,:,1));
        end
        
        function draw(obj)
            frame = obj.video(:,:,:,obj.frameIndex);
            
            obj.frameIndex = obj.frameIndex + 1;
            if obj.frameIndex > size(obj.video, 4)
                obj.frameIndex = 1;
            end
            
            obj.texture.setSubImage(frame);
            
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