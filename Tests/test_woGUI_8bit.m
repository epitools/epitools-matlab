%Test function for headless execution of EpiTools

file_path = pwd;
cd([file_path,'/../SourceCode']);
LoadEpiTools();

cd(file_path);

%% Data setup (ds = Data Settings object)

TestData = [pwd,'/8bitDataSet/'];

BenchmarkDirec = 'Benchmark';

ds = settings();

ds.data_analysisdir = [TestData,'Analysis'];
ds.data_imagepath = [TestData,'test_set.tif'];
ds.platform_units = 1;
 
%% Surface Projection

strModuleName = 'Projection';
ds.CreateModule(strModuleName);

% how much smoothing to apply to original data - default 1 [1-5]
ds.AddSetting(strModuleName, 'SmoothingRadius', 1.0); 
% 1st surface fitting, surface stiffness - default 100 [50 - 200]
ds.AddSetting(strModuleName, 'SurfSmoothness1', 100);        
% 2nd surface fitting, stiffness          - default 30 [10 - 50]
ds.AddSetting(strModuleName, 'SurfSmoothness2', 35);
% how much up/down to gather data from surface - default 1.2 [1 - 3]
ds.AddSetting(strModuleName, 'ProjectionDepthThreshold', 1.2);
% show fit or not
ds.AddSetting(strModuleName, 'InspectResults', false);

Projection(ds);

CheckInputType(ds, 'ProjIm');

%% now test that files generated are the same
CompareFiles('Data/Analysis/ProjIm' , 'Data/Benchmark/ProjIm');
CompareFiles('Data/Analysis/Surfaces' , 'Data/Benchmark/Surfaces');

%% Time Series Registration
strModuleName = 'Stack_Registration';
ds.CreateModule(strModuleName);

ds.AddSetting(strModuleName, 'SkipFirstRegStep', true); 
ds.AddSetting(strModuleName, 'useStackReg', true); 

Registration(ds); 

CheckInputType(ds, 'RegIm');

%% now test that files generated are the same
CompareFiles('Data/Analysis/RegIm' , 'Data/Benchmark/RegIm');

%% Apply CLAHE
strModuleName = 'Contrast_Enhancement';
ds.CreateModule(strModuleName);

ds.AddSetting(strModuleName, 'enhancement_limit', 0.02);

ImproveContrast(ds);

CheckInputType(ds, 'RegIm');

%% Segmentation parameters:
strModuleName = 'Segmentation';
ds.CreateModule(strModuleName);

% area of cell in pixels
ds.AddSetting(strModuleName, 'mincellsize', 25); 
% smoothing to be applied, needed to get rid of as much noise as poss 
% without loosing the actual features we are looking for)
ds.AddSetting(strModuleName, 'sigma1', 1);         
ds.AddSetting(strModuleName, 'threshold', 25);               

% Grow cells
ds.AddSetting(strModuleName, 'sigma3', 2);
ds.AddSetting(strModuleName, 'LargeCellSizeThres', 3000);
% default 0.35 .. have to play with it
ds.AddSetting(strModuleName, 'MergeCriteria', 0.35);   

% Final joining ,  30 for YM data
ds.AddSetting(strModuleName, 'IBoundMax', 30); 

% Performance Options (show=show_steps)
ds.AddSetting(strModuleName, 'debug', false);
ds.AddSetting(strModuleName, 'Parallel', false);
ds.AddSetting(strModuleName, 'SingleFrame', false);


Segmentation(ds);

CheckInputType(ds, 'SegResults');

%% now test that files generated are the same
CompareFiles('Data/Analysis/SegResults', 'Data/Benchmark/SegResults');
CompareFiles('Data/Analysis/TrackingStart', 'Data/Benchmark/TrackingStart');

% load('/Users/alexandertournier/Documents/CRUK-UCL/Yanlan/epitools/Tests/Data/Analysis/SegResults.mat');
% StackView(ColIms);
