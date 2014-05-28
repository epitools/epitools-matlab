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
	%display('need at least 1 input! (stackRegWrapper.m)');
	%return;
    %loadTestData
    load([m_file_dir,'/../Tests/Data/Analysis/ProjIm.mat']);
    imgs = ProjIm;
end

if nargin < 2
	transformationType = '[Rigid Body]';
	disp('Translation used for stackreg registration');
end

% start FIJI without GUI.
%Miji(false);

% transfer images from Matlab to FIJI
MIJ.createImage(imgs);
%%alternatively, above line can be replaced with below line and changing the input 'imgs' with the 'filename' of a multi-page tiff
%MIJ.run('Open...', ['path=[' filename ']']);  

% register
MIJ.run('StackReg ', ['transformation=' transformationType]);

% transfer image from FIJI to Matlab
imgsRegistered = MIJ.getCurrentImage;

% close image window in FIJI
MIJ.run('Close');
	
% exit FIJI
MIJ.exit;