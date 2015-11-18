classdef BasicNetEvents < stage.core.network.NetEvents
    
    properties (Constant)
        %% Client to server:
        % Requests the current canvas size.
        GET_CANVAS_SIZE = 'GET_CANVAS_SIZE'
        
        % Requests a new canvas color.
        SET_CANVAS_CLEAR_COLOR = 'SET_CANVAS_CLEAR_COLOR'
        
        % Requests the current monitor refresh rate.
        GET_MONITOR_REFRESH_RATE = 'GET_MONITOR_REFRESH_RATE'
        
        % Requests the current monitor resolution.
        GET_MONITOR_RESOLUTION = 'GET_MONITOR_RESOLUTION'
        
        % Requests the current red, green, and blue gamma ramp.
        GET_MONITOR_GAMMA_RAMP = 'GET_MONITOR_GAMMA_RAMP'
        
        % Requests a new red, green, and blue gamma ramp.
        SET_MONITOR_GAMMA_RAMP = 'SET_MONITOR_GAMMA_RAMP'
        
        % Requests that a presentation be played asynchronously.
        PLAY_ASYNC = 'PLAY_ASYNC'
        
        % Requests information about the last played presentation.
        GET_PLAY_INFO = 'GET_PLAY_INFO'
        
        % Requests that all current data be cleared out of the server memory.
        CLEAR_DATA = 'CLEAR_DATA'
    end
    
end

