%% SETUP

addpath('/Users/l48imac2/Documents/Userdata/Simon/Epitools/MatlabScripts')
%make sure matlab has access to this java file!
javaaddpath('/Users/l48imac2/Documents/Userdata/Simon/Epitools/OME_LOCI_TOOLS/loci_tools.jar')
addpath('/Users/l48imac2/Documents/Userdata/Simon/Epitools/OME_LOCI_TOOLS')

%matlabpool      % setup multithreading capacity

%% READING ORIGINAL MICROSCOPY DATA

DataDirec = '/Users/l48imac2/Documents/Userdata/Simon/decadGFP_103h_63XNE0_JHIII_20130912_84346 AM/0/h3_separated_files_omeConverter/separated';

% create directory where to store results of analysis
AnaDirec = [DataDirec,'/Analysis'];
mkdir(AnaDirec)


Filemask = 'neo0_T000';

lst = dir(DataDirec);  

%% read first file

FullDataFile = [DataDirec,'/',lst(4).name];
Series = 1;
res = ReadMicroscopyData(FullDataFile, Series);

%%

%Paramaters
SmoothingRadius = 1.;           % how much smoothing to apply to original data (1-5)
SurfSmoothness1 = 50;           % 1st surface fitting, surface stiffness ~100
SurfSmoothness2 = 30;           % 2nd surface fitting, stiffness ~50
ProjectionDepthThreshold = 1.2; % how much up/down to gather data from surface

%Number of time points to be analyzed
NT = res.NT;
%NT = 3;

RegIm = zeros(res.NY,res.NX,NT);
Surfaces = zeros(res.NY,res.NX,NT);
ProjIm = zeros(res.NY,res.NX,NT);

InspectResults = false;         % show fit or not

Series = 1;

%matlabpool 4
d = 0;

%%
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
%% REGISTRATION
matlabpool 2

RegIm = RegisterStack(ProjIm);

% inspect results
StackView(RegIm);

%saving results
save([AnaDirec,'/RegIm'],'RegIm');
matlabpool close



%% SEGMENTATION


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
params.IBoundMax = 80;          % 30 for YM data

% show steps
params.show = false;
params.Parallel  = true;

[ILabels , CLabels , ColIms] = SegmentStack(RegIm, params);

StackView(ColIms)

save([AnaDirec,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','params')

% save([AnaDirec,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','params','NX','NY','NT')


%% Add elipse crop to avoid tracking false structures.

BW = GetEllipse(RegIm(:,:,1));

CLabelsEll = zeros(size(RegIm));

for f = 1 : 100
    I1 = CLabels(:,:,f);
    I1(BW < 1) = 0;
    Ls = unique(I1);
    
    I2 = CLabels(:,:,f);
    I2(~ismember(I2,Ls)) =0;
    CLabelsEll(:,:,f) = I2;
end
StackView(CLabelsEll)

%% TRACKING

load([AnaDirec,'/SegResults']);

params.TrackingRadius = 15;
output = 'ILabelsCorrected';

try
    P = load([AnaDirec,'/SegResultsCorrected']);
    disp('Using previous segmentation as baseline');
    fig = TrackingGUI(RegIm,P.ILabels,P.CLabels,P.ColIms,output,params);
    
    CLabels = P.CLabels;       % using previous segmemtation
    ColIms = P.ColIms;
catch
    disp('no previous segmentation')
    fig = TrackingGUI(RegIm,ILabels,CLabels,ColIms,output,params);
end

% wait for corrections to finish (ie after saving using 's')
uiwait(fig);

% now resegmenting the frames which need it!
IL = load(output);
[ILabels , CLabels , ColIms] = SegmentStack( RegIm , params , IL.ILabels ,CLabels, ColIms, IL.FramesToRegrow );
    
save([AnaDirec,'/SegResultsCorrected'], 'RegIm','ILabels', 'CLabels' ,'ColIms','params','NX','NY','NT');

StackView(ColIms);
StackView(CLabels);


