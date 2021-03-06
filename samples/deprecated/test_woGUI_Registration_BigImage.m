%Function 
% current_script_path = matlab.desktop.editor.getActive().Filename;
% [file_path,~,~] = fileparts(current_script_path);

file_path = pwd;
cd([file_path,'/../EpitoolComponents']);
LoadEpiTools();

cd(file_path);

%% Data Directory Setup (dsp=DataSpecificsPath)

TestData = [pwd,'/FullRegistrationTestSet'];
BenchmarkDirec = ['Benchmark'];

dsp = InspectData(TestData);


%% Time Series Registration
params.SkipFirstRegStep = false;
AnaDirec = 'FullRegistrationTestSet/Analysis';

load([AnaDirec,'/ProjIm']);

progressbar('Registering images...');

RegIm = RegisterStack(ProjImT20,params);

progressbar(1);

% inspect results
StackView(RegIm);


%saving results
save([AnaDirec,'/RegIm'],'RegIm');

%%
% now test that files generated are the same
CompareFiles('Data/Analysis/RegIm' , 'Data/Benchmark/RegIm');

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
CompareFiles('Data/Analysis/SegResults', 'Data/Benchmark/SegResults');
CompareFiles('Data/Analysis/TrackingStart', 'Data/Benchmark/TrackingStart');

% load('/Users/alexandertournier/Documents/CRUK-UCL/Yanlan/epitools/Tests/Data/Analysis/SegResults.mat');
% StackView(ColIms);
