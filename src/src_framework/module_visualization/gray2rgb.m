function im3 = gray2rgb(im,map)

if nargin ==1
    map = [1 1 1];
end

im2 = cast(im, 'double');
im2 = im2/max(max(im2));

s = size(im);
im3 = zeros([s(1) s(2) 3]);
im3(:,:,1) = im2 * map(1);
im3(:,:,2) = im2 * map(2);
im3(:,:,3) = im2 * map(3);
end