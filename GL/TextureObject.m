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
            glTexParameteri(obj.target, GL.TEXTURE_BASE_LEVEL, 0);
            glTexParameteri(obj.target, GL.TEXTURE_MAX_LEVEL, 0);
            glTexParameteri(obj.target, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
            glTexParameteri(obj.target, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
            glTexParameteri(obj.target, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
            glTexParameteri(obj.target, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
            glBindTexture(obj.target, 0);
            
            obj.handle = tex;
        end
        
        function setImage(obj, image, level)
            if nargin < 3
                level = 0;
            end
            
            [pixelFormat, pixelDatatype, internalFormat] = getFormatAndType(image);
            
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
                    glTexImage1D(obj.target, level, internalFormat, width, 0, pixelFormat, pixelDatatype, data);
                case GL.TEXTURE_2D
                    glTexImage2D(obj.target, level, internalFormat, width, height, 0, pixelFormat, pixelDatatype, data);
            end
            
            glBindTexture(obj.target, 0);
        end
        
        function setSubImage(obj, image, level, offset)
            if nargin < 3
                level = 0;
            end
            
            if nargin < 4
                offset = [0, 0];
            end
            
            [pixelFormat, pixelDatatype] = getFormatAndType(image);
            
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
                    glTexSubImage1D(obj.target, level, offset(1), width, pixelFormat, pixelDatatype, data);
                case GL.TEXTURE_2D
                    glTexSubImage2D(obj.target, level, offset(1), offset(2), width, height, pixelFormat, pixelDatatype, data);
            end
            
            glBindTexture(obj.target, 0);
        end
        
        function generateMipmap(obj)
            obj.canvas.makeCurrent();
            glBindTexture(obj.target, obj.handle);
            glTexParameteri(obj.target, GL.TEXTURE_MAX_LEVEL, 1000);
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

function [pixelFormat, pixelDatatype, internalFormat] = getFormatAndType(image)
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

    internalFormat = [];
    if pixelFormat == GL.RGBA
        if pixelDatatype == GL.UNSIGNED_BYTE
            internalFormat = GL.RGBA8;
        end
    end
    
    if isempty(internalFormat)
        error('Cannot match to an internal format');
    end
end