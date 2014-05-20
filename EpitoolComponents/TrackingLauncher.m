function TrackingLauncher(DataSpecificsPath,tracking_radius)
%TrackingGUILauncher launches the interface that allows the user to correct
%the segmentation results of the Epitools segmnetation. Find more
%explanation in TrackingGUIwOldOK.m 

progressbar('Loading SegResults...(might take some minutes)')

load(DataSpecificsPath);
load([AnaDirec,'/SegResults']);

%Save original sequence dimensions
NX = size(RegIm,1);
NY = size(RegIm,2);
NT = size(RegIm,3);

%Optional parameter for the TrackingGUI
params.TrackingRadius = tracking_radius;

output = ['ILabelsCorrected_',datestr(now,30)];

progressbar(1);

%retrieve previous tracking file
[filename, pathname] = uigetfile('.mat','Select last tracking file');
IL = load([pathname,filename]);
disp(['Current tracking file: ',filename]);

%patch to avoid the increase in x,y dimensions
IL.ILabels = IL.ILabels(1:NX,1:NY,:);

%open the tracking gui
fig = TrackingGUIwOldOK(RegIm,IL.ILabels,CLabels,ColIms,...
    output,params,IL.oktrajs,IL.FramesToRegrow);

% wait for corrections to finish (ie after saving using 's')
uiwait(fig);

end

