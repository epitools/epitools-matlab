function [status, argout] = LoadImgData(strFullPathFile, imgIDX, arrayIndices, varargin)
%LOADIMGDATA Creating indeces for selected files to load
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function loads the image files specified by the indices produced by PreparingData2Load
% function. 
%
% INPUT 
%   1. strFullPathFile:  variable containing the analysis object
%	1. imgIDX:  variable containing the analysis object
%	1. arrayIndices:  variable containing the analysis object
%
% OUTPUT
%   1. status:  status elaboration (0  executed correctly; > 0 fatal error)
%   2. argout:  variable containing a structure with output objects, description 
%               and ref association
%
% REFERENCES
%
% AUTHOR:   Lorenzo Gatti (lorenzo.gatti@alumni.ethz.ch)
%
% DATE:     1.10.14 V0.1 for EpiTools 1.0 beta
%           5.12.14 V0.2 for EpiTools 2.0 beta
% 
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the 
% original author is referenced and attributed as such. The original author maintains the right 
% to be solely associated with this work.
% 
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
%% Retrieve supplementary arguments (they are exported as reported in the tags.xml file)
if (nargin<4)
    varargin(1) = {'OUT1'};
end
%% Status initialization
status = 1;
%% Elaboration
% Initialize logging
loci.common.DebugTools.enableLogging('INFO');
% Proallocating variables
if isa(arrayIndices.Z(imgIDX),'cell')   
    Z = cell2mat(arrayIndices.Z(imgIDX)) - 1 ;
else
    Z = arrayIndices.Z(imgIDX) - 1;
end
if isa(arrayIndices.C(imgIDX),'cell')   
    C = cell2mat(arrayIndices.C(imgIDX)) - 1 ;
else
    C = arrayIndices.C(imgIDX) - 1;
end
if isa(arrayIndices.T(imgIDX),'cell') 
    T = cell2mat(arrayIndices.T(imgIDX)) - 1 ;
else
    T = arrayIndices.T(imgIDX) -1;
end
% Check if the the image stack contains multiple channel indeces
if(size(C)>1); C = 0; end
% Invoke the reader for an image file data
reader = bfGetReader(strFullPathFile);
% Loop along the indeces in order to extract only the required planes. Loop order is due to OME plugin
for z=1:numel(Z)
    for c=1:numel(C)
        for t=1:numel(T)
            intPlaneIdx = reader.getIndex(Z(z),C(c),T(t));
            ImgStack(:,:,Z(z)+1,C(c)+1,T(t)+1) = bfGetPlane(reader, intPlaneIdx+1);
        end
    end
end
% Get rid of empty planes
ImgStack = squeeze(ImgStack);
% Close the reader
reader.close();
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
%argout(1).description = 'Image stack reduced to specified indeces';
%argout(1).ref = varargin(1);
argout = ImgStack;
%% Status execution update 
status = 0;
end