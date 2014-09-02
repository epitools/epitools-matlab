function [varargout] =  Segmentation(stgObj)
%Segmentation Segmenents the Projected Images
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
%   params - parameter structure for the segmentation algorithm

tic
% -------------------------------------------------------------------------
% Log status of current application status
log2dev('******************* SEGMENTATION MODULE *******************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.1 beta    $ Date: 2014/09/02 11:37:00       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started segmentation analysis module', 'INFO');
% -------------------------------------------------------------------------        


% 
% $Revision: 5.27.4.8 $  $Date: 2011/06/15 08:03:38 $ 
% Built-in function. 


% it is more convenient to recall the setting file with as shorter variable
% name: stgModule 
tmpStgObj = stgObj.analysis_modules.Segmentation.settings;

if(stgObj.hasModule('Contrast_Enhancement'))
    tmpRegObj = load([stgObj.data_analysisindir,'/RegIm_wClahe']);
else
    tmpRegObj = load([stgObj.data_analysisindir,'/RegIm']);
end
%load([AnaDirec,'/RegIm']);

if tmpStgObj.SingleFrame
    %todo: SegmentStack should be able to handle single frames
    im = tmpRegObj.RegIm(:,:,1);
    [ILabels,CLabels,ColIms] = SegmentIm(im,tmpStgObj);
    
    figure;
    imshow(ColIms,[]);
    RegIm = im;
    save([stgObj.data_analysisoutdir,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','tmpStgObj','-v7.3')
    stgObj.AddResult('Segmentation','segmentation_path','SegResults.mat');

    
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev(sprintf('Saving segmentation results as %s | %s',[stgObj.data_analysisoutdir,'/SegResults'],[stgObj.data_analysisoutdir,'/TrackingStart']), 'DEBUG');
    % -------------------------------------------------------------------------   


else
    
    %Check current parallel options 
    if(stgObj.platform_units ~= 1)
        tmpStgObj.Parallel = true;
    else
        tmpStgObj.Parallel = false;
    end
    
    % Calling segmentation function with parameters set previously
    [ILabels,CLabels,ColIms] = SegmentStack(tmpRegObj.RegIm,tmpStgObj);
    
    
    NX      = size(tmpRegObj.RegIm,1);
    NY      = size(tmpRegObj.RegIm,2);
    NT      = size(tmpRegObj.RegIm,3);
    RegIm   = tmpRegObj.RegIm;
    
    %save dummy tracking information
    FramesToRegrow = [];
    oktrajs = [];
    
    save([stgObj.data_analysisoutdir,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','tmpStgObj','NX','NY','NT','-v7.3')
    save([stgObj.data_analysisoutdir,'/TrackingStart'],'ILabels','FramesToRegrow','oktrajs')
    stgObj.AddResult('Segmentation','segmentation_path','SegResults.mat');
    stgObj.AddResult('Segmentation','tracking_path','TrackingStart.mat');
 
    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev(sprintf('Saving segmentation results as %s | %s',[stgObj.data_analysisoutdir,'/SegResults'],[stgObj.data_analysisoutdir,'/TrackingStart']), 'DEBUG');
    % -------------------------------------------------------------------------   

    % inspect results
    if(~stgObj.exec_commandline)
        if(stgObj.icy_is_used)
            icy_vid3show(ColIms,'Segmented Sequence');
        else
            if(strcmp(stgObj.data_analysisindir,stgObj.data_analysisoutdir))
            
                fig = getappdata(0  , 'hMainGui');
                handles = guidata(fig);
            
                set(handles.('uiBannerDescription'), 'Visible', 'on');
                set(handles.('uiBannerContenitor'), 'Visible', 'on');

                % Change banner description
                log2dev('Currently executing the [Segmentation] module',...
                    [],...
                    2,...
                    'hMainGui',...
                    'uiBannerDescription');

                StackView(ColIms,'hMainGui','figureA');

            else
                
                firstrun = load([stgObj.data_analysisindir,'/SegResults']);
                % The program is being executed in comparative mode
                StackView(firstrun.ColIms,'hMainGui','figureC1');
                StackView(ColIms,'hMainGui','figureC2');              
                
            end
            
        end
    else
        StackView(ColIms);
    end
end

elapsedTime = toc;
% -------------------------------------------------------------------------
% Log status of current application status
log2dev(sprintf('Finished after %.2f', elapsedTime), 'DEBUG');
% -------------------------------------------------------------------------   


end

