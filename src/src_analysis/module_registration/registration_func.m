function [ status, argout ] = registration_func(input_args,varargin)
%REGISTRATION_FUNC Registers image sequence in Time to correct for sample movement
% ------------------------------------------------------------------------------
% PREAMBLE
%
% If the sample is characterized by movement during the acquisition the time series can 
% be corrected by aligning successive frames to the first.
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
if (nargin<2); varargin(1) = {'REGIMAGEPATH'};varargin(2) = {'SETTINGS'};end
%% Procedure initialization
status = 1;
%% Retrieve parameter data
% it is more convenient to recall the setting file with as shorter variable
% name: stgModule
% TODO: input_args{strcmp(input_args(:,1),'SmoothingRadius'),2}
handleSettings = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
tmp = getappdata(getappdata(0,'hMainGui'),'execution_memory');
% Remapping
stgMain = tmp.(char(handleSettings));
stgModule = stgMain.analysis_modules.Stack_Registration.settings;
tmpObj = load([stgMain.data_analysisindir,'/ProjIm']);
% -------------------------------------------------------------------------
% Log current application status
log2dev('******************* REGISTRATION MODULE *******************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.2.1-Dec14 $ Date: 2014/09/02 11:37:00       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started projection analysis module ', 'INFO');
% -------------------------------------------------------------------------
if(stgModule.useStackReg)
    RegIm = stackRegWrapper(tmpObj.ProjIm);
    % ---------------------------------------------------------------------
    % Log current application status
    log2dev('Projection redirected to stackRegWrapper ', 'DEBUG');
    % ---------------------------------------------------------------------
else
    progressbar('Registering images... (please wait)');
    % ---------------------------------------------------------------------
    % Log current application status
    log2dev('Projection redirected to @RegisterStack ', 'DEBUG');
    % ---------------------------------------------------------------------
    RegIm = RegisterStack(tmpObj.ProjIm,stgModule);
    progressbar(1);
end
% inspect results
if ~stgMain.exec_commandline
    if(stgMain.icy_is_used)
        icy_vidshow(RegIm,'Registered Sequence');
    end
end
%saving results
stgMain.AddResult('Stack_Registration','registration_path',[stgMain.data_analysisoutdir,'/RegIm.mat']);
save([stgMain.data_analysisoutdir,'/RegIm'],'RegIm');
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
% -------------------------------------------------------------------------
argout(1).description = 'Registered image file path';
argout(1).ref = varargin(1);
argout(1).object = strcat([stgMain.data_analysisoutdir,'/RegIm.mat']);
% -------------------------------------------------------------------------
argout(2).description = 'Settings associated module instance execution';
argout(2).ref = varargin(2);
argout(2).object = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
% -------------------------------------------------------------------------
%% Status execution update
status = 0;
end

