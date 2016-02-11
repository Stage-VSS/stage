classdef Lcr4500 < handle
    
    properties (SetAccess = private)
        monitor
    end
    
    properties (Constant)
        NATIVE_RESOLUTION = [912, 1140];
        MIN_PATTERN_BIT_DEPTH = 1
        MAX_PATTERN_BIT_DEPTH = 8
    end
    
    properties (Constant, Access = private)
        LEDS = {'none', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white'} % increasing bit order
        MIN_EXPOSURE_PERIODS = [235, 700, 1570, 1700, 2000, 2500, 4500, 8333] % increasing bit depth order, us
        NUM_BIT_PLANES = 24
    end
    
    methods
        
        function obj = Lcr4500(monitor)
            obj.monitor = monitor;
        end
        
        function delete(obj)
            obj.disconnect();
        end
        
        function connect(obj) %#ok<MANU>
            nRetry = 5;
            for i = 1:nRetry
                try
                    lcrOpen();
                    break;
                catch x
                    lcrClose();
                    if i == nRetry
                        rethrow(x);
                    end
                end
            end
        end
        
        function disconnect(obj) %#ok<MANU>
            lcrClose();
        end
        
        function m = getMode(obj) %#ok<MANU>
            m = stage.builtin.extras.LcrMode(lcrGetMode());
        end
        
        function setMode(obj, mode) %#ok<INUSL>
            lcrSetMode(logical(mode));
        end
        
        function [auto, red, green, blue] = getLedEnables(obj) %#ok<MANU>
            [auto, red, green, blue] = lcrGetLedEnables();
        end
        
        function setLedEnables(obj, auto, red, green, blue) %#ok<INUSL>
            lcrSetLedEnables(auto, red, green, blue);
        end
        
        function [red, green, blue] = getLedCurrents(obj) %#ok<MANU>
            [red, green, blue] = lcrGetLedCurrents();
            red = 255 - red;
            green = 255 - green;
            blue = 255 - blue;
        end
        
        function setLedCurrents(obj, red, green, blue) %#ok<INUSL>
            if red < 0 || red > 255 || green < 0 || green > 255 || blue < 0 || blue > 255
                error('Current must be between 0 and 255');
            end
            
            lcrSetLedCurrents(255 - red, 255 - green, 255 - blue);
        end
        
        function setImageOrientation(obj, northSouthFlipped, eastWestFlipped) %#ok<INUSL>
            lcrSetShortAxisImageFlip(northSouthFlipped);
            lcrSetLongAxisImageFlip(eastWestFlipped);
        end
        
        function r = currentPatternRate(obj)
            [~, ~, numPatterns] = obj.getPatternAttributes();
            r = numPatterns * obj.monitor.refreshRate;
        end
        
        function n = maxNumPatternsForBitDepth(obj, bitDepth)
            n = floor(min(obj.NUM_BIT_PLANES / bitDepth, 1/obj.monitor.refreshRate/(obj.MIN_EXPOSURE_PERIODS(bitDepth) * 1e-6)));
        end
        
        function setPatternAttributes(obj, bitDepth, color, numPatterns)
            maxNumPatterns = obj.maxNumPatternsForBitDepth(bitDepth);
            
            if nargin < 4 || isempty(numPatterns)
                numPatterns = maxNumPatterns;
            end
            
            if numPatterns > maxNumPatterns
                error(['The number of patterns must be less than or equal to ' num2str(maxNumPatterns)]);
            end
            
            if obj.getMode() ~= stage.builtin.extras.LcrMode.PATTERN
                error('Must be in pattern mode to set pattern attributes');
            end
            
            if bitDepth < obj.MIN_PATTERN_BIT_DEPTH || bitDepth > obj.MAX_PATTERN_BIT_DEPTH
                error(['Bit depth must be between ' num2str(obj.MIN_PATTERN_BIT_DEPTH) ' and ' num2str(obj.MAX_PATTERN_BIT_DEPTH)]);
            end
            
            % Color to LED selection.
            index = cellfun(@(c)strncmpi(c, color, length(color)), obj.LEDS);
            if ~any(index)
                error('Unknown color');
            end
            ledSelect = find(index, 1, 'first') - 1;
            
            % Stop the current pattern sequence.
            lcrPatternDisplay(0);
            
            % Clear locally stored pattern LUT.
            lcrClearPatLut();
            
            % Create new pattern LUT.
            for i = 1:numPatterns
                if i == 1
                    trigType = 1; % external positive
                    bufSwap = true;
                else
                    trigType = 3; % no trigger
                    bufSwap = false;
                end
                
                patNum = i - 1;
                invertPat = false;
                insertBlack = false;
                trigOutPrev = false;
                
                lcrAddToPatLut(trigType, patNum, bitDepth, ledSelect, invertPat, insertBlack, bufSwap, trigOutPrev);
            end
            
            % Set pattern display data to stream through 24-bit RGB external interface.
            lcrSetPatternDisplayMode(true);
            
            % Set the sequence to repeat.
            lcrSetPatternConfig(numPatterns, true, numPatterns, 0);
            
            % Calculate and set the necessary pattern exposure period.
            vsyncPeriod = 1 / obj.monitor.refreshRate * 1e6; % us
            exposurePeriod = vsyncPeriod / numPatterns;
            lcrSetExposureFramePeriod(exposurePeriod, exposurePeriod);
            
            % Set the pattern sequence to trigger on vsync.
            lcrSetPatternTriggerMode(false);
            
            % Send pattern LUT to device.
            lcrSendPatLut();
            
            % Validate the pattern LUT.
            status = lcrValidatePatLutData();
            if status == 1 || status == 3
                error('Error validating pattern sequence');
            end
            
            % Start the pattern sequence.
            lcrPatternDisplay(2);
        end
        
        function [bitDepth, color, numPatterns] = getPatternAttributes(obj)
            if obj.getMode() ~= stage.builtin.extras.LcrMode.PATTERN
                error('Must be in pattern mode to get pattern attributes');
            end
            
            % Check all patterns for a consistent bit depth and color.
            [~, ~, bitDepth, ledSelect] = lcrGetPatLutItem(0);
            numPatterns = lcrGetPatternConfig();
            for i = 2:numPatterns
                [~, ~, d, l] = lcrGetPatLutItem(i - 1);
                
                if d ~= bitDepth
                    error('Nonhomogeneous bit depth');
                end
                
                if l ~= ledSelect
                    error('Nonhomogenenous color');
                end
            end
            
            % LED selection to color.
            color = obj.LEDS{ledSelect + 1};
        end
        
    end
    
end 