function [varargout] = SkeletonConversion(stgObj)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%load(DataSpecificsPath);
tmpStgObj = stgObj.analysis_modules.Skeletons.settings;
corrected_segmentation = [stgObj.data_analysisindir,'/SegResultsCorrected'];

% -------------------------------------------------------------------------
% Log status of current application status
log2dev('******************* SKELETON GENERATION *******************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.1 beta    $ Date: 2014/09/02 11:37:00       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started skeleton analysis module', 'INFO');
% -------------------------------------------------------------------------      

%possibly substitute with hasModule ecc..
if(exist([corrected_segmentation,'.mat'],'file'))
    tmpSegObj = load(corrected_segmentation);
else
    tmpSegObj = load([stgObj.data_analysisindir,'/SegResults']);
end

progressbar('Loading Segmentation results...');

%TODO substitute with SegResultsCorrected!
%InputFile = [AnaDirec, '/SegResults'];
%load(InputFile);

progressbar(1);
progressbar('Creating skeletons...');

%SkelDirec = [AnaDirec,'/skeletons'];
mkdir([stgObj.data_analysisoutdir,'/skeletons']);

frame_no = size(tmpSegObj.CLabels,3);

for i = 1:frame_no
    
    %to make apply the transformation we need double
    cell_lables = double(tmpSegObj.CLabels(:,:,i));
    
    %given that every cell has a different label
    %we can compute the boundaries by computing 
    %where the gradient changes
    [gx,gy] = gradient(cell_lables);

    cell_outlines = (cell_lables > 0) & ((gx.^2+gy.^2)>0);
    
    %to see intermediate results uncomment
    %imshow(label2rgb(lblImg))
    
    %time point suffix with 3 digits (e.g. 001)
    time_point_str = num2str(i,'%03.f');
    
    %output skeleton as png image
    output_path = '/skeletons/';
    output_file_name = strcat('frame_',time_point_str,'.png');
    output_fullpath = strcat(output_path,output_file_name);
    imwrite(cell_outlines,[stgObj.data_analysisoutdir,output_fullpath]);
    %% Saving results
    stgObj.AddResult('Skeletons',strcat('skeletons_path_',num2str(i)),strcat('skeletons/',output_file_name));
    
    progressbar(i/frame_no);
end

progressbar(1);

varargout{1} = 1;
% 
% hMainGui = getappdata(0  , 'hMainGui');
% if(ishandle(hMainGui))
%     uiresume(hMainGui);
% end


end




