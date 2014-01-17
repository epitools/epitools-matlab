%% CLAHE - Contrast-Limited Adaptive Histogram Equalization
%  info: http://www.mathworks.ch/ch/help/images/ref/adapthisteq.html
%
% Independent version to run clahe on RegIm from Epitools.
% Results could be further improved by changing the last parameter
% 'Distribution' - See website for more information, currently
% using the default(uniform one). Also binnig and clip limit were
% only shortly tuned.
%
% author: Davide Heller
% email:  davide.heller@imls.uzh.ch


%% Data setup

%Epitool scripts to run StackView
addpath('/Users/l48imac2/Documents/Userdata/Simon/Epitools/MatlabScripts')
javaaddpath('/Users/l48imac2/Documents/Userdata/Simon/Epitools/OME_LOCI_TOOLS/loci_tools.jar')
addpath('/Users/l48imac2/Documents/Userdata/Simon/Epitools/OME_LOCI_TOOLS')

%DataDirec = '[path to data]'
DataDirec = '/Users/l48imac2/Documents/Userdata/Simon/decadGFP_103h_63XNE0_JHIII_20130912_84346 AM/0/Test1Output';

InputFile = [DataDirec, '/Analysis/RegIm'];

load(InputFile);

%% View original

StackView(RegIm);

%% Run CLAHE

fprintf('Started CLAHE at %s\n',datestr(now));

%pre-allocate output
RegIm_clahe = zeros(size(RegIm,1), size(RegIm,2), size(RegIm,3), 'double');

%needs prior conversion for method
RegIm_uint16 = zeros(size(RegIm,2), size(RegIm,2), 'uint16');

%pre-alloacation for speed
RegIm_clahe_uint16 = zeros(size(RegIm,2), size(RegIm,2), 'uint16');

for i=1:size(RegIm,3)
    fprintf('Working on frame %d (abort with ctrl+c to see preview)\n',i);
    RegIm_uint16 = uint16(RegIm(:,:,i));
    RegIm_clahe_uint16 = adapthisteq(RegIm_uint16,'NumTiles',[70 70],'ClipLimit',0.02,'Distribution','uniform');
    RegIm_clahe(:,:,i) = double(RegIm_clahe_uint16); 
end

fprintf('Stopped CLAHE at %s\n',datestr(now));

%% View results
StackView(RegIm_clahe);

%% Save results

OutputFile = [DataDirec, '/Analysis/RegIm_clahe']
save(OutputFile,'RegIm_clahe');