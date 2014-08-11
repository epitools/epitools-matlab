function [varargout] = Projection(stgObj)
%SurfaceProjection Discover the surface of the highest intensity signal in
%the image stack and selectively project the signal lying on that surface
%
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
%   SmoothingRadius - how much smoothing to apply to original data (1-5)
%   SurfSmoothness1 - 1st surface fitting, surface stiffness ~100
%   SurfSmoothness2 - 2nd surface fitting, stiffness ~50
%   ProjectionDepthThreshold - how much up/down to gather data from surface
%
% todo: need to convert to int8 in a rational way here!
% can use 95 or 99% quantile of the data and then scale

%initialize progressbar
progressbar('Projecting images...');

global_time_index = 0;

% Variable indicating the number of processed files
intProcessedFiles = 0;

% it is more convenient to recall the setting file with as shorter variable
% name: stgModule
stgModule = stgObj.analysis_modules.Projection.settings;

fprintf('Started projection at %s',datestr(now));

% Preparing specifics for all the images in the analysis

stgObj.analysis_modules.Main.indices = PreparingData2Load(stgObj);

% Activate Matlabpools for parallel execution if set in stgObj
if(stgObj.platform_units ~= 1)
    matlabpool('local',stgObj.platform_units);
    ppm = ParforProgressStarter2('Projecting images...', ...
    length(stgObj.analysis_modules.Main.indices), 0.1, 0, 1, 1);
end



% Per each IMG ID in the IMG ID list generated with PreparingData2Load (where the
% exec toggle property was set to true)
for i=1:numel(stgObj.analysis_modules.Main.indices.I)
    
    % Retrieve the current IMG ID from the list
    intCurImgIdx = stgObj.analysis_modules.Main.indices.I(i);
    
    % Retrieve the current IMG absolute path
    strCurFileName = char(stgObj.analysis_modules.Main.data(intCurImgIdx,1));
    strFullPathFile = [stgObj.data_imagepath,'/',strCurFileName];
    
    % If the first file is being processed, then initialize variables
    % Surface, ProjIm
    if(intProcessedFiles == 0)
        
        % Forced to be of type uint8
        Surfaces = zeros(cell2mat(stgObj.analysis_modules.Main.data(intCurImgIdx,3)),...
            cell2mat(stgObj.analysis_modules.Main.data(intCurImgIdx,2)),...
            sum(arrayfun(@length,stgObj.analysis_modules.Main.indices.T)),...
            'uint8');
        
        ProjIm = zeros(cell2mat(stgObj.analysis_modules.Main.data(intCurImgIdx,3)),...
            cell2mat(stgObj.analysis_modules.Main.data(intCurImgIdx,2)),...
            sum(arrayfun(@length,stgObj.analysis_modules.Main.indices.T)),...
            char(stgObj.analysis_modules.Main.data(intCurImgIdx,7)));
    end
    
    %% Load Data considering the specifics passed by stgObj.analysis_modules.Main.indices
    
    % Warning: the dimensions of ImagesPreStack are given by the number
    % of planes in output from LoadImgData. If channels num is 1, then
    % dim = 4
    ImagesPreStack = LoadImgData(strFullPathFile,intCurImgIdx,stgObj.analysis_modules.Main.indices);
    
    %% Project data
    
    fprintf('Working on %s\n', strCurFileName);
    
    for local_time_index = 1:length(stgObj.analysis_modules.Main.indices.T(intCurImgIdx,:))
        
        ImStack = ImagesPreStack(:,:,:,stgObj.analysis_modules.Main.indices.T(intCurImgIdx,local_time_index));
        
        [im,Surf] = createProjection(ImStack,...
            stgModule.SmoothingRadius,...
            stgModule.ProjectionDepthThreshold,...
            stgModule.SurfSmoothness1,...
            stgModule.SurfSmoothness2,...
            stgModule.InspectResults);
        
        ProjIm(:,:,local_time_index+global_time_index) = im;
        Surfaces(:,:,local_time_index+global_time_index) = Surf;
        
        progressbar(((local_time_index-1)*length(stgObj.analysis_modules.Main.indices.T(intCurImgIdx,:))+...
            stgObj.analysis_modules.Main.indices.T(intCurImgIdx,local_time_index))/...
            length(stgObj.analysis_modules.Main.indices.T(intCurImgIdx,:))/...
            length(stgObj.analysis_modules.Main.indices.T(intCurImgIdx,:)));
        
    end
    
    global_time_index=global_time_index+length(stgObj.analysis_modules.Main.indices.T(intCurImgIdx,:));
    intProcessedFiles = intProcessedFiles+1;
    %ppm.increment(intProcessedFiles);
end

%% Saving results
stgObj.AddResult('Projection','projection_path',strcat(stgObj.data_analysisoutdir,'/ProjIm'));
stgObj.AddResult('Projection','surface_path',strcat(stgObj.data_analysisoutdir,'/ProjIm'));

save([stgObj.data_analysisoutdir,'/ProjIm'],'ProjIm')
save([stgObj.data_analysisoutdir,'/Surfaces'],'Surfaces')

%delete(ppm);
progressbar(1);
fprintf('Finished projection at %s\n',datestr(now));

%% Results visualisation according to the method of execution

if(~stgObj.exec_commandline)
    if(stgObj.icy_is_used)
        icy_vidshow(ProjIm,'Projected Sequence');
    else
        StackView(ProjIm,'hMainGui','figureA');
    end
else
    StackView(ProjIm)
end
end


