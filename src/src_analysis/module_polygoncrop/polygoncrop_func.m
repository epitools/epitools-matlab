function [status, argout] =  polygoncrop_func(input_args, varargin)
%SEGMENTATION This function segments the image
% ------------------------------------------------------------------------------
% PREAMBLE
%
% Segmentation procedure to detect the individual cells in the image and find the 
% boundaries with a seed based region growing algorithm. The input image is assumed 
% to have high intensity membrane signal on low intensity background
%
% INPUT
%   1. input_args:  variable containing the analysis object
%   2. varargin:    variable containing extra parameters for ref association
%                   during output formatting (might not be implemented)
%
% OUTPUT
%   1. status:  status elaboration (0  executed correctly; > 0 fatal error)
%   2. argout:  variable containing a structure with output objects, description
%               and ref association
%
% REFERENCES
%
% AUTHOR:   Alexander Tournier (alexander.tournier@cancer.org.uk)
%           Andreas Hoppe (A.Hoppe@kingston.ac.uk)
%           Davide Martin Heller (davide.heller@imls.uzh.ch)
%           Lorenzo Gatti (lorenzo.gatti@alumni.ethz.ch)
%
% DATE:     02.09.14 V0.1 for EpiTools 0.1 beta
%           05.12.14 V0.2 for EpiTools 2.0 beta
%           29.01.15 V0.3 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.
%
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
%% Retrieve supplementary arguments
if (nargin<2); varargin(1) = {'POLYMASKIMAGEPATH'};varargin(2) = {'CROPPEDIMAGEPATH'};varargin(3) = {'SETTINGS'};end
%% Procedure initialization
status = 1;
%% Retrieve parameter data
% it is more convenient to recall the setting file with as shorter variable
% name: stgModule
% TODO: input_args{strcmp(input_args(:,1),'SmoothingRadius'),2}
handleSettings = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
%% Remapping
% it is more convenient to recall the setting file with a shorter variable
% name: stgModule 
stgObj = getVariable4Memory(handleSettings);
% -------------------------------------------------------------------------
% Log status of current application status
log2dev('******************* POLYGON CROP MODULE *******************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.3.1-Jan15 $ Date: 2015/01/29 12:00:15       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started polygon crop module', 'INFO');
% -------------------------------------------------------------------------  
% Load data structures needed for mask generation
tmpSegObj = load([stgObj.data_analysisindir,'/SegResults']);
tmpRegObj = load([stgObj.data_analysisindir,'/RegIm']);
% Generate the mask and the cropped label image
[polygonal_mask, cropped_CellLabelIm] = PolygonCrop(tmpRegObj.RegIm, tmpSegObj.CLabels);
waitfor(polygonal_mask);
% Save results
save([stgObj.data_analysisoutdir,'/PoligonalMask'],'polygonal_mask');
save([stgObj.data_analysisoutdir,'/CroppedCellLabels'],'cropped_CellLabelIm');
% Update settings module
stgObj.AddResult('Polygon_Masking','polygonal_mask_path',[stgObj.data_analysisoutdir,'/PoligonalMask.mat']);
stgObj.AddResult('Polygon_Masking','cropped_cell_labels',[stgObj.data_analysisoutdir,'/CroppedCellLabels.mat']);
% Visualize in main gui]
%StackView(cropped_CellLabelIm,'hMainGui','figureA');
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
% -------------------------------------------------------------------------
argout(1).description = 'Polygonal Mask file path';
argout(1).ref = varargin(1);
argout(1).object = strcat([stgObj.data_analysisoutdir,'/PoligonalMask.mat']);
% -------------------------------------------------------------------------
argout(2).description = 'Cropped image file path';
argout(2).ref = varargin(1);
argout(2).object = strcat([stgObj.data_analysisoutdir,'/CroppedCellLabels.mat']);
% -------------------------------------------------------------------------
argout(3).description = 'Settings associated module instance execution';
argout(3).ref = varargin(3);
argout(3).object = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
% -------------------------------------------------------------------------
%% Status execution update
status = 0;
end