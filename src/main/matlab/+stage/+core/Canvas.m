classdef Canvas < handle

    properties (SetAccess = private)
        window              % Window containing the canvas
        size                % Size of the canvas [width, height] (pixels)
        width               % Width of the canvas, for convenience (pixels)
        height              % Height of the canvas, for convenience (pixels)
        projection          % Projection matrix stack
        modelView           % Model/View matrix stack
        currentRenderer     % Current primitive renderer
        standardPrograms    % Standard shader programs available for renderers
    end

    properties (Access = private)
        defaultRenderer         % Renderer used when none is explicitly set
        framebufferBound        % Is a framebuffer set? (true or false)
    end

    methods

        function obj = Canvas(window, varargin)
            ip = inputParser();
            ip.addParameter('disableDwm', true);
            ip.parse(varargin{:});

            obj.window = window;

            obj.projection = stage.core.gl.MatrixStack();
            obj.projection.orthographic(0, window.size(1), 0, window.size(2));
            obj.modelView = stage.core.gl.MatrixStack();

            obj.defaultRenderer = stage.core.Renderer();
            obj.resetRenderer();

            obj.standardPrograms = stage.core.shaders.StandardPrograms(obj);
            obj.framebufferBound = false;
            obj.resetBlend();

            % On Windows Vista+ the desktop window manager (DWM) must be disabled to avoid timing and performance issues.
            v = java.lang.System.getProperty('os.version');
            if ispc && str2double(v.charAt(0)) >= 6 && ip.Results.disableDwm
                DwmEnableComposition(DWM.DWM_EC_DISABLECOMPOSITION);
                if DwmIsCompositionEnabled()
                    warning('Unable to disable DWM. You will experience timing and performance issues.');
                end
            end

            glfwSwapInterval(1);
        end

        function s = get.size(obj)
            s = obj.window.size;
        end

        function w = get.width(obj)
            w = obj.size(1);
        end

        function h = get.height(obj)
            h = obj.size(2);
        end

        function makeCurrent(obj)
            glfwMakeContextCurrent(obj.window.handle);
        end

        function setClearColor(obj, color)
            obj.makeCurrent();

            c = color;
            if length(c) == 1
                c = [c, c, c, 1];
            elseif length(c) == 3
                c = [c, 1];
            end
            glClearColor(c(1), c(2), c(3), c(4));
        end

        function clear(obj)
            obj.makeCurrent();
            glClear(GL.COLOR_BUFFER_BIT);
        end
        
        function resetProjection(obj)
            obj.projection = stage.core.gl.MatrixStack();
            obj.projection.orthographic(0, obj.window.size(1), 0, obj.window.size(2));
        end

        function setProgram(obj, program)
            obj.makeCurrent();
            glUseProgram(program.handle);
        end

        function enableBlend(obj, src, dest)
            obj.makeCurrent();
            glEnable(GL.BLEND);
            glBlendFunc(src, dest);
        end

        function disableBlend(obj)
            obj.makeCurrent();
            glDisable(GL.BLEND);
        end

        function resetBlend(obj)
            obj.enableBlend(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
        end
        
        function d = getPixelData(obj, x, y, width, height, permuteImage)
            % Gets image matrix of current framebuffer data.
            
            if nargin < 2
                x = 0;
            end

            if nargin < 3
                y = 0;
            end

            if nargin < 4
                width = obj.size(1);
            end

            if nargin < 5
                height = obj.size(2);
            end

            if nargin < 6
                permuteImage = true;
            end

            obj.makeCurrent();

            if ~obj.framebufferBound
                glReadBuffer(GL.BACK);
            end

            d = glReadPixels(x, y, width, height, GL.RGB, GL.UNSIGNED_BYTE);

            if permuteImage
                d = flip(permute(d, [3, 2, 1]), 1);
            end
        end

        function setFramebuffer(obj, drawBuffer, readBuffer)
            if nargin < 3
                readBuffer = [];
            end

            if drawBuffer.canvas ~= obj || (~isempty(readBuffer) && readBuffer.canvas ~= obj)
                error('Buffer canvas must equal this canvas');
            end

            drawBuffer.checkFramebufferComplete();
            drawBuffer.bindFramebuffer(true);

            if ~isempty(readBuffer)
                readBuffer.checkFramebufferComplete();
                readBuffer.bindFramebuffer(false);
            end

            obj.framebufferBound = true;
        end

        function resetFramebuffer(obj)
            obj.makeCurrent();

            glBindFramebuffer(GL.FRAMEBUFFER, 0);
            glBindFramebuffer(GL.READ_FRAMEBUFFER, 0);

            glDrawBuffer(GL.BACK);
            glReadBuffer(GL.BACK);

            obj.framebufferBound = false;
        end

        function setRenderer(obj, renderer)
            obj.currentRenderer = renderer;
            obj.currentRenderer.init(obj);
        end

        function resetRenderer(obj)
            obj.setRenderer(obj.defaultRenderer);
        end

        function drawArray(obj, array, mode, first, count, color, mask, texture, filter)
            if nargin < 7
                mask = [];
            end

            if nargin < 8
                texture = [];
            end

            if nargin < 9
                filter = [];
            end

            obj.currentRenderer.projection.setMatrix(obj.projection.top());
            obj.currentRenderer.modelView.setMatrix(obj.modelView.top());

            obj.currentRenderer.drawArray(array, mode, first, count, color, mask, texture, filter);
        end

    end

end
