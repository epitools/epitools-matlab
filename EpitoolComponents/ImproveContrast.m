function ImproveContrast( DataSpecificsPath )
%ImproveContrast Improve image contrast by applying CLAHE
%   CLAHE - Contrast-Limited Adaptive Histogram Equalization
%   DataSpecificsPath - Path Data to analyze (See InspectData function)

load(DataSpecificsPath);
load([AnaDirec,'/RegIm']);

%pre-allocate output
RegIm_clahe = zeros(size(RegIm,1), size(RegIm,2), size(RegIm,3), 'double');

for i=1:size(RegIm,3)
    %parameter needs to be adapted for specific image input: uint16>uint8
    RegIm_uint8 = uint8(RegIm(:,:,i));
    RegIm_clahe_uint8 = adapthisteq(RegIm_uint8,'NumTiles',[70 70],'ClipLimit',0.02);
    RegIm_clahe(:,:,i) = double(RegIm_clahe_uint8); 
end

%backup previous result
save([AnaDirec,'/RegIm_woCLAHE'],'RegIm');

%save new version with contrast enhancement
RegIm = RegIm_clahe;
save([AnaDirec,'/RegIm'],'RegIm');

end

