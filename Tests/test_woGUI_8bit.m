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

mdname = 'Projection';
ds.CreateModule(mdname);

% how much smoothing to apply to original data - default 1 [1-5]
ds.AddSetting(mdname, 'SmoothingRadius', 1.0); 
% 1st surface fitting, surface stiffness - default 100 [50 - 200]
ds.AddSetting(mdname, 'SurfSmoothness1', 100);        
% 2nd surface fitting, stiffness          - default 30 [10 - 50]
ds.AddSetting(mdname, 'SurfSmoothness2', 35);
% how much up/down to gather data from surface - default 1.2 [1 - 3]
ds.AddSetting(mdname, 'ProjectionDepthThreshold', 1.2);
% show fit or not
ds.AddSetting(mdname, 'InspectResults', false);

Projection(ds);

CheckInputType(ds, 'ProjIm');

%% now test that files generated are the same
CompareFiles('Data/Analysis/ProjIm' , 'Data/Benchmark/ProjIm');
CompareFiles('Data/Analysis/Surfaces' , 'Data/Benchmark/Surfaces');

%% Time Series Registration
mdname = 'Stack_Registration';
ds.CreateModule(mdname);

ds.AddSetting(mdname, 'SkipFirstRegStep', true); 
ds.AddSetting(mdname, 'useStackReg', true); 

Registration(ds); 

CheckInputType(ds, 'RegIm');

%% now test that files generated are the same
CompareFiles('Data/Analysis/RegIm' , 'Data/Benchmark/RegIm');

%% Segmentation parameters:
mdname = 'Segmentation';
ds.CreateModule(mdname);

% area of cell in pixels
ds.AddSetting(mdname, 'mincellsize', 25); 
% smoothing to be applied, needed to get rid of as much noise as poss 
% without loosing the actual features we are looking for)
ds.AddSetting(mdname, 'sigma1', 1);         
ds.AddSetting(mdname, 'threshold', 25);               

% Grow cells
ds.AddSetting(mdname, 'sigma3', 2);
ds.AddSetting(mdname, 'LargeCellSizeThres', 3000);
% default 0.35 .. have to play with it
ds.AddSetting(mdname, 'MergeCriteria', 0.35);   

% Final joining ,  30 for YM data
ds.AddSetting(mdname, 'IBoundMax', 30); 

% Performance Options (show=show_steps)
ds.AddSetting(mdname, 'debug', false);
ds.AddSetting(mdname, 'Parallel', false);
ds.AddSetting(mdname, 'SingleFrame', false);


Segmentation(ds);

CheckInputType(ds, 'SegResults');

%% now test that files generated are the same
CompareFiles('Data/Analysis/SegResults', 'Data/Benchmark/SegResults');
CompareFiles('Data/Analysis/TrackingStart', 'Data/Benchmark/TrackingStart');

% load('/Users/alexandertournier/Documents/CRUK-UCL/Yanlan/epitools/Tests/Data/Analysis/SegResults.mat');
% StackView(ColIms);
