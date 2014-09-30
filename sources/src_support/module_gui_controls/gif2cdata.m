function cdataout = gif2cdata(path)

[cdata,map] = imread(path);
 
% Convert white pixels into a transparent background
map(find(map(:,1)+map(:,2)+map(:,3)==3)) = NaN;
 
% Convert into 3D RGB-space
cdataout = ind2rgb(cdata,map);
end