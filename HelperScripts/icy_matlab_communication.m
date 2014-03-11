% Program to try out behavior between matlab and icy
% source: http://icy.bioimageanalysis.org/plugin/Matlab%20X%20server
%
% author:   Davide Heller
% date:     2014-02-25

%% Add plugin path
addpath('/Users/davide/programs/icy_1.3.6.0_updated/plugins/ylemontag/matlabcommunicator');

%% start program
icy_init();

%% Picture an image in icy
icy_imshow(RegIm(:,:,1))

%% Open a temporal sequence in Icy
icy_vidshow(RegIm)

%% Obtain roi sequence drawn on sequence

%% 1.Open image and obtain handle
h_fig = icy_imshow(RegIm(:,:,1),'Image title')

%% 2.Draw polyline roi in icy and then return the mask
[mask, h_roi] = icy_roimask(h_fig);

%% 3.Visualize mask
icy_imshow(mask)

%% Repeat process for video
h_vid = icy_vidshow(RegIm)
[mask, h_roi] = icy_roimask(h_vid);