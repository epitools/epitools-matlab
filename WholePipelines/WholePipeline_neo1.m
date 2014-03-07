%% SETUP

addpath('/Users/l48imac2/Documents/Userdata/Simon/Epitools/MatlabScripts')
%make sure matlab has access to this java file!
javaaddpath('/Users/l48imac2/Documents/Userdata/Simon/Epitools/OME_LOCI_TOOLS/loci_tools.jar')
addpath('/Users/l48imac2/Documents/Userdata/Simon/Epitools/OME_LOCI_TOOLS') 

%% READING ORIGINAL MICROSCOPY DATA

DataDirec = '/Users/l48imac2/Documents/Userdata/Simon/decadGFP_103h_63XNE0_JHIII_20130912_84346 AM/1/Neo1_huygens_output/';

% create directory where to store results of analysis
AnaDirec = [DataDirec,'/Analysis'];
mkdir(AnaDirec)

%Filemask = 'frame_085b_525e963c9e3a7_hrm.tif'; %same for 028 and 068, 089
%because of bright spot correction
Filemask = '.tif';

lst = dir(DataDirec);  

%% find out list index of first file based on Filemask

first_index = 0;

for i =1:length(lst)
    
    %first indeces will most likely be folders and non-relevant files
    %so skip
    if isempty(strfind(lst(i).name,Filemask)); 
        continue; 
    else
        first_index = i;
        break;
    end;

end

%% read first file

FullDataFile = [DataDirec,'/',lst(first_index).name];
Series = 1;
res = ReadMicroscopyData(FullDataFile, Series);

%% Setup parameters for Projection
fprintf('Started projection at %s',datestr(now));

%Paramaters
SmoothingRadius = 1.;           % how much smoothing to apply to original data (1-5)
SurfSmoothness1 = 30;           % 1st surface fitting, surface stiffness ~100
SurfSmoothness2 = 20;           % 2nd surface fitting, stiffness ~50
ProjectionDepthThreshold = 1.2; % how much up/down to gather data from surface

%Number of time points to be analyzed
NT = res.NT;
%NT = 3;

RegIm = zeros(res.NY,res.NX,NT);
Surfaces = zeros(res.NY,res.NX,NT);
ProjIm = zeros(res.NY,res.NX,NT);

InspectResults = false;         % show fit or not

Series = 1;

%matlabpool 2
d = 0;

% For loop for all files in the folder (lst) and second parfor for all timepoints

for i =1:length(lst)
    if isempty(strfind(lst(i).name,Filemask)); continue; end;
    FullDataFile = [DataDirec,'/',lst(i).name];
    res = ReadMicroscopyData(FullDataFile, Series);
    res.images = squeeze(res.images); % get rid of empty 
    fprintf('Working on %s\n', lst(i).name);
   
    %information seems to not be transmitted correctly 10 time points
    %appear to be presente while there are only 3, CHECK [ ] 
    for f = 1:res.NT 
        ImStack = res.images(:,:,:,f);
        [im,Surf] = createProjection(ImStack,SmoothingRadius,ProjectionDepthThreshold,SurfSmoothness1,SurfSmoothness2,InspectResults);
        ProjIm(:,:,f+d) = im;
        Surfaces(:,:,f+d) = Surf;
    end
    d=d+res.NT;
    save([AnaDirec,'/ProjIm'],'ProjIm')
    save([AnaDirec,'/Surfaces'],'Surfaces')
end
% inspect results
StackView(ProjIm);

%matlabpool close

fprintf('Finished projection at %s',datestr(now));

%% REGISTRATION
%matlabpool 2

RegIm = RegisterStack(ProjIm);

% inspect results
StackView(RegIm);

%saving results
save([AnaDirec,'/RegIm'],'RegIm');

%matlabpool close


%% CLAHE - Contrast-Limited Adaptive Histogram Equalization

%help: http://www.mathworks.ch/ch/help/images/ref/adapthisteq.html

fprintf('Started CLAHE at %s',datestr(now));

%pre-allocate output
RegIm_clahe = zeros(size(RegIm,1), size(RegIm,2), size(RegIm,3), 'double');

%needs prior conversion for method
RegIm_uint8 = zeros(size(RegIm,2), size(RegIm,2), 'uint8');

%pre-alloacation for speed
RegIm_clahe_uint8 = zeros(size(RegIm,2), size(RegIm,2), 'uint8');

for i=1:size(RegIm,3)
    %parameter needs to be adapted for specific image input: uint16>uint8
    RegIm_uint8 = uint8(RegIm(:,:,i));
    RegIm_clahe_uint8 = adapthisteq(RegIm_uint8,'NumTiles',[70 70],'ClipLimit',0.02);
    RegIm_clahe(:,:,i) = double(RegIm_clahe_uint8); 
end


StackView(RegIm_clahe);

fprintf('Stopped CLAHE at %s',datestr(now));

%% SEGMENTATION modified for clahe!
fprintf('Started SEGMENTATION at %s',datestr(now));

%matlabpool 4

