% Program to make correction iterative. First set the sample to work on
% and then proceed to redo the tracking information.
%
% author:   Davide Heller
% email:    davide.heller@imls.uzh.ch
% date:     2014-02-13

% help: proceed through the selections by pressing cmd + enter

%% SETUP

addpath('/Users/davide/programs/epitools/MatlabScripts')
%make sure matlab has access to this java file!
javaaddpath('/Users/davide/programs/epitools/OME_LOCI_TOOLS/loci_tools.jar')
addpath('/Users/davide/programs/epitools/OME_LOCI_TOOLS') 

%% Repeat tracking correction with manually specified file 

[filename, pathname] = uigetfile('.mat','Select SegResults.mat');

AnaDirec = pathname;

disp(['Retrieving results from:',AnaDirec])

cd(AnaDirec)

%% If this is correct (Check Command Window) proceed to tracking correction

load([AnaDirec,'/SegResults']);

NX = size(RegIm,1);
NY = size(RegIm,2);
NT = size(RegIm,3);

params.TrackingRadius = 15;
%save new tracking results with new timestamp
%e.g. ILabelsCorrected_20140213T144649
output = ['ILabelsCorrected_',datestr(now,30)];

[filename, pathname] = uigetfile('.mat','Select last tracking file');

try
    %open last tracking file
    IL = load([pathname,filename]);
    fig = TrackingGUIwOldOK(RegIm,IL.ILabels,CLabels,ColIms,output,params,IL.oktrajs,IL.FramesToRegrow);
catch
    disp('no previous segmentation')
end

% wait for corrections to finish (ie after saving using 's')
uiwait(fig);
