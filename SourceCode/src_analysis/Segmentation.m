function Segmentation(stgObj)
%Segmentation Segmenents the Projected Images
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
%   params - parameter structure for the segmentation algorithm


% it is more convenient to recall the setting file with as shorter variable
% name: stgModule 
tmpStgObj = stgObj.analysis_modules.Segmentation.settings;

tmpRegObj = load([stgObj.data_analysisdir,'/RegIm']);
%load([AnaDirec,'/RegIm']);

if tmpStgObj.SingleFrame
    %todo: SegmentStack should be able to handle single frames
    im = tmpRegObj.RegIm(:,:,1);
    [Ilabel,Clabel,ColIm] = SegmentIm(im,tmpStgObj);
    
    figure;
    imshow(ColIm,[]);
    
else
    
    [ILabels ,CLabels,ColIms] = SegmentStack(tmpRegObj.RegIm,tmpStgObj);
    
    NX = size(tmpRegObj.RegIm,1);
    NY = size(tmpRegObj.RegIm,2);
    NT = size(tmpRegObj.RegIm,3);
    
    RegIm = tmpRegObj.RegIm;
    save([stgObj.data_analysisdir,'/SegResults'], 'RegIm', 'ILabels', 'CLabels' ,'ColIms','tmpStgObj','NX','NY','NT','-v7.3')
    
    %save dummy tracking information
    FramesToRegrow = [];
    oktrajs = [];

    save([stgObj.data_analysisdir,'/TrackingStart'],'ILabels','FramesToRegrow','oktrajs')
    
    stgObj.AddResult('Segmentation','segmentation_path',strcat(stgObj.data_analysisdir,'/SegResults'));
    stgObj.AddResult('Segmentation','tracking_path',strcat(stgObj.data_analysisdir,'/TrackingStart'));
    
    StackView(ColIms,'hMainGui','figureA');
    
end
end

