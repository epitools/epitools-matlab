%% Segmentation debug

%% Setup icy

addpath('/Users/davide/programs/icy_1.3.6.0_updated/plugins/ylemontag/matlabcommunicator');
icy_init();

%% Load files

%segmentation
load([AnaDirec,'/SegResults']);

%tracking correction
[filename, pathname] = uigetfile('.mat','Select last tracking file');
output = [pathname, filename];
IL = load(output);

%% Select frame

frame_no = 4;

im = double(RegIm(:,:,frame_no));
labels = IL.ILabels(:,:,frame_no);

%% Crop window, keep in mind matlab (x,y) is (y,x) in icy

% dividing cell in frame 4
icy_x = 730:830;
icy_y = 580:680;

% dividing cell in frame 8
% icy_x = 760:860;
% icy_y = 580:680;

% dividing cell in frame 8
% icy_x = 450:550;
% icy_y = 630:730;

im = im(icy_y,icy_x,1);
labels = labels(icy_y,icy_x,1);

%% Change parameters

%initial seed parameters
params.sigma1 = 1;
params.MergeCriteria = 0.35;
params.mincellsize = 25;

%gaussian blur for seed grow parameter
%the lower, the less the image is blurred to begin with
params.sigma3 = 0.1;

%poor seed elimination parameter
params.IBoundMax = 30;

%optional parameters
params.show = 0;
params.Parallel = 1;
params.LargeCellSizeThres = 3000;
params.TrackingRadius = 15;
params.threshold = 25;
params.frame_no = frame_no;

%show debugging information
is_debug = true;

%Segmentation

[Ilabel ,Clabel,ColIm] = SegmentImDebug(im,is_debug,params,labels);

%% Repetive parameter testing (be shure to limit the code in this case)
for sigma_i=linspace(0.1,1,10)
    params.sigma3 = sigma_i;
    [Ilabel ,Clabel,ColIm] = SegmentImDebug(im,is_debug,params,labels);
end