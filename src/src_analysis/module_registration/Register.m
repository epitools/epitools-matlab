function R = Register(A,B,Ang,X,Y,mode)
% Register [1 line description ]
%
% IN: 
%   A - 
%   B - 
%   Ang - 
%   X -
%   Y -
%   mode - 
%
% OUT: 
%   R - 
%
% Author:
% Copyright:
                                                                           % add sections & comments
    if nargin < 6 
        mode = 'optimised';
    end
    
    R.X = X;
    R.Y = Y;
    R.Ang = Ang;
    
    if strcmp(mode , 'surface')
        R.S = zeros([length(Ang),length(X),length(Y)]);
        for i=1:length(Ang)
            [A2,B2] = RotateAndCrop(A,B,Ang(i));
            R.S(i,:,:) = Explore(A2,B2, X,Y);
        end
        
    else
        
        R.S(1,:,:) = Explore(A,B, X,Y);
        S =permute(R.S,[2,3,1]);
        Uy = min(S);            Ux = min(S,[],2);
        [U1,iminx] = min(Ux);      [U2,iminy] = min(Uy);
        minx = X(iminx);           miny = Y(iminy);
        
        newmin = U1; mini = -1;
        minAng = 0;
        minA = A;    minB = B;
        while (mini ~= newmin)
            mini = newmin;
            oldx = minx;        oldy = miny;
            [minA,minB,minAng,newmin] = ExploreAng(A,B,Ang,minx,miny);
            if (minAng == 0)
                break;
            end
            [minx,newmin] = ExploreX(minA,minB,X,miny);
            [miny,newmin] = ExploreY(minA,minB,minx,Y);
            if (oldx == minx && oldy == miny)
                break;
            end
        end
        
        R.x = minx;    R.y = miny;
        R.Ang = minAng;
%         R.newA = zeros(size(A),'uint8');
%         s = size(minA); l = s(1); m = s(2);
%         cropedA = minA(max(1,-minx+1):min(l,l-minx),max(1,-miny+1):min(m,m-miny));
%         R.newA(max(1,minx+1):min(l,l+minx),max(1,miny+1):min(m,m+miny)) = cropedA;
        
    end
    
%     l = size(RegRes,2);
%     
%     if (isempty(RegRes)) 
%         R.CumX = R.x;
%         R.CumY = R.y;
%         R.CumAng = R.Ang;
%     else
%         R.CumX = RegRes{l}.CumX + R.x ;
%         R.CumY = RegRes{l}.CumY + R.y;
%         R.CumAng = RegRes{l}.CumAng + R.Ang;
%     end
    
    %%  
    
    function [minx,C] = ExploreX(A,B,X,y)
        S = zeros(length(X),1);
        for i = 1:length(X)
            S(i) = Correl(A,B,X(i),y);
        end
        [C,I] = min(S);
        minx = X(I);
    end

    function [miny,C] = ExploreY(A,B,x,Y)
        S = zeros(length(Y),1);
        for i = 1:length(Y)
            S(i) = Correl(A,B,x,Y(i));
        end
        [C,I] = min(S);
        miny = Y(I);
    end

    function [minA,minB,minAng,mini] = ExploreAng(A,B,Ang,x,y)
        S = zeros(length(Ang),1);
        mini = 1.E10;
        minA = A; minB = B;
        minAng = 0;
        for i = 1:length(Ang)
            [A2,B2] = RotateAndCrop(A,B,Ang(i));
            S = Correl(A2,B2,x,y);
            if (S < mini)
                mini = S;
                minA = A2;         minB = B2;
                minAng = Ang(i);
            end
        end
    end

    function S = Explore(A,B,X,Y)
        S = zeros(length(X),length(Y));
        for ii = 1:length(X)
            for jj = 1:length(Y) 
                S(ii, jj) = Correl(A,B,X(ii),Y(jj));
            end
        end
    end

    function C = Correl(A,B,ii,jj)
        s = size(A);
        l = s(1);        m = s(2);
        I = A(max(1,-ii+1):min(l,l-ii),max(1,-jj+1):min(m,m-jj));
        J = B(max(1,ii+1):min(l,l+ii),max(1,jj+1):min(m,m+jj));
        s = size(I);
        n = s(1)*s(2);
%         C = sum(sum(double(I).*double(J)))/n;
        C =  sum(sum(abs(double(I) - double(J)).^2 ))/n;
    end

    function [I,J] = RotateAndCrop(A,B,theta)
        if theta == 0
            I = A;
            J = B;
            return
        end
        s = size(A);
        l = s(1); m = s(2);
        I2 = imrotate(A,theta,'bilinear','crop');
        cropx = ceil(abs(sin(theta/180*3.14159265)*l/2.));
        cropy = ceil(abs(sin(theta/180*3.14159265)*m/2.));
        I = I2(cropy+1:l-cropy,cropx+1:m-cropx);
        J = B(cropy+1:l-cropy,cropx+1:m-cropx);
    end
end
