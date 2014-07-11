function ImproveContrast( DataSpecificsPath, enhancement_limit)
%ImproveContrast Improve image contrast by applying CLAHE
%   CLAHE - Contrast-Limited Adaptive Histogram Equalization
%   DataSpecificsPath - Path Data to analyze (See InspectData function)

load(DataSpecificsPath);
load([AnaDirec,'/RegIm']);

progressbar('Enhancing contrast...');

%pre-allocate output
RegIm_clahe = zeros(size(RegIm,1), size(RegIm,2), size(RegIm,3), 'double');

%assuming that images are either 8 or 16bit in input
load([AnaDirec,'/ProjIm']);
uint_type = class(ProjIm);

for i=1:size(RegIm,3)
    %parameter needs to be adapted for specific image input:
    
    if(isa(RegIm,'double'))
        if(uint_type == 8)
            RegIm_uint = uint8(RegIm(:,:,i));
        elseif(uint_type == 16)
            RegIm_uint = uint16(RegIm(:,:,i));
        else
            error('I could not determine the pixel depth. Images should have either 8 bit or 16 bit pixel depth')
        end
    else
        RegIm_uint = RegIm(:,:,i);
    end
    
    %todo, this needs to be adaptive for the image size
    %e.g. compute NumTiles based on a predifined size of tiling (e.g. 30px)
    RegIm_clahe_uint = adapthisteq(RegIm_uint,'NumTiles',[70 70],'ClipLimit',enhancement_limit);
    
    if(isa(RegIm,'double'))
        RegIm_clahe(:,:,i) = double(RegIm_clahe_uint);
    else
       RegIm_clahe(:,:,i) = RegIm_clahe_uint; 
    end
    
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

