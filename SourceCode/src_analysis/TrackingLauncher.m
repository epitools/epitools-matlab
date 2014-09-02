function [varargout] =  TrackingLauncher(stgObj)
%TrackingGUILauncher launches the interface that allows the user to correct
%the segmentation results of the Epitools segmnetation. Find more
%explanation in TrackingGUIwOldOK.m 

progressbar('Loading SegResults...(might take some minutes)')

% -------------------------------------------------------------------------
% Log status of current application status
log2dev('********************* TRACKING MODULE *********************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.1 beta    $ Date: 2014/09/02 11:37:00       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started tracking analysis module', 'INFO');
% -------------------------------------------------------------------------   

% it is more convenient to recall the setting file with as shorter variable
% name: stgModule 
tmpStgObj = stgObj.analysis_modules.Tracking.settings;
tmpSegObj = load([stgObj.data_analysisindir,'/SegResults']);

%Save original sequence dimensions
NX = size(tmpSegObj.RegIm,1);
NY = size(tmpSegObj.RegIm,2);
NT = size(tmpSegObj.RegIm,3);

%Optional parameter for the TrackingGUI
%tmpStgObj.TrackingRadius = tracking_radius;

strFilename = strcat('ILabelsCorrected_',datestr(now,30));
output = [stgObj.data_analysisoutdir,'/',strFilename];

progressbar(1);

%retrieve tracking file

listFilesInput = dir(stgObj.data_analysisindir);
ArrayFileNames = [listFilesInput.name];

% If tracking module has been executed already, ask which tracking file to start with
if (~isempty(strfind(ArrayFileNames,'ILabelsCorrected')))

    [filename, pathname] = uigetfile(strcat(stgObj.data_analysisindir,'/','*.mat'),'Select last tracking file');
     
    if (~isa(filename, 'char') && (filename == 0 || pathname == 0))
        filename = '';
        pathname = '';
    end
    
% If tracking module has not been executed aready... then in the folder you
% might find TrackingStart.mat
elseif (~isempty(strfind(ArrayFileNames,'TrackingStart')))
    
       filename =  '/TrackingStart.mat';
       pathname =  stgObj.data_analysisindir;

% If segmentation module has not been executed 
% In future, throw an error due to dependences not satisfied
else
    return;
end

if((isempty(filename) || isempty(pathname) ) == 0)
    IL = load([pathname,filename]);
    
    %disp(['Current tracking file: ',filename]);

    log2dev(['Current tracking file: ',filename],'INFO');

    %patch to avoid the increase in x,y dimensions
    IL.ILabels = IL.ILabels(1:NX,1:NY,:);
    
    %Did the user apply a polygon crop? If yes use the cropped CLabels
    cropped_cell_labels_file = [stgObj.data_analysisindir,'/CroppedCellLabels.mat'];
    if exist(cropped_cell_labels_file,'file')
        cropped_data = load(cropped_cell_labels_file);
        tmpSegObj.CLabels = cropped_data.cropped_CellLabelIm;
    end

    %open the tracking gui
    fig = TrackingGUIwOldOK(tmpSegObj.RegIm,...
                            IL.ILabels,...
                            tmpSegObj.CLabels,...
                            tmpSegObj.ColIms,...
                            output,...
                            tmpStgObj,...
                            IL.oktrajs,...
                            IL.FramesToRegrow);

    % wait for corrections to finish (ie after saving using 's')
    uiwait(fig);
  
%% Saving results
stgObj.AddResult('Tracking','tracking_file',strcat(strFilename,'.mat'));

end

end

