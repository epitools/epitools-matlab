function [varargout] =  Segmentation(stgObj)
%Segmentation Segmenents the Projected Images
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
%   params - parameter structure for the segmentation algorithm


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
    [Ilabel,Clabel,ColIm] = SegmentIm(im,tmpStgObj);
    
    figure;
    imshow(ColIm,[]);
    
else
    
    %Check current parallel options 
    if(stgObj.platform_units ~= 1)
        tmpStgObj.Parallel = true;
    else
        tmpStgObj.Parallel = false;
    end
    
    
    [ILabels ,CLabels,ColIms] = SegmentStack(tmpRegObj.RegIm,tmpStgObj);
    
    NX = size(tmpRegObj.RegIm,1);
    NY = size(tmpRegObj.RegIm,2);
    NT = size(tmpRegObj.RegIm,3);
    
    RegIm = tmpRegObj.RegIm;
    save([stgObj.data_analysisoutdir,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','tmpStgObj','NX','NY','NT','-v7.3')
    
    %save dummy tracking information
    FramesToRegrow = [];
    oktrajs = [];

    save([stgObj.data_analysisoutdir,'/TrackingStart'],'ILabels','FramesToRegrow','oktrajs')
    
    stgObj.AddResult('Segmentation','segmentation_path',strcat(stgObj.data_analysisoutdir,'/SegResults'));
    stgObj.AddResult('Segmentation','tracking_path',strcat(stgObj.data_analysisoutdir,'/TrackingStart'));
   
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
                'hMainGui',...
                'uiBannerDescription',...
                [],...
                2 );

                StackView(ColIms,'hMainGui','figureA');
                SandboxGUIRedesign(0);

            else
                
                firstrun = load([stgObj.data_analysisindir,'/ColIms']);
                % The program is being executed in comparative mode
                StackView(firstrun.ColIms,'hMainGui','figureC1');
                StackView(ColIms,'hMainGui','figureC2');

            end
            
        end
    else
        StackView(ColIms);
    end
end
end

