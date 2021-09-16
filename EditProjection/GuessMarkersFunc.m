function [markermap2, depthmap2]=GuessMarkersFunc(ImStack, depthThreshold)

% AUTHOR:   Andreas Hoppe (A.Hoppe@kingston.ac.uk)
%           

SmoothingRadius=20;
SurfSmoothness1=30;
%depthThreshold=1.2;

cutmarkerthreshold=7;


if (nargin==1)
   depthThreshold=1.2;
end

s=size(ImStack); 

markermap=zeros(s(1),s(2));
markermap=imnoise(markermap,'salt & pepper',0.1);
zmaxproj=max(ImStack,[],3);

gf = fspecial( 'gaussian', [s(1) s(2)], SmoothingRadius);
I1 = zeros([s(1), s(2),s(3) ]);
for z=1:s(3),
    I1(:,:,z) = real(fftshift(ifft2(fft2(ImStack(:,:,z)).*fft2(gf))));
end



% ---- prepare surface ---------

[vm1,depthmap] = max(I1,[],3);
markers=depthmap.*double(zmaxproj>cutmarkerthreshold).*markermap;


[y,x]=find( markers > 0);
z=markers(markers > 0);
tilesize = max(s(1),s(2));
  
  
  xnodes = 1:s(2);
  ynodes = 1:s(1);
  [zg1,xg1,yg1] = gridfit(...
    x,y,z,xnodes,ynodes,...
    'tilesize',tilesize,...
    'overlap',0.25,...
    'smoothness',SurfSmoothness1,...
    'interp','bilinear','regularizer','springs');


markermap2 = markers.*(abs(depthmap-zg1)<depthThreshold);
depthmap2=zg1;



end






