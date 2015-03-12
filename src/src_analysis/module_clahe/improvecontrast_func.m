function [status,argout] = improvecontrast_func(input_args,varargin)
%IMPROVECONTRAST_FUNC Improve image contrast by applying CLAHE enhancement method
% ------------------------------------------------------------------------------
% PREAMBLE
%
% CLAHE operates on small regions in the image, called tiles, rather than the entire image. 
% Each tile's contrast is enhanced, so that the histogram of the output region approximately 
% matches the histogram specified by the 'Distribution' parameter. The neighboring tiles are 
% then combined using bilinear interpolation to eliminate artificially induced boundaries. 
% The contrast, especially in homogeneous areas, can be limited to avoid amplifying any 
% noise that might be present in the image
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

% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
%% Retrieve supplementary arguments
if (nargin<2); varargin(1) = {'CLAHEIMAGEPATH'};varargin(2) = {'SETTINGS'};end
%% Procedure initialization
status = 1;
argout = struct();
export_extratag = false;
%% Retrieve parameter data
handleSettings = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
execMessageUID = input_args{strcmp(input_args(:,1),'ExecutionMessageUID'),2};
tmp = getappdata(getappdata(0,'hMainGui'),'execution_memory');
% Remapping
stgMain = tmp.(char(handleSettings));
stgModule = stgMain.analysis_modules.Contrast_Enhancement.settings;
%% Load data
tmpRegObj = load([stgMain.data_analysisindir,'/RegIm']);
% Display informations about the current module        
% -------------------------------------------------------------------------
log2dev('*********************** CLAHE MODULE **********************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.2.1-Dec1  $ Date: 2014/12/17 22:13:46       *','INFO');
log2dev('***********************************************************','INFO');  
log2dev('Started clahe analysis module', 'INFO');
% -------------------------------------------------------------------------        
% Display informations about the elaborations      
progressbar('Enhancing contrast...(please wait)');
%% Check for correct formats
% Assuming that images are either 8 or 16bit in input
if ~isa(tmpRegObj.RegIm, 'uint16') && ~isa(tmpRegObj.RegIm, 'uint8')
    log2dev('Images should have either 8 bit or 16 bit pixel depth','ERR');
    return;
end
if numel(size(tmpRegObj.RegIm)<3)
    dim = 1;
elseif numel(size(tmpRegObj.RegIm)==3)
    dim = size(tmpRegObj.RegIm,3);
    export_extratag = true;
else numel(size(tmpRegObj.RegIm)==4)
    log2dev('This module does not support 4D images! Abort analysis','ERR');
    return;
end
%% Apply CLAHE
% Tracking time of the computation
tic
% Pre-allocate output
RegIm_clahe = zeros(size(tmpRegObj.RegIm), class(tmpRegObj.RegIm));
% Loop along the time frames
for i=1:dim
    % Extract single frame
    if dim == 1; RegIm_uint = tmpRegObj.RegIm(:,:); else RegIm_uint = tmpRegObj.RegIm(:,:,i); end
    % Retrieve image dimensions
    sizeX = size(tmpRegObj.RegIm,1);
    sizeY = size(tmpRegObj.RegIm,2);
    % Compute tiles number
    numTilesX = round(sizeX / stgModule.enhancement_width);
    numTilesY = round(sizeY / stgModule.enhancement_width);
    %todo, this needs to be adaptive for the image size ?
    %e.g. compute NumTiles based on a predifined size of tiling (e.g. 30px)
    RegIm_clahe_uint = adapthisteq(RegIm_uint,'NumTiles',[numTilesX numTilesY],'ClipLimit',stgModule.enhancement_limit);
    % Store result according to image dimensions
    if dim == 1; RegIm_clahe(:,:) = RegIm_clahe_uint; else RegIm_clahe(:,:,i) = RegIm_clahe_uint; end
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev(sprintf('Local time point: %u | Progression: %0.2f',i,(i/dim)), 'DEBUG');
    progressbar(i/dim);
    % -------------------------------------------------------------------------
end
elapsedTime = toc;
%% Storing Results
RegIm = RegIm_clahe;
stgMain.AddResult('Contrast_Enhancement','clahe_path',[stgMain.data_analysisoutdir,'/RegIm_wClahe.mat']);
stgMain.AddMetadata('Projection','handle_settings', handleSettings);
stgMain.AddMetadata('Projection','exec_message', execMessageUID);
stgMain.AddMetadata('Projection','exec_elapsed_time_seconds', elapsedTime);
save([stgMain.data_analysisoutdir,'/RegIm_wClahe'],'RegIm');
% -------------------------------------------------------------------------
% Log status of current application status
log2dev(sprintf('Finished after %.2f', elapsedTime), 'DEBUG');
progressbar(1);
%% Exporting extra Tags according to input data
server_instances = getappdata(getappdata(0, 'hMainGui'), 'server_instances');
server = server_instances(2).ref;
if export_extratag
        server.setMessageParameter(execMessageUID, 'Level','tags','Action','add','Argvar','Generic_Image_TSerie');
end
% -------------------------------------------------------------------------
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
% -------------------------------------------------------------------------
argout(1).description = 'Contast improved image file path';
argout(1).ref = varargin(1);
argout(1).object = strcat([stgMain.data_analysisoutdir,'/RegIm_wClahe.mat']);
% -------------------------------------------------------------------------
argout(2).description = 'Settings associated module instance execution';
argout(2).ref = varargin(2);
argout(2).object = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
% -------------------------------------------------------------------------
%% Status execution update
status = 0;
end

