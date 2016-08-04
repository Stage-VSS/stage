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
        
        function drawArray(obj, array, mode, first, count, color, texture, mask, filter, pedestal)
            c = mean(color(1:3));
            if c > 1
                c = 1;
            elseif c < 0
                c = 0;
            end
            
            p = mean(pedestal(1:3));
            if p > 1
                p = 1;
            elseif p < 0
                p = 0;
            end
            
            % Expand color/pedestal to range of pattern bit depth.
            patternColor = round(c * (2^obj.patternBitDepth - 1));
            patternPedestal = round(p * (2^obj.patternBitDepth - 1));
            
            % Shift pattern color/pedestal into pattern index position.
            patternColor = bitshift(patternColor, obj.patternIndex * obj.patternBitDepth);
            patternPedestal = bitshift(patternPedestal, obj.patternIndex * obj.patternBitDepth);
            
            % Split shifted pattern color into GRB components.
            bitMask = 2 ^ obj.colorBitDepth - 1;
            cg = bitand(bitshift(patternColor, -0 * obj.colorBitDepth), bitMask);
            cr = bitand(bitshift(patternColor, -1 * obj.colorBitDepth), bitMask);
            cb = bitand(bitshift(patternColor, -2 * obj.colorBitDepth), bitMask);
            
            pg = bitand(bitshift(patternPedestal, -0 * obj.colorBitDepth), bitMask);
            pr = bitand(bitshift(patternPedestal, -1 * obj.colorBitDepth), bitMask);
            pb = bitand(bitshift(patternPedestal, -2 * obj.colorBitDepth), bitMask);
            
            % Normalize and combine.
            cg = cg / bitMask;
            cr = cr / bitMask;
            cb = cb / bitMask;
            color = [cr, cg, cb, color(4)];
            
            pg = pg / bitMask;
            pr = pr / bitMask;
            pb = pb / bitMask;
            pedestal = [pr, pg, pb];
            
            drawArray@stage.core.Renderer(obj, array, mode, first, count, color, texture, mask, filter, pedestal);
        end
        
        function resetPatternIndex(obj)
            obj.patternIndex = 0;
        end
        
        function incrementPatternIndex(obj)
            obj.patternIndex = rem(obj.patternIndex + 1, obj.numPatterns);
        end
        
    end
    
end