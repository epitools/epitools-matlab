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

% -------------------------------------------------------------------------
% Log status of current application status
log2dev('******************** PROJECTION MODULE ********************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.1 beta    $ Date: 2014/09/02 11:37:00       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started projection analysis module', 'INFO');
% -------------------------------------------------------------------------

% Preparing specifics for all the images in the analysis
stgObj.analysis_modules.Main.indices = PreparingData2Load(stgObj);

% Activate Matlabpools for parallel execution if set in stgObj
if(stgObj.platform_units ~= 1)
    parpoolobj = parpool('local',stgObj.platform_units);
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev( sprintf('Opening %u pools on currently default cluster',parpoolobj.NumWorkers), 'DEBUG');
    % -------------------------------------------------------------------------
end

% Per each IMG ID in the IMG ID list generated with PreparingData2Load (where the
% exec toggle property was set to true)
for i=1:numel(stgObj.analysis_modules.Main.indices.I)
    
    % Retrieve the current IMG ID from the list
    intCurImgIdx = stgObj.analysis_modules.Main.indices.I(i);
    
    % Retrieve the current IMG absolute path
    strCurFileName = char(stgObj.analysis_modules.Main.data(intCurImgIdx,1));
    strFullPathFile = [stgObj.data_imagepath,'/',strCurFileName];
    

    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev(sprintf('Currently processing %s',strCurFileName), 'INFO');
    % -------------------------------------------------------------------------


    % If the first file is being processed, then initialize variables
    % Surface, ProjIm
    if(intProcessedFiles == 0)
        
        % Forced to be of type uint8
        Surfaces = zeros(cell2mat(stgObj.analysis_modules.Main.data(intCurImgIdx,3)),...
            cell2mat(stgObj.analysis_modules.Main.data(intCurImgIdx,2)),...
            sum(arrayfun(@length,stgObj.analysis_modules.Main.indices.T(intCurImgIdx))),...
            'uint8');
        
        ProjIm = zeros(cell2mat(stgObj.analysis_modules.Main.data(intCurImgIdx,3)),...
            cell2mat(stgObj.analysis_modules.Main.data(intCurImgIdx,2)),...
            sum(arrayfun(@length,stgObj.analysis_modules.Main.indices.T(intCurImgIdx))),...
            char(stgObj.analysis_modules.Main.data(intCurImgIdx,7)));
    end
    
    %% Load Data considering the specifics passed by stgObj.analysis_modules.Main.indices
    
    % Warning: the dimensions of ImagesPreStack are given by the number
    % of planes in output from LoadImgData. If channels num is 1, then
    % dim = 4
    
    ImagesPreStack = LoadImgData(strFullPathFile,intCurImgIdx,stgObj.analysis_modules.Main.indices);
    
    %% Project data
    totalTimeSteps = sum(cellfun(@length,stgObj.analysis_modules.Main.indices.T));
    
    for local_time_index = 1:length(stgObj.analysis_modules.Main.indices.T{intCurImgIdx})
    

        ImStack = ImagesPreStack(:,:,:,stgObj.analysis_modules.Main.indices.T{intCurImgIdx}(local_time_index));
        
        [im,Surf] = createProjection(ImStack,...
            stgModule.SmoothingRadius,...
            stgModule.ProjectionDepthThreshold,...
            stgModule.SurfSmoothness1,...
            stgModule.SurfSmoothness2,...
            stgModule.InspectResults);
        
        ProjIm(:,:,local_time_index+global_time_index) = im;
        Surfaces(:,:,local_time_index+global_time_index) = Surf;
        
        currTimeStep = global_time_index + local_time_index;

        % -------------------------------------------------------------------------
        % Log status of current application status
        log2dev(sprintf('Local time point: %u | Global time point: %u | Progression: %0.2f',local_time_index,currTimeStep,(currTimeStep/totalTimeSteps)), 'DEBUG');
        % -------------------------------------------------------------------------

        progressbar(currTimeStep/totalTimeSteps);
        
    end
    
    global_time_index=global_time_index+length(stgObj.analysis_modules.Main.indices.T{intCurImgIdx});
    intProcessedFiles = intProcessedFiles+1;

end

%% Saving results
stgObj.AddResult('Projection','projection_path','ProjIm.mat');
stgObj.AddResult('Projection','surface_path','Surfaces.mat');

save([stgObj.data_analysisoutdir,'/ProjIm'],'ProjIm')
save([stgObj.data_analysisoutdir,'/Surfaces'],'Surfaces')

% -------------------------------------------------------------------------
% Log status of current application status
log2dev(sprintf('Saving results as %s | %s',([stgObj.data_analysisoutdir,'/ProjIm']),([stgObj.data_analysisoutdir,'/Surfaces'])), 'INFO');
% -------------------------------------------------------------------------

progressbar(1);

% -------------------------------------------------------------------------
% Log status of current application status
log2dev('Finished projection module ', 'INFO');
% -------------------------------------------------------------------------

%% Results visualisation according to the method of execution
if(~stgObj.exec_commandline)
    if(stgObj.icy_is_used)
        icy_vidshow(ProjIm,'Projected Sequence');

        % -------------------------------------------------------------------------
        % Log current application status
        log2dev('Display results of projection module via IcyConnection ', 'DEBUG');
        % -------------------------------------------------------------------------

    else
        if(strcmp(stgObj.data_analysisindir,stgObj.data_analysisoutdir))
            
            fig = getappdata(0  , 'hMainGui');
            handles = guidata(fig);
            
            set(handles.('uiBannerDescription'), 'Visible', 'on');
            set(handles.('uiBannerContenitor'), 'Visible', 'on');
            
            % Change banner description
            log2dev('Currently executing the [Projection] module',...
            'GUI',...
            2,...
            'hMainGui',...
            'uiBannerDescription');
            
            StackView(ProjIm,'hMainGui','figureA');


        else
            firstrun = load([stgObj.data_analysisindir,'/ProjIm']);
            % The program is being executed in comparative mode
            StackView(firstrun.ProjIm,'hMainGui','figureC1');
            StackView(ProjIm,'hMainGui','figureC2');
            
        end

        % -------------------------------------------------------------------------
        % Log status of current application status
        log2dev('Display results of projection module via @StackView ', 'DEBUG');
        % -------------------------------------------------------------------------

    end
else
    StackView(ProjIm);
end
end


