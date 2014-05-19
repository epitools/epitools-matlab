function ImproveContrast( DataSpecificsPath,uint_type, enhancement_limit)
%ImproveContrast Improve image contrast by applying CLAHE
%   CLAHE - Contrast-Limited Adaptive Histogram Equalization
%   DataSpecificsPath - Path Data to analyze (See InspectData function)

load(DataSpecificsPath);
load([AnaDirec,'/RegIm']);

progressbar('Enhancing contrast...');

%pre-allocate output
RegIm_clahe = zeros(size(RegIm,1), size(RegIm,2), size(RegIm,3), 'double');

for i=1:size(RegIm,3)
    %parameter needs to be adapted for specific image input: uint16>uint8
    if(uint_type == 8)
        RegIm_uint = uint8(RegIm(:,:,i));
    else
        RegIm_uint = uint16(RegIm(:,:,i));
    end
    RegIm_clahe_uint = adapthisteq(RegIm_uint,'NumTiles',[70 70],'ClipLimit',enhancement_limit);
    RegIm_clahe(:,:,i) = double(RegIm_clahe_uint);
    
    progressbar(i/size(RegIm,3));
end

progressbar(1);

StackView(RegIm_clahe);

do_overwrite = questdlg('Please decide over the CLAHE image','Overrite decision',...
    'Overrite original','Keep Original','Keep Original');

if(strcmp(do_overwrite,'Overrite original'))

    %backup previous result
    save([AnaDirec,'/RegIm_woCLAHE'],'RegIm');

    %save new version with contrast enhancement
    RegIm = RegIm_clahe;
    save([AnaDirec,'/RegIm'],'RegIm');
    
end

end

