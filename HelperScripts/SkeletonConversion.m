% Script to convert CLabels image to skeletons
%
% Author:    Davide Heller
% email:     davide.heller@imls.uzh.ch
%
% adapted from: http://stackoverflow.com/questions/5265837/find-outlines-borders-of-label-image-in-matlab


%% set and output input directory

%DataDirec = '[path to data]'
DataDirec = '/Users/l48imac2/Documents/Userdata/Simon/decadGFP_103h_63XNE0_JHIII_20130912_84346 AM/0/Test1Output';

%OutputDirec = '[parent folder where to store skeletons]'
OutputDirec = '/Users/l48imac2/Documents/Userdata/Simon/decadGFP_103h_63XNE0_JHIII_20130912_84346 AM/0/Test1Output/';

%New directory in OutputDirec where to store the skeletons for each time point
SkelDirec = [OutputDirec,'/skeletons'];
mkdir(SkelDirec);

%skeleton file name
skeleton_name_pattern = '/Neo0_skeleton_';

%% load epitools data structure 

%it 1 before manual tracking corrections
%InputFile = [DataDirec, '/Analysis/SegResults'];

%it 2
InputFile = [DataDirec, '/Analysis/SegResultsCorrected'];

load(InputFile);

%% transform CLabels into boundary Bitmaps

for i = 1:size(CLabels,3)
    
    lblImg = CLabels(:,:,i);
    
    [gx,gy] = gradient(lblImg);

    lblImg = (lblImg > 0) & ((gx.^2+gy.^2)>0);
    
    %to see intermediate results uncomment
    %imshow(label2rgb(lblImg))
    
    %time point suffix with 3 digits (e.g. 001)
    time_point_str = num2str(i,'%03.f');
    
    %output skeleton as png image
    imwrite(lblImg,strcat(SkelDirec,skeleton_name_pattern,time_point_str,'.png'));
end