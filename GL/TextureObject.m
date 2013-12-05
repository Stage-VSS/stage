classdef TextureObject < handle
    
    properties (SetAccess = private)
        target
        handle
    end
    
    properties (Access = private)
        canvas
    end
    
    methods
        
        function obj = TextureObject(canvas, dimensions)
            if nargin < 2
                dimensions = 2;
            end
            
            switch dimensions
                case 1
                    obj.target = GL.TEXTURE_1D;
                case 2
                    obj.target = GL.TEXTURE_2D;
                otherwise
                    error('Unsupported dimensions');
            end
            
            obj.canvas = canvas;
            canvas.makeCurrent();
            
            tex = glGenTextures(1);
            glBindTexture(obj.target, tex);
            glTexParameteri(obj.target, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
            glTexParameteri(obj.target, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
            glTexParameteri(obj.target, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
            glTexParameteri(obj.target, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
            glBindTexture(obj.target, 0);
            
            obj.handle = tex;
        end
        
        function setImage(obj, image)
            switch size(image, 3)
                case 4
                    pixelFormat = GL.RGBA;
                otherwise
                    error('Unsupported pixel format');
            end
            
            switch class(image)
                case 'uint8'
                    pixelDatatype = GL.UNSIGNED_BYTE;
                otherwise
                    error('Unsupported pixel datatype');
            end
            
            internalFormat = matchingInternalFormat(pixelFormat, pixelDatatype);
            
            obj.canvas.makeCurrent();
            glBindTexture(obj.target, obj.handle);
            
            width = size(image, 2);
            height = size(image, 1);
            
            data = zeros(4, height, width, 'uint8');
            for i = 1:4
                data(i, :, :) = transpose(flipud(image(:, :, i)));
            end
            
            switch obj.target
                case GL.TEXTURE_1D
                    if height ~= 1
                        error('1D textures must have a height of 1');
                    end
                    glTexImage1D(obj.target, 0, internalFormat, width, 0, pixelFormat, pixelDatatype, data);
                case GL.TEXTURE_2D
                    glTexImage2D(obj.target, 0, internalFormat, width, height, 0, pixelFormat, pixelDatatype, data);
            end
                        
            obj.generateMipmap();
            
            glBindTexture(obj.target, 0);
        end
        
        function generateMipmap(obj)
            obj.canvas.makeCurrent();
            glBindTexture(obj.target, obj.handle);
            glGenerateMipmap(obj.target);
            glBindTexture(obj.target, 0);
        end
        
        function setWrapModeS(obj, mode)
            obj.canvas.makeCurrent();
            glBindTexture(obj.target, obj.handle);
            glTexParameteri(obj.target, GL.TEXTURE_WRAP_S, mode);
            glBindTexture(obj.target, 0);
        end
        
        function setWrapModeT(obj, mode)
            obj.canvas.makeCurrent();
            glBindTexture(obj.target, obj.handle);
            glTexParameteri(obj.target, GL.TEXTURE_WRAP_T, mode);
            glBindTexture(obj.target, 0);
        end
        
        function delete(obj)
            obj.canvas.makeCurrent();
            glDeleteTextures(1, obj.handle);
        end
        
    end
    
end

function f = matchingInternalFormat(pixelFormat, pixelDatatype)
    f = [];
    if pixelFormat == GL.RGBA
        if pixelDatatype == GL.UNSIGNED_BYTE
            f = GL.RGBA8;
        end
    end
    
    if isempty(f)
        error('Cannot match to an internal format');
    end
end