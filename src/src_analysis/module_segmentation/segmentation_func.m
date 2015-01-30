function [status, argout] =  segmentation_func(input_args, varargin)
%SEGMENTATION This function segments the image
% ------------------------------------------------------------------------------
% PREAMBLE
%
% Segmentation procedure to detect the individual cells in the image and find the 
% boundaries with a seed based region growing algorithm. The input image is assumed 
% to have high intensity membrane signal on low intensity background
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
% DATE:     02.09.14 V0.1 for EpiTools 0.1 beta
%           05.12.14 V0.2 for EpiTools 2.0 beta
%           27.01.15 V0.3 for EpiTools 2.0 beta
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
stgMain = getVariable4Memory(handleSettings);
tmpStgObj = stgMain.analysis_modules.Segmentation.settings;
tic
% -------------------------------------------------------------------------
% Log status of current application status
log2dev('******************* SEGMENTATION MODULE *******************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.3.1-Jan15 $ Date: 2015/01/27 22:53:12       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started segmentation analysis module', 'INFO');
% -------------------------------------------------------------------------        
use_clahe_flag = 0;
if(isfield(tmpStgObj,'use_clahe')) %backwards compatability
    if(stgMain.hasModule('Contrast_Enhancement'))
        if tmpStgObj.use_clahe; use_clahe_flag = 1; end
    else
        log2dev('CLAHE option is not available if CLAHE module has not been executed beforehand','INFO');
    end
end
if use_clahe_flag
    tmpRegObj = load([stgMain.data_analysisindir,'/RegIm_wClahe']);
else
    tmpRegObj = load([stgMain.data_analysisindir,'/RegIm']);
end
if tmpStgObj.SingleFrame
    %todo: SegmentStack should be able to handle single frames
    im = tmpRegObj.RegIm(:,:,1);
    [ILabels,CLabels,ColIms] = SegmentIm(im,tmpStgObj);
    %figure;
    %imshow(ColIms,[]);
    RegIm = im;
    save([stgMain.data_analysisoutdir,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','tmpStgObj','-v7.3')
    stgMain.AddResult('Segmentation','segmentation_path',[stgMain.data_analysisoutdir,'/SegResults.mat']);
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev(sprintf('Saving segmentation results as %s | %s',[stgMain.data_analysisoutdir,'/SegResults']), 'DEBUG');
    % -------------------------------------------------------------------------   
else
    %Check current parallel options 
    if(stgMain.platform_units ~= 1); tmpStgObj.Parallel = true; else tmpStgObj.Parallel = false; end
    % Calling segmentation function with parameters set previously
    [ILabels,CLabels,ColIms] = SegmentStack(tmpRegObj.RegIm,tmpStgObj);
    NX      = size(tmpRegObj.RegIm,1);
    NY      = size(tmpRegObj.RegIm,2);
    NT      = size(tmpRegObj.RegIm,3);
    RegIm   = tmpRegObj.RegIm;
    %save dummy tracking information
    FramesToRegrow = []; oktrajs = [];
    save([stgMain.data_analysisoutdir,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','tmpStgObj','NX','NY','NT','-v7.3')
    save([stgMain.data_analysisoutdir,'/TrackingStart'],'ILabels','FramesToRegrow','oktrajs')
    stgMain.AddResult('Segmentation','segmentation_path',[stgMain.data_analysisoutdir,'/SegResults.mat']);
    stgMain.AddResult('Segmentation','tracking_path',[stgMain.data_analysisoutdir,'/TrackingStart.mat']);
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev(sprintf('Saving segmentation results as %s | %s',[stgMain.data_analysisoutdir,'/SegResults'],[stgMain.data_analysisoutdir,'/TrackingStart']), 'DEBUG');
    % -------------------------------------------------------------------------
end
elapsedTime = toc;
% -------------------------------------------------------------------------
% Log status of current application status
log2dev(sprintf('Finished after %.2f', elapsedTime), 'DEBUG');
% -------------------------------------------------------------------------
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
% -------------------------------------------------------------------------
argout(1).description = 'Segmented image file path';
argout(1).ref = varargin(1);
%argout(1).object = strcat([stgMain.data_analysisoutdir,'/ProjIm.tif']);
argout(1).object = strcat([stgMain.data_analysisoutdir,'/SegResults.mat']);
% -------------------------------------------------------------------------
argout(2).description = 'Tracking file path';
argout(2).ref = varargin(2);
argout(2).object = strcat([stgMain.data_analysisoutdir,'/TrackingStart.mat']);
% -------------------------------------------------------------------------
argout(3).description = 'Settings associated module instance execution';
argout(3).ref = varargin(3);
argout(3).object = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
% -------------------------------------------------------------------------
%% Status execution update
status = 0;
end