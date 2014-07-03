classdef NetEvents
    
    properties (Constant)
        %% Client to server:
        % Requests the current canvas size.
        GET_CANVAS_SIZE = 'GET_CANVAS_SIZE'
        
        % Request a new canvas color.
        SET_CANVAS_COLOR = 'SET_CANVAS_COLOR'
        
        % Requests the current monitor refresh rate.
        GET_MONITOR_REFRESH_RATE = 'GET_MONITOR_REFRESH_RATE'
        
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