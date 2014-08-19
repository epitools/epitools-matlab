function [varargout] =  TrackingLauncher(stgObj)
%TrackingGUILauncher launches the interface that allows the user to correct
%the segmentation results of the Epitools segmnetation. Find more
%explanation in TrackingGUIwOldOK.m 

progressbar('Loading SegResults...(might take some minutes)')

% it is more convenient to recall the setting file with as shorter variable
% name: stgModule 
tmpStgObj = stgObj.analysis_modules.Tracking.settings;

tmpSegObj = load([stgObj.data_analysisindir,'/SegResults']);


%load([AnaDirec,'/SegResults']);

%Save original sequence dimensions
NX = size(tmpSegObj.RegIm,1);
NY = size(tmpSegObj.RegIm,2);
NT = size(tmpSegObj.RegIm,3);

%Optional parameter for the TrackingGUI
%tmpStgObj.TrackingRadius = tracking_radius;

strFilename = strcat('ILabelsCorrected_',datestr(now,30));
output = [stgObj.data_analysisoutdir,'/',strFilename];

progressbar(1);

%retrieve tracking file

listFilesInput = dir(stgObj.data_analysisindir);
ArrayFileNames = extractfield(listFilesInput, 'name');

% If tracking module has been executed already in the past
if (~isempty(strfind(ArrayFileNames,'ILabelsCorrected')))

    [filename, pathname] = uigetfile(strcat(stgObj.data_analysisindir,'/','*.mat'),'Select last tracking file');
    
% If tracking module has not been executed aready... then in the folder you
% might find TrackingStart.mat
elseif (~isempty(strfind(ArrayFileNames,'TrackingStart')))
    
       filename =  '/TrackingStart.mat'
       pathname =  stgObj.data_analysisindir;

% If segmentation module has not been executed
else
    return;
    
end

if((isempty(filename) || isempty(pathname) ) == 0)
    IL = load([pathname,filename]);
    disp(['Current tracking file: ',filename]);

    %patch to avoid the increase in x,y dimensions
    IL.ILabels = IL.ILabels(1:NX,1:NY,:);

    %open the tracking gui
    fig = TrackingGUIwOldOK(tmpSegObj.RegIm,...
                            IL.ILabels,...
                            tmpSegObj.CLabels,...
                            tmpSegObj.ColIms,...
                            output,...
                            tmpStgObj,...
                            IL.oktrajs,...
                            IL.FramesToRegrow);

    % wait for corrections to finish (ie after saving using 's')
    uiwait(fig);
    
end

%% Saving results
stgObj.AddResult('Tracking','tracking_file',strFilename);

end

