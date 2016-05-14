function ProjIm = reapplyProjection(ImStack, DepthMap)
%REAPPLYPROJECTION Reapply the projection to another channel of the image
% ------------------------------------------------------------------------------
%
% INPUT:
%   1. ImStack - 3D image matrix in 8 or 16-bit greyscale
%   2. DepthMap - 2D index matrix specifying the z-origin of every pixel
%                 in the previously projected image
%                 e.g. a slice of the Surfaces.mat file in EpiTools
%
% NOTE:
%   This only works for individual time points! 
%
% OUTPUT:
%   1. ProjIm - Projection of ImStack using the z-map in DepthMap
%
% AUTHOR:   Davide Martin Heller (davide.heller@imls.uzh.ch)
% 
% LICENSE:
%   License to use and modify this code is granted freely without any warranty
% ------------------------------------------------------------------------------

% extract the size information from the input stack
s = size(ImStack);

% preallocate output image with same x,y dimensions and data type as input
projected_image = zeros(s(1),s(2),class(ImStack));

% loop through every pixel of the image and insert the value of the
% pixel at the same x,y position in the input z-slice indicated by the DepthMap
for y=1:s(1),
    for x=1:s(2),
        z_coordinate = DepthMap(y,x);
        projected_image(y,x)=ImStack(y,x,z_coordinate);
    end
end

% define the output
ProjIm = projected_image;
