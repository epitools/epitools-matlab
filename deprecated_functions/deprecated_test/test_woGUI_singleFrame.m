%Function 
% current_script_path = matlab.desktop.editor.getActive().Filename;
% [file_path,~,~] = fileparts(current_script_path);

file_path = pwd;
cd([file_path,'/../EpitoolComponents']);
LoadEpiTools();

cd(file_path);

%% Data Directory Setup (dsp=DataSpecificsPath)

TestData = [pwd,'/SingleFrame'];
BenchmarkDirec = ['SFBenchmark'];

dsp = InspectData(TestData);
 
%% Surface Projection

params.SmoothingRadius = 1.0;          % how much smoothing to apply to original data (1-5)
params.SurfSmoothness1 = 100;           % 1st surface fitting, surface stiffness ~100
params.SurfSmoothness2 = 35;           % 2nd surface fitting, stiffness ~50
params.ProjectionDepthThreshold = 1.2; % how much up/down to gather data from surface
params.InspectResults = false;         % show fit or not
params.Parallel = false;               % Use parallelisation?

Projection(dsp,params);

%% now test that files generated are the same
CompareFiles('SingleFrame/Analysis/ProjIm' , 'SingleFrame/Benchmark/ProjIm');
CompareFiles('SingleFrame/Analysis/Surfaces' , 'SingleFrame/Benchmark/Surfaces');

%% Time Series Registration
params.SkipFirstRegStep = true;

Registration(dsp, params); 

%%
% now test that files generated are the same
CompareFiles('SingleFrame/Analysis/RegIm' , 'SingleFrame/Benchmark/RegIm');

%% Segmentation parameters:
params.mincellsize=25;          % area of cell in pixels
params.sigma1=1;                % smoothing to be applied (need to get rid of as much noise as poss without loosing the actual features we are looking for)
params.threshold = 25;

% Grow cells
params.sigma3=2;
params.LargeCellSizeThres = 3000;
params.MergeCriteria = 0.35;

% Final joining
params.IBoundMax = 30;          % 30 for YM data

% Performance Options (show=show_steps)
params.debug = false;
params.Parallel  = false;

params.SingleFrame = false;

Segmentation(dsp,params);

% now test that files generated are the same
CompareFiles('SingleFrame/Analysis/SegResults', 'SingleFrame/Benchmark/SegResults');
CompareFiles('SingleFrame/Analysis/TrackingStart', 'SingleFrame/Benchmark/TrackingStart');
% 
% % load('/Users/alexandertournier/Documents/CRUK-UCL/Yanlan/epitools/Tests/SingleFrame/Analysis/SegResults.mat');
% % figure, imshow(ColIms)