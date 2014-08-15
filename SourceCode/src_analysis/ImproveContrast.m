function ImproveContrast(stgObj)
%ImproveContrast Improve image contrast by applying CLAHE
%   CLAHE - Contrast-Limited Adaptive Histogram Equalization
%   DataSpecificsPath - Path Data to analyze (See InspectData function)

tmpStgObj = stgObj.analysis_modules.Contrast_Enhancement.settings;
%load(DataSpecificsPath);

backup_file_name = [stgObj.data_analysisdir,'/RegIm_woCLAHE'];

if exist(backup_file_name, 'file')
    tmpRegObj = load(backup_file_name);
else
    tmpRegObj = load([stgObj.data_analysisdir,'/RegIm']);
end

progressbar('Enhancing contrast...(please wait)');

%% assuming that images are either 8 or 16bit in input
if ~isa(tmpRegObj.RegIm, 'uint16') && ~isa(tmpRegObj.RegIm, 'uint8')
    error('Images should have either 8 bit or 16 bit pixel depth');
end

%pre-allocate output
RegIm_clahe = zeros(size(tmpRegObj.RegIm), 'like', tmpRegObj.RegIm);


%% Apply CLAHE

for i=1:size(tmpRegObj.RegIm,3)
    %parameter needs to be adapted for specific image input:
    
    RegIm_uint = tmpRegObj.RegIm(:,:,i);
    
    %todo, this needs to be adaptive for the image size
    %e.g. compute NumTiles based on a predifined size of tiling (e.g. 30px)
    RegIm_clahe_uint = adapthisteq(RegIm_uint,'NumTiles',[70 70],'ClipLimit',tmpStgObj.enhancement_limit);
   
    RegIm_clahe(:,:,i) = RegIm_clahe_uint; 

    progressbar(i/size(tmpRegObj.RegIm,3));
end

progressbar(1);

%% Inspect results
if stgObj.hasModule('Main')
    if(stgObj.icy_is_used)
        icy_vidshow(RegIm_clahe,'CLAHE Sequence');
    else
        StackView(RegIm_clahe,'hMainGui','figureA');
    end
    
    do_overwrite = questdlg('Please decide over the CLAHE image','Overrite decision',...
    'Overrite original','Keep Original','Keep Original');
    
    overrite_original = strcmp(do_overwrite,'Overrite original');

else
    StackView(RegIm_clahe);
    overrite_original = 1;
end


%% Overrite original and save original result as backup (with time stamp to avoid any loss)
if(overrite_original)

    %backup original if not existant result
    if ~exist(backup_file_name, 'file')
        stgObj.AddResult('Contrast_Enhancement','clahe_backup_path',strcat(stgObj.data_analysisdir,'/RegIm_woCLAHE'));
        RegIm_woCLAHE = tmpRegObj.RegIm;
        save([stgObj.data_analysisdir,'/RegIm_woCLAHE'],'RegIm_woCLAHE');
    end
    
    %save new version with contrast enhancement
    RegIm = RegIm_clahe;
    stgObj.AddResult('Contrast_Enhancement','clahe_path',strcat(stgObj.data_analysisdir,'/RegIm'));
    save([stgObj.data_analysisdir,'/RegIm'],'RegIm');
    
end

end

