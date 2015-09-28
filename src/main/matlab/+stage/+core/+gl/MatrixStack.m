classdef MatrixStack < handle
    
    properties (Access = private)
        stack
        depth
    end
    
    methods
        
        function obj = MatrixStack()
            obj.stack = zeros(4, 4, 10);
            obj.depth = 1;
            
            obj.setIdentity();
        end
        
        function push(obj)
            obj.stack(:,:,obj.depth+1) = obj.stack(:,:,obj.depth);
            obj.depth = obj.depth + 1;
        end
        
        function pop(obj)
            if obj.depth == 1
                error('Stack underflow');
            end
            obj.depth = obj.depth - 1;
        end
        
        function m = top(obj)
            m = obj.stack(:,:,obj.depth);
        end
        
        function translate(obj, x, y, z)
            t = [1 0 0 x;
                 0 1 0 y;
                 0 0 1 z;
                 0 0 0 1];
            
            obj.stack(:,:,obj.depth) = obj.stack(:,:,obj.depth) * t; 
        end
        
        function rotate(obj, angle, x, y, z)
            c = cosd(angle);
            s = sind(angle);
            r = [  x^2*(1-c)+c x*y*(1-c)-z*s x*z*(1-c)+y*s 0;
                 y*x*(1-c)+z*s   y^2*(1-c)+c y*z*(1-c)-x*s 0;
                 x*z*(1-c)-y*s y*z*(1-c)+x*s   z^2*(1-c)+c 0;
                             0             0             0 1];
                         
            obj.stack(:,:,obj.depth) = obj.stack(:,:,obj.depth) * r;
        end
        
        function scale(obj, x, y, z)
            s = [x 0 0 0;
                 0 y 0 0;
                 0 0 z 0;
                 0 0 0 1];
             
             obj.stack(:,:,obj.depth) = obj.stack(:,:,obj.depth) * s;
        end
        
        function orthographic(obj, left, right, bottom, top, zNear, zFar)
            if nargin < 6
                zNear = -1;
            end
            if nargin < 7
                zFar = 1;
            end
            
            tx = -(right+left)/(right-left);
            ty = -(top+bottom)/(top-bottom);
            tz = -(zFar+zNear)/(zFar-zNear);
            o = [2/(right-left)              0               0 tx;
                              0 2/(top-bottom)               0 ty;
                              0              0 -2/(zFar-zNear) tz;
                              0              0               0  1];
                          
            obj.stack(:,:,obj.depth) = obj.stack(:,:,obj.depth) * o;
        end
        
        function setMatrix(obj, m)
            obj.stack(:,:,obj.depth) = m;
        end
        
        function setIdentity(obj)
            obj.stack(:,:,obj.depth) = [1 0 0 0;
                                        0 1 0 0;
                                        0 0 1 0;
                                        0 0 0 1];
        end
        
    end
    
end