function [status, argout] =  resegmentation_func(input_args, varargin)
%RESEGMENTATION This function resegments the image given a set of corrected seeds
% ------------------------------------------------------------------------------
% PREAMBLE
%
% ReSegmentation procedure processes the image file loaded give a set of seeds 
% manually corrected by the user during the tracking step of the pipeline.
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
if (nargin<2); varargin(1) = {'RESEGIMAGEPATH'};varargin(2) = {'SETTINGS'};end
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
tic
% -------------------------------------------------------------------------
% Log status of current application status
log2dev('***************** RESEGEMENTATION MODULE ******************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.3.1-Jan15 $ Date: 2015/01/29 10:56:01       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started re-segmentation analysis module', 'INFO');
% ------------------------------------------------------------------------- 
if(stgObj.hasModule('Segmentation'))
    segmentation_module = stgObj.analysis_modules.Segmentation;
else
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev('Segmentation module missing, cannot proceed with resegmentation', 'ERR');
    % -------------------------------------------------------------------------
    return;
end
if(stgObj.hasModule('Tracking'))
    tracking_module = stgObj.analysis_modules.Tracking;
else
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev('Tracking module missing, cannot proceed with resegmentation', 'ERR');
    % -------------------------------------------------------------------------
    return;
end
%copy all parameters from old segmentation
stgObj.analysis_modules.ReSegmentation.settings = segmentation_module.settings;
tmpStgObj = stgObj.analysis_modules.ReSegmentation.settings;
%% Load data (only if working in new matlab session)
load([stgObj.data_analysisindir,'/SegResults']);
% This should be substituted with the last tracking file saved
% in the analysis module. Might wanna check for compatability
% in case the tracking module was used on another machine!
[filename, pathname] = uigetfile(strcat(stgObj.data_analysisindir,'/','*.mat'),'Select last tracking file');
tracking_file = [pathname, filename];
stgObj.AddResult('ReSegmentation','tracking_file_path',filename);
%% Now resegmenting the frames which need it!
% given the reduced amuont of frames parallelization is manually set
% as otherwise always all frames would be resegmented. Judge according
% to the case if to activate or not
% Check current parallel options
if(stgObj.platform_units ~= 1); tmpStgObj.Parallel = true; else tmpStgObj.Parallel = false; end
IL = load(tracking_file);
[ILabels , CLabels , ColIms] = SegmentStack( RegIm , tmpStgObj , IL.ILabels ,CLabels, ColIms, IL.FramesToRegrow );
% Added version option to save ColIms as well /skipped otherwise, added
NX = size(RegIm,1);
NY = size(RegIm,2);
NT = size(RegIm,3);
% Storage results
save([stgObj.data_analysisoutdir,'/SegResultsCorrected'], 'RegIm','ILabels', 'CLabels' ,'ColIms','tmpStgObj','NX','NY','NT','IL','-v7.3' );
stgObj.AddResult('ReSegmentation','ReSegmentation_path',[stgObj.data_analysisoutdir,'/SegResultsCorrected.mat']);   
% -------------------------------------------------------------------------
% Log status of current application status
elapsedTime = toc;
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
argout(1).description = 'ReSegmented image file path';
argout(1).ref = varargin(1);
%argout(1).object = strcat([stgMain.data_analysisoutdir,'/ProjIm.tif']);
argout(1).object = strcat([stgObj.data_analysisoutdir,'/SegResultsCorrected.mat']);
% -------------------------------------------------------------------------
argout(2).description = 'Settings associated module instance execution';
argout(2).ref = varargin(2);
argout(2).object = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
% -------------------------------------------------------------------------
%% Status execution update
status = 0;
end

