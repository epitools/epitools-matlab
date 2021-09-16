function A=imreadRobLargeFiles(filename)

info = imfinfo(filename);
A = [];
numberOfImages = length(info);
for k = 1:numberOfImages
    currentImage = imread(filename, k, 'Info', info);
    A(:,:,k) = currentImage;
end