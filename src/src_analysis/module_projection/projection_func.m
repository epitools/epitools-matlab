function [ status, argout ] = projection_func(input_args,varargin)
%PROJECTION Discover the surface of the highest intensity signal in the image
%           stack and selectively project the signal lying on that surface
% ------------------------------------------------------------------------------
% PREAMBLE
%
% Creates a 2D projection from a Z-stack by selectively choosing from which
% plane to extract each pixel based on a surface estimation. The input image is
% composed of several z planes representing a cohesive tissue which can be
% approximated by a 3D surface. In order to exclude another surface from being
% also projected the latter has to have a lower intensity or at least a smaller
% number of high intensity points than the region of interest (ROI).
%
% INPUT
%   1. input_args:  variable containing the analysis object
%   2. varargin:    variable containing extra parameters for ref association
%                   during output formatting (might not be implemented)
%
% OUTPUT
%   1. status:  status elaboration (0  executed correctly; > 0 fatal error)
%   2. argout:  variable containing a structure with output objects, description
%               and ref association
%
% REFERENCES
%
% AUTHOR:   Alexander Tournier (alexander.tournier@cancer.org.uk)
%           Andreas Hoppe (A.Hoppe@kingston.ac.uk)
%           Davide Martin Heller (davide.heller@imls.uzh.ch)
%           Lorenzo Gatti (lorenzo.gatti@alumni.ethz.ch)
%
% DATE:     2.09.14 V0.1 for EpiTools 0.1 beta
%           5.12.14 V0.2 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.
%
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
%% Retrieve supplementary arguments
if (nargin<2); varargin(1) = {'PJIMAGEPATH'};varargin(2) = {'PJSURFPATH'};varargin(3) = {'SETTINGS'};end
%% Procedure initialization
status = 1;
%initialize progressbar
progressbar('Projecting images...');
% Initialize global time variable
global_time_index = 0;
% Variable indicating the number of processed files
intProcessedFiles = 0;
%% Retrieve parameter data
% it is more convenient to recall the setting file with as shorter variable
% name: stgModule
% TODO: input_args{strcmp(input_args(:,1),'SmoothingRadius'),2}
handleSettings = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
tmp = getappdata(getappdata(0,'hMainGui'),'execution_memory');
% Remapping
stgMain = tmp.(char(handleSettings));
stgModule = stgMain.analysis_modules.Projection.settings;
% -------------------------------------------------------------------------
% Log status of current application status
log2dev('******************** PROJECTION MODULE ********************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.2.1-Dec14 $ Date: 2014/09/02 11:37:00       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started projection analysis module', 'INFO');
% -------------------------------------------------------------------------
% Preparing specifics for all the images in the analysis
%stgObj.analysis_modules.Main.indices = PreparingData2Load(stgObj);
% Activate Matlabpools for parallel execution if set in stgObj
if(stgMain.platform_units ~= 1)
    parpoolobj = parpool('local',stgMain.platform_units);
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev( sprintf('Opening %u pools on currently default cluster',parpoolobj.NumWorkers), 'DEBUG');
    % -------------------------------------------------------------------------
