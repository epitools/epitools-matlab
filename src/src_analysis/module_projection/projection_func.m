function [ status, argout ] = projection_func(input_args,varargin)
%PROJECTION Discover the surface of the highest intensity signal in the image
%           stack and selectively project the signal lying on that surface
% ------------------------------------------------------------------------------
% PREAMBLE
%
% Creates a 2D projection from a Z-stack by selectively choosing from which
% plane to extract each pixel based on a surface estimation. The input image is
% composed of several z planes representing a cohesive tissue which can be
% approximated by a 3D surface. In order to exclude another surface from being
% also projected the latter has to have a lower intensity or at least a smaller
% number of high intensity points than the region of interest (ROI).
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
% DATE:     2.09.14 V0.1 for EpiTools 0.1 beta
%           5.12.14 V0.2 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.
%
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------

%% Retrieve supplementary arguments
if (nargin<2); varargin(1) = {'PJIMAGEPATH'};varargin(2) = {'PJSURFPATH'};varargin(3) = {'SETTINGS'};varargin(4) = {'VTKPATH'};end
%% Procedure initialization
status = 1;
%initialize progressbar
%progressbar('Projecting images...');
% Initialize global time variable
global_time_index = 0;
% Variable indicating the number of processed files
intProcessedFiles = 0;
%% Retrieve parameter data
% it is more convenient to recall the setting file with as shorter variable
% name: stgModule
% TODO: input_args{strcmp(input_args(:,1),'SmoothingRadius'),2}
handleSettings = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
execMessageUID = input_args{strcmp(input_args(:,1),'ExecutionMessageUID'),2};
%% Open Connection to Server 
server_instances = getappdata(getappdata(0, 'hMainGui'), 'server_instances');
server = server_instances(2).ref;
%% Variable Remapping
stgMain = getVariable4Memory(handleSettings);
stgModule = stgMain.analysis_modules.Projection.settings;
%% Load Data
% -------------------------------------------------------------------------
% Log status of current application status
log2dev('******************** PROJECTION MODULE ********************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.2.2-Mar15 $ Date: 2015/03/11 15:46:12       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started projection analysis module', 'INFO');
% -------------------------------------------------------------------------
%% Apply Projection
% Activate Matlabpools for parallel execution if set in stgObj
if(stgMain.platform_units ~= 1)
    parpoolobj = parpool('local',stgMain.platform_units);
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev( sprintf('Opening %u pools on currently default cluster',parpoolobj.NumWorkers), 'DEBUG');
    % -------------------------------------------------------------------------
end
% Per each IMG ID in the IMG ID list generated with PreparingData2Load (where the
% exec toggle property was set to true)
execTDep = server.getMessageParameter(execMessageUID,'queue','dependences');
[~,data] = RetrieveData2Load(execTDep);
% initialize data structures
Surfaces = zeros(size(data,1), size(data,2), size(data,4) ,'uint8');
ProjIm   = zeros(size(data,1), size(data,2), size(data,4), char(class(data)));
minv = 0; maxv=size(data,4);
log2dev('Processing time frame...plase wait','INFO',0,'hMainGui', 'statusbar',{minv,maxv,0});
progressbar('Projecting images... (please wait)');

%initialize directory for VTK polydata files (1 vtk surface file per frame)
%vtk_path = [stgMain.data_analysisoutdir,'/vtk'];
%mkdir(vtk_path);
mkdir([stgMain.data_analysisoutdir,'/vtk']);

