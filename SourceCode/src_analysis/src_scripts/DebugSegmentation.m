%% Segmentation debug

%retrieve needed files from current script location
%requires Matlab 7+
current_script_path = matlab.desktop.editor.getActive().Filename;
fprintf('Script location:%s\n',current_script_path);

[file_path,file_name,file_ext] = fileparts(current_script_path);
cd(file_path)

addpath([fileparts(file_path),'/MatlabScripts'])
%make sure matlab has access to this java file!
javaaddpath([fileparts(file_path),'/OME_LOCI_TOOLS/loci_tools.jar'])
addpath([fileparts(file_path),'/OME_LOCI_TOOLS']) 

%% Setup icy

addpath('/Users/davide/programs/icy_1.3.6.0_updated/plugins/ylemontag/matlabcommunicator');
icy_init();

%% Load files

%segmentation
[filename, pathname] = uigetfile('.mat','Select segmentation file');
segmentation_file = [pathname,filename];
load(segmentation_file);

%% if available tracking
%tracking correction
[filename, pathname] = uigetfile('.mat','Select last tracking file');
output = [pathname, filename];
IL = load(output);

%% Select frame

frame_no = 9;

im = double(RegIm(:,:,frame_no));

%% or custom define

frame_no = 1;
im = OreR_30hAPF_aSRF_05_apical_ch00;

%% if label information is available repeat
labels = IL.ILabels(:,:,frame_no);

%% Crop window, keep in mind matlab (x,y) is (y,x) in icy

% dividing cell in frame 4
% icy_x = 730:830;
% icy_y = 580:680;

% dividing cell in frame 8
% icy_x = 760:860;
% icy_y = 580:680;

% dividing cell in frame 8
% icy_x = 450:550;
% icy_y = 630:730;

% dividing cell in frame 7
% icy_x = 690:790;
% icy_y = 410:510;

% dividing cell in frame 9
icy_x = 770:870;
icy_y = 600:700;


im = im(icy_y,icy_x,1);
labels = labels(icy_y,icy_x,1);

%% Change parameters

%initial seed parameters
params.sigma1 = 5;
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

%% Segmentation (no previous tracking!)
[Ilabel ,Clabel,ColIm] = SegmentImDebug(im,is_debug,params);

%% if tracking information is available
[Ilabel ,Clabel,ColIm] = SegmentImDebug(im,is_debug,params,labels);

%% Repetive parameter testing (be shure to limit the code in this case)
for sigma_i=linspace(0.1,1,10)
    params.MergeCriteria = sigma_i;
    [Ilabel ,Clabel,ColIm] = SegmentImDebug(im,is_debug,params);
end