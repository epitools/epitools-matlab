function [varargout] =  ReSegmentation(stgObj)
%ReSegmentation reruns the segmentation with the Tracking Corrections
%   stgObj - EpiTools settings object

% it is more convenient to recall the setting file with as shorter variable
% name: stgModule

%Please locate the last Tracking module used
%This should be handled outomatically in the future
tic
% -------------------------------------------------------------------------
% Log status of current application status
log2dev('Started re-segmentation analysis module', 'INFO');
% -------------------------------------------------------------------------        

if(stgObj.hasModule('Segmentation'))
    segmentation_module = stgObj.analysis_modules.Segmentation;
else
    %errordlg('Segmentation module missing, cannot proceed with resegmentation');
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev('Segmentation module missing, cannot proceed with resegmentation', 'ERR');
    % -------------------------------------------------------------------------
    return;
end

if(stgObj.hasModule('Tracking'))
    tracking_module = stgObj.analysis_modules.Tracking;
else
    %errordlg('Tracking module missing, cannot proceed with resegmentation');
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev('Tracking module missing, cannot proceed with resegmentation', 'ERR');
    % -------------------------------------------------------------------------
    return;
end

%copy all parameters from old segmentation
stgObj.analysis_modules.ReSegmentation.settings = segmentation_module.settings;

tmpStgObj = stgObj.analysis_modules.ReSegmentation.settings;

%% load data (only if working in new matlab session)

load([stgObj.data_analysisindir,'/SegResults']);

%This should be substituted with the last tracking file saved
%in the analysis module. Might wanna check for compatability
%in case the tracking module was used on another machine!
[filename, pathname] = uigetfile(strcat(stgObj.data_analysisindir,'/','*.mat'),'Select last tracking file');
tracking_file = [pathname, filename];

stgObj.AddResult('ReSegmentation','tracking_file_path',filename);

%% now resegmenting the frames which need it!

%given the reduced amuont of of frames parallelization is manually set
%as otherwise always all frames would be resegmented. Judge according
%to the case if to activate or not

%Check current parallel options
if(stgObj.platform_units ~= 1)
    tmpStgObj.Parallel = true;
else
    tmpStgObj.Parallel = false;
end

IL = load(tracking_file);
[ILabels , CLabels , ColIms] = SegmentStack( RegIm , tmpStgObj , IL.ILabels ,CLabels, ColIms, IL.FramesToRegrow );


% added version option to save ColIms as well /skipped otherwise, added
NX = size(RegIm,1);
NY = size(RegIm,2);
NT = size(RegIm,3);


% Storage results
save([stgObj.data_analysisoutdir,'/SegResultsCorrected'], 'RegIm','ILabels', 'CLabels' ,'ColIms','tmpStgObj','NX','NY','NT','IL','-v7.3' );
stgObj.AddResult('ReSegmentation','ReSegmentation_path','SegResultsCorrected.mat');


   
elapsedTime = toc;
% -------------------------------------------------------------------------
% Log status of current application status
log2dev(sprintf('Finished after %.2f', elapsedTime), 'DEBUG');
% -------------------------------------------------------------------------

%% inspect results
if(~stgObj.exec_commandline)
    if(stgObj.icy_is_used)
        icy_vid3show(ColIms,'ReSegmented Sequence');
        
        
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev('Display results of re-segmentation module via IcyConnection ', 'DEBUG');
        % -------------------------------------------------------------------------
        
        
    else
        if(strcmp(stgObj.data_analysisindir,stgObj.data_analysisoutdir))
            
            fig = getappdata(0  , 'hMainGui');
            handles = guidata(fig);
            
            set(handles.('uiBannerDescription'), 'Visible', 'on');
            set(handles.('uiBannerContenitor'), 'Visible', 'on');
            
            % Change banner description
            log2dev('Currently executing the [ReSegmentation] module',...
                'GUI',...
                2,...
                'hMainGui',...
                'uiBannerDescription');
            
            StackView(ColIms,'hMainGui','figureA');

            
            
        else
            
            firstrun = load([stgObj.data_analysisindir,'/ColIms']);
            % The program is being executed in comparative mode
            StackView(firstrun.ColIms,'hMainGui','figureC1');
            StackView(ColIms,'hMainGui','figureC2');

        end
        
        
        % -------------------------------------------------------------------------
        % Log status of current application status
        log2dev('Display results of re-segmentation module via @StackView ', 'DEBUG');
        % -------------------------------------------------------------------------

        
        
    end
else
    StackView(ColIms);
end
end

