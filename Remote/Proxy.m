classdef Proxy < handle
    
    properties
        client
        name
    end
    
    methods
        
        function obj = Proxy(client, name)
            obj.client = client;
            obj.name = name;
        end
        
        function varargout = subsref(obj, S)
            obj.client.request('eval', 'clear varargout');
            
            if length(S) > 1
                obj.client.request('put', 'varargin', S(2).subs);
                obj.client.request('eval', ['[varargout{1:' num2str(nargout) '}] = ' obj.name '.' S(1).subs '(varargin{:})']);
            else
                obj.client.request('eval', ['[varargout{1:' num2str(nargout) '}] = ' obj.name '.' S(1).subs]);
            end
            
            varargout = obj.client.request('get', 'varargout');
            varargout = varargout{2};
        end
        
    end
    
end