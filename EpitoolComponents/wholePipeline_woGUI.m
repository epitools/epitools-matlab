%Function version of neo0_trial

LoadEpiTools();

%% Data Directory Setup (dsp=DataSpecificsPath)

dsp = InspectData('/Users/davide/data/neo/0/gui_trial');
 
%% Surface Projection

SmoothingRadius = 1.;           % how much smoothing to apply to original data (1-5)
SurfSmoothness1 = 30;           % 1st surface fitting, surface stiffness ~100
SurfSmoothness2 = 20;           % 2nd surface fitting, stiffness ~50
ProjectionDepthThreshold = 1.2; % how much up/down to gather data from surface

Projection(dsp,1,30,20,1.2);

%% Time Series Registration

Registration(dsp);

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
params.show = false;
params.Parallel  = true;

Segmentation(dsp,params);