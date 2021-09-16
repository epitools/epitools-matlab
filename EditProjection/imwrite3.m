function imwrite3( A, filename)

% saves an image 3D matrix as a multi-tiff image
% only tiff images supported

s=size(A);

imwrite(A(:,:,1),filename,'tif','Compression','none');

for n=2:s(3),
    imwrite(A(:,:,n),filename,'tif','WriteMode','append','Compression','none');
end


