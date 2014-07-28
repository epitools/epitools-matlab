function SkeletonConversion(stgObj)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%load(DataSpecificsPath);
tmpStgObj = stgObj.analysis_modules.Skeletons.settings;
tmpSegObj = load([stgObj.data_analysisdir,'/SegResults']);

progressbar('Loading Segmentation results...');

%TODO substitute with SegResultsCorrected!
%InputFile = [AnaDirec, '/SegResults'];
%load(InputFile);

progressbar(1);
progressbar('Creating skeletons...');

%SkelDirec = [AnaDirec,'/skeletons'];
mkdir([stgObj.data_analysisdir,'/skeletons']);

frame_no = size(tmpSegObj.CLabels,3);

for i = 1:frame_no
    
    lblImg = tmpSegObj.CLabels(:,:,i);
    
    [gx,gy] = gradient(lblImg);

    lblImg = (lblImg > 0) & ((gx.^2+gy.^2)>0);
    
    %to see intermediate results uncomment
    %imshow(label2rgb(lblImg))
    
    %time point suffix with 3 digits (e.g. 001)
    time_point_str = num2str(i,'%03.f');
    
    %output skeleton as png image
    output_file_name = strcat('/','frame_',time_point_str,'.png');
    imwrite(lblImg,[stgObj.data_analysisdir,'/skeletons',output_file_name]);
    
    progressbar(i/frame_no);
end

progressbar(1);

hMainGui = getappdata(0  , 'hMainGui');
if(ishandle(hMainGui))
    uiresume(hMainGui);
end

end




