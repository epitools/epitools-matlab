function [status, argout] =  tracking_func(input_args, varargin)
%TRACKING This function initialises the tracking module 
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This module helps to reduce the amount of segmentation errors in the image by tracking 
% all cell seeds throughout every frame. The GUI shows the seeds and the cell boundaries 
% obtained from the segmentation module and uses the registered image as background.
% Incompletely tracked cells are often due to segmentation mistakes which can be corrected 
% by manual supervision. Manual intervention is currently defined as placing and removing 
% seeds by simple clicking actions. The algorithm will automatically recalculate the 
% trajectories when a modification occurs.
% Find more explanation in TrackingGUIwOldOK.m

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
% DATE:     02.09.14 V0.1 for EpiTools 0.1 beta
%           05.12.14 V0.2 for EpiTools 2.0 beta
%           29.01.15 V0.3 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.
%
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
%% Retrieve supplementary arguments
if (nargin<2); varargin(1) = {'SEGIMAGEPATH'};varargin(2) = {'TRACKINGPATH'};varargin(3) = {'SETTINGS'};end
%% Procedure initialization
status = 1;
%% Retrieve parameter data
% it is more convenient to recall the setting file with as shorter variable
% name: stgModule
% TODO: input_args{strcmp(input_args(:,1),'SmoothingRadius'),2}
handleSettings = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
%% Remapping
% it is more convenient to recall the setting file with a shorter variable
% name: stgModule 
stgObj = getVariable4Memory(handleSettings);
tmpStgObj = stgObj.analysis_modules.Tracking.settings;
% -------------------------------------------------------------------------
% Log status of current application status
log2dev('********************* TRACKING MODULE *********************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision:  0.3.1-Jan15 $ Date: 2015/01/29 11:12:56      *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started tracking analysis module', 'INFO');
% -------------------------------------------------------------------------
% Load segmentation results
tmpSegObj = load([stgObj.data_analysisindir,'/SegResults']);
%Save original sequence dimensions
NX = size(tmpSegObj.RegIm,1);
NY = size(tmpSegObj.RegIm,2);
%NT = size(tmpSegObj.RegIm,3);
strFilename = strcat('ILabelsCorrected_',datestr(now,30));
output = [stgObj.data_analysisoutdir,'/',strFilename];
%% Retrieve tracking file
listFilesInput = dir(stgObj.data_analysisindir);
ArrayFileNames = [listFilesInput.name];
% If tracking module has been executed already, ask which tracking file to start with
if (~isempty(strfind(ArrayFileNames,'ILabelsCorrected')))
    [filename, pathname] = uigetfile(strcat(stgObj.data_analysisindir,'/','*.mat'),'Select last tracking file');
    if (~isa(filename, 'char') && (filename == 0 || pathname == 0));filename = ''; pathname = ''; end 
    % If tracking module has not been executed aready... then in the folder you
    % might find TrackingStart.mat
elseif (~isempty(strfind(ArrayFileNames,'TrackingStart')))
    filename =  '/TrackingStart.mat';
    pathname =  stgObj.data_analysisindir;
    % If segmentation module has not been executed
    % In future, throw an error due to dependences not satisfied
else
    return;
end
% Load seed file
if((isempty(filename) || isempty(pathname) ) == 1);return;end
IL = load([pathname,filename]);
log2dev(['Current tracking file: ',filename],'INFO');
%patch to avoid the increase in x,y dimensions
IL.ILabels = IL.ILabels(1:NX,1:NY,:);
%% Retrieve cropping mask file
%Did the user apply a polygon crop? If yes use the cropped CLabels
cropped_cell_labels_file = [stgObj.data_analysisindir,'/CroppedCellLabels.mat'];
if exist(cropped_cell_labels_file,'file')
    cropped_data = load(cropped_cell_labels_file);
    tmpSegObj.CLabels = cropped_data.cropped_CellLabelIm;
    log2dev(['User applied cropping mask on segmented cells with file: ',filename],'INFO');
end
%% Execute tracking GUI
fig = TrackingGUIwOldOK(tmpSegObj.RegIm,...
                        IL.ILabels,...
                        tmpSegObj.CLabels,...
                        tmpSegObj.ColIms,...
                        output,...
                        tmpStgObj,...
                        IL.oktrajs,...
                        IL.FramesToRegrow,...
                        stgObj.analysis_modules.Tracking.results);
uiwait(fig); 
if exist('tmp/trackingmeta.xml','file')>0
    tmp = xml_read('tmp/trackingmeta.xml');
    stgObj.AddResult('Tracking',tmp{1}{1},tmp{1}{2});
    if isfield(stgObj.analysis_modules.Tracking.metadata, 'click_counts')
        stgObj.ModifyMetadata('Tracking','click_counts', stgObj.analysis_modules.Tracking.metadata.click_counts + tmp{2});
    else
        stgObj.AddMetadata('Tracking','click_counts', tmp{2});
    end    
    status = 0;
    delete('tmp/trackingmeta.xml');
else
    status = 1;
    return;
end
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
% -------------------------------------------------------------------------
argout(1).description = 'Tracking results from seed correction module';
argout(1).ref = varargin(1);
%argout(1).object = strcat([stgMain.data_analysisoutdir,'/ProjIm.tif']);
argout(1).object = strcat([stgObj.data_analysisoutdir,'/',tmp{1}{2}]);
% -------------------------------------------------------------------------
argout(2).description = 'Settings associated module instance execution';
argout(2).ref = varargin(3);
argout(2).object = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
% -------------------------------------------------------------------------
end

