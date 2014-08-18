% Program to make correction iterative. First set the sample to work on
% and then proceed to redo the tracking information.
%
% author:   Davide Heller
% email:    davide.heller@imls.uzh.ch
% date:     2014-02-13

% help: Proceed through the sections by pressing cmd + enter, 
%       the last section can be executed repeatedly without risking to 
%       overwrite the previous results.

%% Epitools setup

%retrieve needed files from current script location requires Matlab 7+
%assuming this file is executed from repository location!
file_path = pwd;

% set epitool script location
addpath([fileparts(file_path),'/MatlabScripts'])
javaaddpath([fileparts(file_path),'/OME_LOCI_TOOLS/loci_tools.jar'])
addpath([fileparts(file_path),'/OME_LOCI_TOOLS']) 

%% Load Image and Segmentation 

pathname = '/Users/alexandertournier/Documents/CRUK-UCL/Yanlan/epitools/Tests/SingleFrame/Analysis/';

disp(['Retrieving results from:',pathname])
disp('Starting to load SegResults...');
load([pathname,'SegResults']);
disp('...Finished loading SegResults');

%Save original sequence dimensions
NX = size(RegIm,1);
NY = size(RegIm,2);
NT = size(RegIm,3);

%Optional parameter for the TrackingGUI
params.TrackingRadius = 15;

%Change Directory to save the tracking corrections
cd(pathname)

%% Tracking correction

%save new tracking results with new timestamp
%e.g. ILabelsCorrected_20140213T144649
output = ['ILabelsCorrected_',datestr(now,30)];

IL = load([pathname,'TrackingStart']);

%patch to avoid the increase in x,y dimensions
IL.ILabels = IL.ILabels(1:NX,1:NY,:);

%open the tracking gui
fig = TrackingGUIwOldOK(RegIm,IL.ILabels,CLabels,ColIms,output,params,IL.oktrajs,IL.FramesToRegrow);

% wait for corrections to finish (ie after saving using 's')
uiwait(fig);

%% Final Check if the new size exeeds the previous one!
load(output);

%% if yes reSize and reSave!
ILabels = ILabels(1:NX,1:NY,:);
save(output,'ILabels','FramesToRegrow','oktrajs');