% Segmentation parameters:
params.mincellsize=25;          % area of cell in pixels
params.sigma1=1;                % smoothing to be applied (need to get rid of as much noise as poss without loosing the actual features we are looking for)
params.threshold = 25;
% %mergeseeds:
% params.maxDistance=20;          % max distance between seeds ~= cell diameter
% params.maxGradient=.1;         % 
% params.iterations=6;
% params.sigma2=1;
% grow cells
params.sigma3=2;
params.LargeCellSizeThres = 3000;
params.MergeCriteria = 0.35;
%final joining
params.IBoundMax = 30;          % 30 for YM data

% show steps
params.show = false;
params.Parallel  = true;

[ILabels , CLabels , ColIms] = SegmentStack(RegIm_clahe, params);

fprintf('Stopped SEGMENTATION at %s',datestr(now));

%StackView(ColIms)

%% If successful save RegIm_clahe as Regim and save 

RegIm = RegIm_clahe;

NX = size(RegIm,1);
NY = size(RegIm,2);
NT = size(RegIm,3);

save([AnaDirec,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','params','NX','NY','NT','-v7.3')

matlabpool close


%% Add elipse crop to avoid tracking false structures. (not needed for deconvolved images)

%BW = GetEllipse(RegIm(:,:,1));

%alternative polygonal ROI
figure;
imshow(RegIm(:,:,1),[]);
BW = roipoly;

CLabelsEll = zeros(size(RegIm));

for f = 1 : size(RegIm,3)
    I1 = CLabels(:,:,f);
    I1(BW < 1) = 0;
    Ls = unique(I1);
    
    I2 = CLabels(:,:,f);
    I2(~ismember(I2,Ls)) =0;
    CLabelsEll(:,:,f) = I2;
end
StackView(CLabelsEll)


%% Save ellipse selection changes, make sure to save the old SegResults as backup in case

save([AnaDirec,'/CLabelsBKP'],'CLabels');

CLabels = CLabelsEll;

save([AnaDirec,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','params','-v7.3');


%% TRACKING (first time - single run)

load([AnaDirec,'/SegResults']);

NX = size(RegIm,1);
NY = size(RegIm,2);
NT = size(RegIm,3);

params.TrackingRadius = 15;
output = ['ILabelsCorrected_',datestr(now,30)];

try
    P = load([AnaDirec,'/SegResultsCorrected']);
    disp('Using previous segmentation as baseline');
    %changed the Tracking framework such that it can read previous OK
    %trajectories
    fig = TrackingGUIwOldOK(RegIm,P.ILabels,P.CLabels,P.ColIms,output,params,IL.oktrajs);
    
    CLabels = P.CLabels;       % using previous segmemtation
    ColIms = P.ColIms;
catch
    disp('no previous segmentation')
    fig = TrackingGUI(RegIm,ILabels,CLabels,ColIms,output,params);
end

% wait for corrections to finish (ie after saving using 's')
uiwait(fig);

%TrackingGUI takes care of saving a copy of the changes in the current
%matlab working directory [BACKUP if needed!]

%% REPEAT tracking correction with manually specified file 
% (skip or run as many times as needed)

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

%% load data (only if working in new matlab session)

load([AnaDirec,'/SegResults']);
[filename, pathname] = uigetfile('.mat','Select last tracking file');

output = [pathname, filename];

%% now resegmenting the frames which need it!

%given the reduced amuont of of frames parallelization is manually set
%as otherwise always all frames would be resegmented. Judge according
%to the case if to activate or not

params.Parallel = true; 

if(params.Parallel)
    matlabpool 3
end

fprintf('Started SEGMENTATION at %s\n',datestr(now));

IL = load(output);
[ILabels , CLabels , ColIms] = SegmentStack( RegIm , params , IL.ILabels ,CLabels, ColIms, IL.FramesToRegrow );

fprintf('Stopped SEGMENTATION at %s\n',datestr(now));

if(params.Parallel)
    matlabpool close
end

% added version option to save ColIms as well /skipped otherwise, added 
save([AnaDirec,'/SegResultsCorrected'], 'RegIm','ILabels', 'CLabels' ,'ColIms','params','NX','NY','NT','IL','-v7.3' );

%% TESTING RESULTS SECTION / enhance for multiple correction procedure

BackupDir = [AnaDirec,'/BKP'];

%load([BackupDir,'/ColImsBKP']);
%load([BackupDir,'/IlabelsCorrected']);

%% reload previous results first / not available as ColIms was never saved before tracking (v7.3 MOD)

fig = TrackingGUI(RegIm,IL.ILabels,CLabels,ColIms,output,params);
uiwait(fig);

%% new results, 

fig = TrackingGUI(RegIm,P.ILabels,P.CLabels,ColIms,output,params);
uiwait(fig);

%% old results with old OKs

fig = TrackingGUIwOldOK(RegIm,IL.ILabels,CLabels,ColIms,output,params,IL.oktrajs);
uiwait(fig);


%% new results with old OKs

fig = TrackingGUIwOldOK(RegIm,ILabels,CLabels,ColIms,output,params,IL.oktrajs);
uiwait(fig);


%% Close workers

StackView(ColIms);
StackView(CLabels);
