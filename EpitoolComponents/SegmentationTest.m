function SegmentationTest( DataSpecificsPath,params)
%Segmentation Segmenents the Projected Images
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
%   params - parameter structure for the segmentation algorithm
load(DataSpecificsPath);
load([AnaDirec,'/RegIm']);

%Segment only the first frame of RegIm
im = RegIm(:,:,1);

progressbar('Segmenting first frame...');

[Ilabel ,Clabel,ColIm] = SegmentIm(im,params.show,params);

progressbar(1);

%Visualize result
figure();
imshow(ColIm,[]);

end

