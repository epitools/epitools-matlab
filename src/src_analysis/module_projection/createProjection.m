function [ProjIm,DepthMap,xg2,yg2,zg2] = createProjection(ImStack, SmoothingRadius, depthThreshold,SurfSmoothness1,SurfSmoothness2,ShowProcess)
%CREATEPROJECTION Discover the surface of the highest intensity signal in the image
%                 stack and selectively project the signal lying on that surface
% ------------------------------------------------------------------------------
% PREAMBLE
%
% Creates a 2D projection from a Z-stack by selectively choosing from which
% plane to extract each pixel based on a surface estimation. The input image is
% composed of several z planes representing a cohesive tissue which can be
% approximated by a 3D surface. In order to exclude another surface from being
% also projected the latter has to have a lower intensity or at least a smaller
% number of high intensity points than the region of interest (ROI).
%
% INPUT [reccomended range]
%   1. ImStack - 3D image matrix in 8 or 16-bit greyscale
%   2. SmoothingRadius - gaussian blur to apply before estimating the surface [0.1 - 5]
%   3. depthThreshold - Cutoff distance in z-planes from the 1st estimated surface [1 - 3]
%   4. SurfSmoothness1 - Surface smoothness for 1st gridFit(c) estimation, the smaller the smoother [30 - 100]
%   5. SurfSmoothness1 - Surface smoothness for 3nd gridFit(c) estimation, the smaller the smoother [20 - 50]
%   6. ShowProcess - Boolean to output intermediate results
%
% OUTPUT
%   1. ProjIm - Projection of ImStack using only pixels closest to the 2nd gridfit surface
%   2. DepthMap - Z-location of pixels chosen for the Projected image from ImStack
%   3. xg2 - 1st component of the 2nd estimated gridfit surface
%   4. yg2 - 2nd component of the 2nd estimated gridfit surface
%   5. zg2 - 3rd component of the 2nd estimated gridfit surface
%
% REFERENCES
%
% AUTHOR:   Alexander Tournier (alexander.tournier@cancer.org.uk)
%           Andreas Hoppe (A.Hoppe@kingston.ac.uk)
%           Davide Martin Heller (davide.heller@imls.uzh.ch)
%           Lorenzo Gatti (lorenzo.gatti@alumni.ethz.ch)
%
% DATE:     2.09.14 V0.1 for EpiTools 0.1 beta
%           5.12.14 V0.2 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.
%
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Log status of current application status
log2dev('Creating smart projection', 'DEBUG');
% -------------------------------------------------------------------------

tic

s=size(ImStack); 

% doing some simple smoothing
gaussianProfile = fspecial( 'gaussian', [s(1) s(2)], SmoothingRadius);
I1 = zeros([s(1), s(2),s(3) ]);
for z=1:s(3),
    I1(:,:,z) = real(fftshift(ifft2(fft2(ImStack(:,:,z)).*fft2(gaussianProfile))));
end

% ---- prepare surface ---------                                           % what does prepare mean?
[vm1,depthmap] = max(I1,[],3);                                             % var names ?
confidencemap = s(3)*vm1./sum(I1,3);

c = confidencemap(:);
confthres = median(c(c > median(c)));

% keep only the brightest surface points (intensity in 1 quartile)
% assumed to be the surface of interest
depthmap2=depthmap.*double(confidencemap>confthres);                       % renaming depthmatp2 would help

%now fit a surface through these high-intensity points

[y,x]=find( depthmap2 > 0);
z=depthmap2(depthmap2 > 0);

xnodes = 1:s(2);
ynodes = 1:s(1);
tilesize = max(s(1),s(2));

% for more information on gridfit see the program header
[zg1,xg1,yg1] = gridfit(...
    x,y,z,xnodes,ynodes,...
    'tilesize',tilesize,...
    'overlap',0.25,...
    'smoothness',SurfSmoothness1,...
    'interp','bilinear','regularizer','springs');

if ShowProcess
    figure('Name','1st Surface Estimation');
    surf(xg1,yg1,zg1) 
    zlim([0,s(3)]);
    shading interp
    colormap(jet(256))
    camlight right
    lighting phong
    title 'Tiled gridfit'
end


% given the hight locations of the surface (zg1) compute the difference
% towards the 1st quartile location (depthmap2), ignore the rest (==0);
% the result reflects the distance (abs) between estimate and points.
depthmap3=abs(zg1-depthmap2);                                              
depthmap3(depthmap2==0)=0;

% only keep points which are relatively close to our first estimate,
% i.e. below the threshold. TIP: if the first estimate is too detailed(~=smooth)
% the points from the peripodial membrane will not be eliminated since
% the surface approximated them well. Increase the smoothness to prevent this.
depthmap4 = depthmap2.*(depthmap3 < depthThreshold); 

%TIP: depthmap4 should only contain signal of interest at this point.

% --- 2nd iteration - 
% compute a better more detailed estimate with the filtered list (depthmap4)
% this is to make sure that the highest intensity points will be
% selected from the correct surface (The coarse grained estimate could
% potentially approximate the origin of the point to another plane)

[y,x]=find( depthmap4 > 0);
z=depthmap4(depthmap4 > 0);


xnodes = 1:s(2);
ynodes = 1:s(1);
[zg2,xg2,yg2] = gridfit(...
    x,y,z,xnodes,ynodes,...
    'tilesize',tilesize,...
    'overlap',0.25,...
    'smoothness',SurfSmoothness2,...
    'interp','bilinear','regularizer','springs');


if ShowProcess
    figure('Name','2nd Surface Estimation');
    surf(xg2,yg2,zg2)
    zlim([0,s(3)]);
    shading interp
    colormap(jet(256))
    camlight right
    lighting phong
    title 'Tiled gridfit'
end

% ----- creating projected image from interpolated surface estimation ------

projected_image=zeros(s(1),s(2),class(ImStack));
z_origin_map = zeros(s(1),s(2),'uint8'); % supports up to 256 planes


for y=1:s(1),
    for x=1:s(2),
        if (zg2(y,x) > 0)
            z_coordinate = round(zg2(y,x));
            z_origin_map(y,x) = z_coordinate;
            projected_image(y,x)=ImStack(y,x,z_coordinate);
        end
    end
end

elapsedTime = toc;
% -------------------------------------------------------------------------
% Log status of current application status
log2dev(sprintf('Finished after %.2f', elapsedTime), 'DEBUG');
% -------------------------------------------------------------------------


ProjIm = projected_image;
DepthMap = z_origin_map;



