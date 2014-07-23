function imgsRegistered = stackRegWrapper(imgs, transformationType)

% THIS FUNCTION REQUIRES INSTALLATION OF Fiji
% DOWNLOAD FIJI HERE: http://fiji.sc/Downloads
%
% this function ILLUSTRATES a method to call
% the stackReg function in FIJI (ImageJ) with MIJI 
%
% Thanks to the support team at FIJI,MIJI,StackReg,ImageJ
% for these incredibly easy to use tools!
% 
% useful references
%
%  StackReg : http://bigwww.epfl.ch/thevenaz/stackreg/
%  Fiji: http://fiji.sc/Fiji
%  Miji: http://fiji.sc/Miji
%  ImageJ: http://imagej.nih.gov/ij/
%
% $Revision: 1.0 $ $Date: 2014/02/20 08:00$ $Author: Pangyu Teng $
% $Revision: 1.1 $ $Date: 2014/05/27 13:00$ $Author: Davide Heller $
%                  stackRegWrapper now runs independently from FIJI

%% Find ij/and mir

m_file_path = mfilename('fullpath');
m_file_dir = fileparts(m_file_path);

javaaddpath([m_file_dir,'/mij.jar']);
javaaddpath([m_file_dir,'/ij.jar']);

%start matlab interface
MIJ.start(m_file_dir); %could surpress ImageJ log with false flag

if nargin < 1
    load([m_file_dir,'/../Tests/Data/Analysis/ProjIm.mat']);
    imgs = ProjIm;
end

if nargin < 2
	transformationType = '[Rigid Body]';
	disp('Translation used for stackreg registration');
end

% transfer images from Matlab to FIJI
MIJ.createImage('Image to register', imgs, true);

% register
MIJ.run('StackReg ', ['transformation=' transformationType]);

% transfer image from FIJI to Matlab
imgsRegistered = MIJ.getCurrentImage;

% close image window in FIJI
MIJ.run('Close');
	
% exit FIJI
MIJ.exit;

%check output data type, if different: reconvert
original_data_format = class(imgs);
new_data_format = class(imgsRegistered);

if(~strcmp(new_data_format,original_data_format))
    
    if(isa(imgs,'uint16'))
        converted_imgs = uint16(imgsRegistered);
    elseif(isa(imgs,'uint8'))
        converted_imgs = uint8(imgsRegistered);
    else
        fprintf('Unknown input format %s\n',img_type);
    end
    
    fprintf('Reconverted %s to %s\n',new_data_format,original_data_format);
    
    %check equality and substitute
    if(~isequal(converted_imgs,imgsRegistered))
        fprintf('Conversion failed for %s\n',new_data_format);
    else
        imgsRegistered = converted_imgs;
    end
    
end

