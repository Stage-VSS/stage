classdef PrerenderedPlayer < Player
    
    properties (Access = private)
        frameBuffer
    end
    
    methods
        
        function obj = PrerenderedPlayer(presentation)
            obj = obj@Player(presentation);
        end
        
        function info = play(obj, canvas)
            obj.prerender(canvas);
            info = obj.replay(canvas);
        end
        
        function prerender(obj, canvas)
            frameRate = canvas.window.monitor.refreshRate;
            nFrames = floor(obj.presentation.duration * frameRate) + 1;
            
            obj.frameBuffer = zeros(canvas.size(2), canvas.size(1), 3, nFrames, 'uint8');
            
            for i = 1:length(obj.presentation.stimuli)
                obj.presentation.stimuli{i}.init(canvas);
            end
            
            frame = 0;
            frameDuration = 1 / canvas.window.monitor.refreshRate;
            time = frame * frameDuration;
            while time <= obj.presentation.duration
                canvas.clear();
                
                obj.drawFrame(frame, frameDuration, time);
                
                obj.frameBuffer(:,:,:,frame+1) = canvas.getPixelData();
                
                frame = frame + 1;
                time = frame * frameDuration;
            end
        end
        
        function info = replay(obj, canvas)            
            flipTimer = FlipTimer();
            
            % Each vertex position is followed by a texture coordinate and a mask coordinate.
            w = canvas.size(1);
            h = canvas.size(2);
            vertexData = [ 0  h  0  1,  0  1,  0  1 ...
                           0  0  0  1,  0  0,  0  0 ...
                           w  h  0  1,  1  1,  1  1 ...
                           w  0  0  1,  1  0,  1  0];

            vbo = VertexBufferObject(canvas, GL.ARRAY_BUFFER, single(vertexData), GL.STATIC_DRAW);

            vao = VertexArrayObject(canvas);
            vao.setAttribute(vbo, 0, 4, GL.FLOAT, GL.FALSE, 8*4, 0);
            vao.setAttribute(vbo, 1, 2, GL.FLOAT, GL.FALSE, 8*4, 4*4);
            vao.setAttribute(vbo, 2, 2, GL.FLOAT, GL.FALSE, 8*4, 6*4);

            texture = TextureObject(canvas, 2);
            texture.setImage(obj.frameBuffer(:,:,:,1));
            
            currentRenderer = canvas.currentRenderer;
            canvas.resetRenderer();
            
            canvas.projection.push();
            canvas.projection.setIdentity();
            canvas.projection.orthographic(0, canvas.size(1), 0, canvas.size(2));

            nFrames = size(obj.frameBuffer, 4);
            for frame = 1:nFrames
                canvas.clear();
                
                texture.setSubImage(obj.frameBuffer(:,:,:,frame));
                canvas.drawArray(vao, GL.TRIANGLE_STRIP, 0, 4, [1, 1, 1, 1], [], texture);

                canvas.window.flip();
                flipTimer.tick();
            end
            
            canvas.projection.pop();
            
            canvas.setRenderer(currentRenderer);

            info.flipDurations = flipTimer.flipDurations;
        end
        
    end
    
end