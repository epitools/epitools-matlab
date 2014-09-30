%% SETUP

current_script_path = matlab.desktop.editor.getActive().Filename;
[file_path,file_name,file_ext] = fileparts(current_script_path);
cd(file_path)

% set epitool script location
addpath([fileparts(file_path),'/MatlabScripts'])
javaaddpath([fileparts(file_path),'/OME_LOCI_TOOLS/loci_tools.jar'])
addpath([fileparts(file_path),'/OME_LOCI_TOOLS'])

%% Load data

[filename, pathname] = uigetfile('.tif','Select Input Image [format: 8-bit single channel tif]');
image_file = [pathname,filename];
RegIm = imread(image_file);

%% Inspect loaded image

figure;
imshow(RegIm,[])

%% SEGMENTATION 

% Segmentation parameters:
params.mincellsize=25;          % area of cell in pixels
params.sigma1=0.5;              % smoothing to be applied (need to get rid of as much noise as poss without loosing the actual features we are looking for)
params.threshold = 25;
% %mergeseeds:
% params.maxDistance=20;        % max distance between seeds ~= cell diameter
% params.maxGradient=.1;        % 
% params.iterations=6;
% params.sigma2=1;
% grow cells
params.sigma3=0.1;
params.LargeCellSizeThres = 3000;
params.MergeCriteria = 0.35;
%final joining
params.IBoundMax = 30;          % 30 for YM data

% show steps
params.show = false;
params.Parallel  = false;
params.frame_no = 1;

[ILabels , CLabels , ColIms] = SegmentImDebug(RegIm,params.show,params);

%% Look at results

figure;
imshow(ColIms,[])

%% If results are satisfying save Regim and 

AnaDirec = uigetdir('~','Define where to save the Segmentation Results');

NX = size(RegIm,1);
NY = size(RegIm,2);
NT = size(RegIm,3);

save([AnaDirec,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','params','NX','NY','NT','-v7.3')

%% Constrain segmentation to a polygon - 
% Draw polygon and confirm with right-click 'form mask' 

figure;
imshow(RegIm,[]);
BW = roipoly;

%% apply the drawn mask 

CLabelsEll = zeros(size(RegIm));

for f = 1 : size(RegIm,3)
    I1 = CLabels(:,:,f);
    I1(BW < 1) = 0;
    Ls = unique(I1);
    
    I2 = CLabels(:,:,f);
    I2(~ismember(I2,Ls)) =0;
    CLabelsEll(:,:,f) = I2;
end

figure;
imshow(CLabelsEll,[])

%% Save ellipse selection changes, make sure to save the old SegResults as backup in case

save([AnaDirec,'/CLabelsBKP'],'CLabels');

CLabels = CLabelsEll;

save([AnaDirec,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','params','-v7.3');
