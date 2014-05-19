function Segmentation( DataSpecificsPath,params)
%Segmentation Segmenents the Projected Images
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
%   params - parameter structure for the segmentation algorithm
load(DataSpecificsPath);
load([AnaDirec,'/RegIm']);

im = RegIm(:,:,1);

[Ilabel ,Clabel,ColIm] = SegmentIm(im,params.show,params);

NX = size(RegIm,1);
NY = size(RegIm,2);
NT = size(RegIm,3);

save([AnaDirec,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','params','NX','NY','NT','-v7.3')

%save dummy tracking information
FramesToRegrow = [];
oktrajs = [];
save([AnaDirec,'/TrackingStart'],'ILabels','FramesToRegrow','oktrajs')

end

