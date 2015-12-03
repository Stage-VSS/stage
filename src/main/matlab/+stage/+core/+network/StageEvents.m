classdef StageEvents
    
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
        
        % Requests that a presentation be played.
        PLAY = 'PLAY'
        
        % Requests that the last played presentation be played again.
        REPLAY = 'REPLAY'
        
        % Requests information about the last played presentation.
        GET_PLAY_INFO = 'GET_PLAY_INFO'
        
        % Requests that the current session data be cleared out of the server memory.
        CLEAR_SESSION_DATA = 'CLEAR_SESSION_DATA'
        
        %% Server to client:
        % The request was completed successfully.
        OK = 'OK'
        
        % An error occurred while executing the request.
        ERROR = 'ERROR'
    end
    
end