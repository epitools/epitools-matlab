function CropSegmentation( DataSpecificsPath )
%CropSegmentation Improve image contrast by applying CLAHE
%   CLAHE - Contrast-Limited Adaptive Histogram Equalization
%   DataSpecificsPath - Path Data to analyze (See InspectData function)

load(DataSpecificsPath);
load([AnaDirec,'/SegResults']);

figure;
imshow(RegIm(:,:,1),[]);
BW = roipoly;

CLabelsCrop = zeros(size(RegIm));

for f = 1 : size(RegIm,3)
    I1 = CLabels(:,:,f);
    I1(BW < 1) = 0;
    Ls = unique(I1);
    
    I2 = CLabels(:,:,f);
    I2(~ismember(I2,Ls)) =0;
    CLabelsCrop(:,:,f) = I2;
end

%StackView(CLabelsCrop)

save([AnaDirec,'/CLabels_woCrop'],'CLabels');

CLabels = CLabelsCrop;

save([AnaDirec,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','params','-v7.3');

end