for i=1:size(data,4)
    log2dev(sprintf('Processing time frame %u of %u ',i, size(data,4)), 'DEBUG');
    log2dev(sprintf('Processing time frame: %u/%u',i,size(data,4)),'INFO',0,'hMainGui', 'statusbar',{minv,maxv,i});
    [im,Surf,xg2,yg2,zg2] = createProjection(data(:,:,:,i),...
        stgModule.SmoothingRadius,...
        stgModule.ProjectionDepthThreshold,...
        stgModule.SurfSmoothness1,...
        stgModule.SurfSmoothness2,...
        stgModule.InspectResults);
    ProjIm(:,:,i)   = im;
    Surfaces(:,:,i) = Surf;
    
    %save 2nd surface estimation by gridfit in VTK polydata
    %triangulation = delaunay(xg2,yg2);

    %output vtk file
    output_path = [stgMain.data_analysisoutdir,'/vtk/'];
    output_file_name = sprintf('gridfit_frame_%03d.vtk',i);
    output_fullpath = strcat(output_path,output_file_name);
        
    %frame_file = sprintf('%s/gridfit_frame_%03d.vtk',vtk_path,i);
    %vtkwrite(output_fullpath,'polydata','triangle',xg2,yg2,zg2,triangulation);
    vtkwrite(output_fullpath,'structured_grid',...
        xg2,yg2,zg2,'scalars','intensity',im)
    
    log2dev(sprintf('Exporting VTK frame %u of %u ',i, size(data,4)), 'DEBUG');

    %% Saving VTK results
    stgMain.AddResult('Projection',strcat('vtk_path_',num2str(i)),strcat(output_path,output_file_name));

    progressbar(i/size(data,4));
    
end
progressbar(1);

log2dev('Projection completed...saving data structures','INFO',0,'hMainGui', 'statusbar');
%% Saving results
%stgMain.AddResult('Projection','projection_path','ProjIm.tif');
%exportTiffImages(ProjIm,'filename',[stgMain.data_analysisoutdir,'/ProjIm.tif']);
stgMain.AddResult('Projection','projection_path',[stgMain.data_analysisoutdir,'/ProjIm.mat']);
stgMain.AddResult('Projection','surface_path',[stgMain.data_analysisoutdir,'/Surfaces.mat']);
%stgMain.AddResult('Projection','vtk_path',vtk_path);

stgMain.AddMetadata('Projection','handle_settings', handleSettings);
stgMain.AddMetadata('Projection','exec_message', execMessageUID);
stgMain.AddMetadata('Projection','exec_dependences', execTDep);

save([stgMain.data_analysisoutdir,'/ProjIm'],'ProjIm')
save([stgMain.data_analysisoutdir,'/Surfaces'],'Surfaces')
%% Exporting extra Tags according to input data
if size(data,4) ~= 1
    server.setMessageParameter(execMessageUID, 'Level','tags','Action','add','Argvar','Generic_Image_TSerie');
end
%% Passing settings to calling environment
tmp = getappdata(getappdata(0,'hMainGui'),'settings_execution');
tmp.(char(handleSettings)) = stgMain;
setappdata(getappdata(0,'hMainGui'),'settings_execution', tmp);
% -------------------------------------------------------------------------
% Log status of current application status
log2dev(sprintf('Saving results as %s | %s',...
    ([stgMain.data_analysisoutdir,'/ProjIm']),...
    ([stgMain.data_analysisoutdir,'/Surfaces'])),...
    'INFO');
% -------------------------------------------------------------------------
progressbar(1);
% -------------------------------------------------------------------------
% Log status of current application status
log2dev('Finished projection module ', 'INFO');
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
% -------------------------------------------------------------------------
argout(1).description = 'Projected image file path';
argout(1).ref = varargin(1);
%argout(1).object = strcat([stgMain.data_analysisoutdir,'/ProjIm.tif']);
argout(1).object = strcat([stgMain.data_analysisoutdir,'/ProjIm.mat']);
% -------------------------------------------------------------------------
argout(2).description = 'Projected surface file path';
argout(2).ref = varargin(2);
argout(2).object = strcat([stgMain.data_analysisoutdir,'/Surfaces.mat']);
% -------------------------------------------------------------------------
argout(3).description = 'Settings associated module instance execution';
argout(3).ref = varargin(3);
argout(3).object = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
% -------------------------------------------------------------------------
argout(4).description = 'VTK file path';
argout(4).ref = varargin(4);
argout(4).object = output_path;
% -------------------------------------------------------------------------
%% Status execution update
status = 0;
end