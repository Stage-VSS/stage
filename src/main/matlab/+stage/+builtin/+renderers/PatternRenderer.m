classdef PatternRenderer < stage.core.Renderer
    % A renderer that draws primitives into a subset of color bits depending on the current pattern index.
    
    properties
        numPatterns
        patternBitDepth
        colorBitDepth
    end
    
    properties (Access = private)
        patternIndex
    end
    
    methods
        
        function obj = PatternRenderer(numPatterns, patternBitDepth, colorBitDepth)
            if nargin < 3
                colorBitDepth = 8;
            end
            
            obj = obj@stage.core.Renderer();
            
            obj.numPatterns = numPatterns;
            obj.patternBitDepth = patternBitDepth;
            obj.colorBitDepth = colorBitDepth;
            obj.patternIndex = 0;
        end
        
        function drawArray(obj, array, mode, first, count, color, texture, mask, filter)
            c = mean(color(1:3));
            if c > 1
                c = 1;
            elseif c < 0
                c = 0;
            end
            
            % Expand color to range of pattern bit depth.
            patternColor = round(c * (2^obj.patternBitDepth - 1));
            
            % Shift pattern color into pattern index position.
            patternColor = bitshift(patternColor, obj.patternIndex * obj.patternBitDepth);
            
            % Split shifted pattern color into GRB components.
            bitMask = 2 ^ obj.colorBitDepth - 1;
            g = bitand(bitshift(patternColor, -0 * obj.colorBitDepth), bitMask);
            r = bitand(bitshift(patternColor, -1 * obj.colorBitDepth), bitMask);
            b = bitand(bitshift(patternColor, -2 * obj.colorBitDepth), bitMask);
            
            % Normalize and combine.
            g = g / bitMask;
            r = r / bitMask;
            b = b / bitMask;
            color = [r, g, b, color(4)];
            
            drawArray@stage.core.Renderer(obj, array, mode, first, count, color, texture, mask, filter);
        end
        
        function resetPatternIndex(obj)
            obj.patternIndex = 0;
        end
        
        function incrementPatternIndex(obj)
            obj.patternIndex = rem(obj.patternIndex + 1, obj.numPatterns);
        end
        
    end
    
end