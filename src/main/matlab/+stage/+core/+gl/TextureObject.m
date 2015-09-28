classdef TextureObject < handle
    
    properties (SetAccess = private)
        size
        target
        handle
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
        
        function setImage(obj, image, level, permuteImage)
            if nargin < 3
                level = 0;
            end
            
            if nargin < 4
                permuteImage = true;
            end
            
            if permuteImage
                glImage = permute(flipdim(image, 1), [3, 2, 1]);
            else
                glImage = image;                
            end
            
            [pixelFormat, pixelDatatype, internalFormat] = getFormatAndType(glImage);
            width = size(glImage, 2);
            height = size(glImage, 3);
            
            obj.canvas.makeCurrent();
            glBindTexture(obj.target, obj.handle);
            
            glPixelStorei(GL.UNPACK_ALIGNMENT, 1);
            
            switch obj.target
                case GL.TEXTURE_1D
                    if height ~= 1
                        error('1D textures must have a height of 1');
                    end
                    glTexImage1D(obj.target, level, internalFormat, width, 0, pixelFormat, pixelDatatype, glImage);
                case GL.TEXTURE_2D
                    glTexImage2D(obj.target, level, internalFormat, width, height, 0, pixelFormat, pixelDatatype, glImage);
            end
            
            if level == 0
                obj.size = [width, height];
            end
            
            glBindTexture(obj.target, 0);
        end
        
        function setSubImage(obj, image, level, offset, permuteImage)
            if nargin < 3
                level = 0;
            end
            
            if nargin < 4
                offset = [0, 0];
            end
            
            if nargin < 5
                permuteImage = true;
            end
            
            if permuteImage
                glImage = permute(flipdim(image, 1), [3, 2, 1]);
            else
                glImage = image;                
            end
            
            [pixelFormat, pixelDatatype] = getFormatAndType(glImage);
            width = size(glImage, 2);
            height = size(glImage, 3);
            
            obj.canvas.makeCurrent();
            glBindTexture(obj.target, obj.handle);
            
            glPixelStorei(GL.UNPACK_ALIGNMENT, 1);
            
            switch obj.target
                case GL.TEXTURE_1D
                    if height ~= 1
                        error('1D textures must have a height of 1');
                    end
                    glTexSubImage1D(obj.target, level, offset(1), width, pixelFormat, pixelDatatype, glImage);
                case GL.TEXTURE_2D
                    glTexSubImage2D(obj.target, level, offset(1), offset(2), width, height, pixelFormat, pixelDatatype, glImage);
            end
            
            glBindTexture(obj.target, 0);
        end
        
        function d = getPixelData(obj, level)
            if nargin < 2
                level = 0;
            end
            
            obj.canvas.makeCurrent();
            glBindTexture(obj.target, obj.handle);
            
            d = glGetTexImage(obj.target, level, GL.RGBA, GL.UNSIGNED_BYTE);
            d = flipdim(permute(d, [2, 3, 1]), 1);
            
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
        
        function setMinFunction(obj, func)
            obj.canvas.makeCurrent();
            glBindTexture(obj.target, obj.handle);
            glTexParameteri(obj.target, GL.TEXTURE_MIN_FILTER, func);
            glBindTexture(obj.target, 0);
        end
        
        function setMagFunction(obj, func)
            obj.canvas.makeCurrent();
            glBindTexture(obj.target, obj.handle);
            glTexParameteri(obj.target, GL.TEXTURE_MAG_FILTER, func);
            glBindTexture(obj.target, 0);
        end
        
        function delete(obj)
            if isvalid(obj.canvas)
                obj.canvas.makeCurrent();
                glDeleteTextures(1, obj.handle);
            end
        end
        
    end
    
end

function [pixelFormat, pixelDatatype, internalFormat] = getFormatAndType(glImage)
    switch size(glImage, 1)
        case 1
            pixelFormat = GL.RED;
        case 3
            pixelFormat = GL.RGB;
        case 4
            pixelFormat = GL.RGBA;
        otherwise
            error('Unsupported pixel format');
    end

    switch class(glImage)
        case 'uint8'
            pixelDatatype = GL.UNSIGNED_BYTE;
        case 'single'
            pixelDatatype = GL.FLOAT;
        otherwise
            error('Unsupported pixel datatype');
    end
    
    internalFormat = [];
    switch pixelDatatype
        case GL.UNSIGNED_BYTE
            switch pixelFormat
                case GL.RED
                    internalFormat = GL.R8;
                case GL.RGB
                    internalFormat = GL.RGB8;
                case GL.RGBA
                    internalFormat = GL.RGBA8;
            end
        case GL.FLOAT
            switch pixelFormat
                case GL.RED
                    internalFormat = GL.R32F;
                case GL.RGB
                    internalFormat = GL.RGB32F;
                case GL.RGBA
                    internalFormat = GL.RGBA32F;
            end
    end           
    
    if isempty(internalFormat)
        error('Cannot match to an internal format');
    end
end