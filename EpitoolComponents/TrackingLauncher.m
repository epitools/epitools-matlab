function TrackingLauncher(stgObj)
%TrackingGUILauncher launches the interface that allows the user to correct
%the segmentation results of the Epitools segmnetation. Find more
%explanation in TrackingGUIwOldOK.m 

progressbar('Loading SegResults...(might take some minutes)')

% it is more convenient to recall the setting file with as shorter variable
% name: stgModule 
tmpStgObj = stgObj.analysis_modules.Tracking.settings;

tmpSegObj = load([stgObj.data_analysisdir,'/SegResults']);


%load([AnaDirec,'/SegResults']);

%Save original sequence dimensions
NX = size(tmpSegObj.RegIm,1);
NY = size(tmpSegObj.RegIm,2);
NT = size(tmpSegObj.RegIm,3);

%Optional parameter for the TrackingGUI
%tmpStgObj.TrackingRadius = tracking_radius;

output = ['ILabelsCorrected_',datestr(now,30)];

progressbar(1);

%retrieve previous tracking file
[filename, pathname] = uigetfile('.mat','Select last tracking file');
IL = load([pathname,filename]);
disp(['Current tracking file: ',filename]);

%patch to avoid the increase in x,y dimensions
IL.ILabels = IL.ILabels(1:NX,1:NY,:);

%open the tracking gui
fig = TrackingGUIwOldOK(tmpSegObj.RegIm,IL.ILabels,tmpSegObj.CLabels,tmpSegObj.ColIms,...
    output,tmpStgObj,IL.oktrajs,IL.FramesToRegrow);

% wait for corrections to finish (ie after saving using 's')
uiwait(fig);

end