end
% Per each IMG ID in the IMG ID list generated with PreparingData2Load (where the
% exec toggle property was set to true)
for i=1:numel(stgMain.analysis_modules.Main.indices.I)
    % Retrieve the current IMG ID from the list
    intCurImgIdx = stgMain.analysis_modules.Main.indices.I(i);
    % Retrieve the current IMG absolute path
    strCurFileName = char(stgMain.analysis_modules.Main.data(intCurImgIdx,1));
    strFullPathFile = [stgMain.data_imagepath,'/',strCurFileName];
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev(sprintf('Currently processing %s',strCurFileName), 'INFO');
    % -------------------------------------------------------------------------
    % If the first file is being processed, then initialize variables
    % Surface, ProjIm
    if(intProcessedFiles == 0)
        % Forced to be of type uint8
        Surfaces = zeros(cell2mat(stgMain.analysis_modules.Main.data(intCurImgIdx,3)),...
            cell2mat(stgMain.analysis_modules.Main.data(intCurImgIdx,2)),...
            sum(arrayfun(@length,stgMain.analysis_modules.Main.indices.T(intCurImgIdx))),...
            'uint8');
        ProjIm = zeros(cell2mat(stgMain.analysis_modules.Main.data(intCurImgIdx,3)),...
            cell2mat(stgMain.analysis_modules.Main.data(intCurImgIdx,2)),...
            sum(arrayfun(@length,stgMain.analysis_modules.Main.indices.T(intCurImgIdx))),...
            char(stgMain.analysis_modules.Main.data(intCurImgIdx,7)));
    end
    %% Load Data considering the specifics passed by stgObj.analysis_modules.Main.indices
    % Warning: the dimensions of ImagesPreStack are given by the number
    % of planes in output from LoadImgData. If channels num is 1, then
    % dim = 4
    [~,ImagesPreStack] = LoadImgData(strFullPathFile,intCurImgIdx,stgMain.analysis_modules.Main.indices);
    %% Project data
    totalTimeSteps = sum(cellfun(@length,stgMain.analysis_modules.Main.indices.T));
    for local_time_index = 1:length(stgMain.analysis_modules.Main.indices.T{intCurImgIdx})
        ImStack = ImagesPreStack(:,:,:,stgMain.analysis_modules.Main.indices.T{intCurImgIdx}(local_time_index));
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
        log2dev(sprintf('Local time point: %u | Global time point: %u | Progression: %0.2f',...
            local_time_index,...
            currTimeStep,...
            (currTimeStep/totalTimeSteps)),...
            'DEBUG');
        % -------------------------------------------------------------------------
        progressbar(currTimeStep/totalTimeSteps);
    end
    global_time_index=global_time_index+length(stgMain.analysis_modules.Main.indices.T{intCurImgIdx});
    intProcessedFiles = intProcessedFiles+1;
end
%% Saving results
%stgMain.AddResult('Projection','projection_path','ProjIm.tif');
stgMain.AddResult('Projection','projection_path','ProjIm.mat');
stgMain.AddResult('Projection','surface_path','Surfaces.mat');
%exportTiffImages(ProjIm,'filename',[stgMain.data_analysisoutdir,'/ProjIm.tif']);
save([stgMain.data_analysisoutdir,'/ProjIm'],'ProjIm')
save([stgMain.data_analysisoutdir,'/Surfaces'],'Surfaces')
%% Passing settings to calling environment
tmp = getappdata(getappdata(0,'hMainGui'),'settings_execution');
tmp.(char(handleSettings)) = stgMain;
setappdata(getappdata(0,'hMainGui'),'settings_execution', tmp);
% -------------------------------------------------------------------------
% Log status of current application status
log2dev(sprintf('Saving results as %s | %s',...
    ([stgMain.data_analysisoutdir,'/ProjIm']),...
    ([stgMain.data_analysisoutdir,'/Surfaces'])),...
    'INFO');
% -------------------------------------------------------------------------
progressbar(1);
% -------------------------------------------------------------------------
% Log status of current application status
log2dev('Finished projection module ', 'INFO');
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
% -------------------------------------------------------------------------
argout(1).description = 'Projected image file path';
argout(1).ref = varargin(1);
%argout(1).object = strcat([stgMain.data_analysisoutdir,'/ProjIm.tif']);
argout(1).object = strcat([stgMain.data_analysisoutdir,'/ProjIm.mat']);
% -------------------------------------------------------------------------
argout(2).description = 'Projected surface file path';
argout(2).ref = varargin(2);
argout(2).object = strcat([stgMain.data_analysisoutdir,'/Surfaces.mat']);
% -------------------------------------------------------------------------
argout(3).description = 'Settings associated module instance execution';
argout(3).ref = varargin(3);
argout(3).object = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
% -------------------------------------------------------------------------
%% Status execution update
status = 0;
end