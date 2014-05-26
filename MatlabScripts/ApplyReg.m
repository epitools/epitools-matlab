function im2 = ApplyReg(reg,im)
% ApplyReg [1 line description ]                                            
%
% IN: 
%   reg -
%   im - 
%
% OUT: 
%   im2 -                                                                  % change name!
%
% Author:
% Copyright:

imsize = size(im);
c = whos('im');
im2 = zeros(imsize,c.class);
s = imsize; l = s(1); m = s(2);
% rotate
RI = imrotate(im,reg.CumAng,'bilinear','crop');
%translate                                                                 % divide commands
cropedI = RI(max(1,-reg.CumX+1):min(l,l-reg.CumX),max(1,-reg.CumY+1):min(m,m-reg.CumY));
im2(max(1,reg.CumX+1):min(l,l+reg.CumX),max(1,reg.CumY+1):min(m,m+reg.CumY)) = cropedI;
end
