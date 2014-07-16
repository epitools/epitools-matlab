function [ out_status ] = CreateMetadata( varargin )
%CREATEMETADATA Create a metadata file containing the informations to
%access the image files found in [data] directory
%
% Auth: L. Gatti
% Date: 16-July-2014 
% Update: 
% 
% SYNOPSIS r = bfopen(id)
%          r = bfopen(id, x, y, w, h)
%
% Input
%    r - the reader object (e.g. the output bfGetReader)
%
% Output
%
%    result - a cell array of cell arrays of (matrix, label) pairs, 
%    with each matrix representing a single image plane, and each inner 
%    list of matrices representing an image series.
%
% -- Configuration - customize this section to your liking --
%
% Toggle the autoloadBioFormats flag to control automatic loading
% of the Bio-Formats library using the javaaddpath command.
%
% For static loading, you can add the library to MATLAB's class path:
%     1. Type "edit classpath.txt" at the MATLAB prompt.
%     2. Go to the end of the file, and add the path to your JAR file
%        (e.g., C:/Program Files/MATLAB/work/loci_tools.jar).
%     3. Save the file and restart MATLAB.
%
% There are advantages to using the static approach over javaaddpath:
%     1. If you use bfopen within a loop, it saves on overhead
%        to avoid calling the javaaddpath command repeatedly.
%     2. Calling 'javaaddpath' may erase certain global parameters.
%
% =========================================================================
% Disclaimer
% =========================================================================
% Copyright (C) 2014 - Lorenzo Gatti - All rights reserved
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as
% published by the Free Software Foundation, either version 2 of the
% License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
% =========================================================================

% Who am I?

[ST,~] = dbstack();

% ---------------------------- ARGIN VALIDATION ---------------------------
% if no arguments are passed during function calling, report an error in
% the output status.
if nargin == 0 
    
    out_status = sprintf('No arguments passed to function @%s. Please give me something to do... ', ST.name);
    return;
    
end
% if argument passed is not a setting object then report an error in
% the output status.
if (~isa(varargin{1}, 'settings'))

    out_status = sprintf('Argument passed to function @%s is not a setting file. Please give me something better to do... ', ST.name);
    return;
    
else
    stgObj = varargin{1};
end

% ----------------------------- FILE DISCOVERY ----------------------------
    

lstImageFiles = dir(stgObj.data_imagepath);

stcMetaData = struct();
stcMetaData.main = struct();
stcMetaData.main.file_analysis_name = stgObj.analysis_name;
stcMetaData.main.file_analysis_code = stgObj.analysis_code;
stcMetaData.main.file_date = date();
stcMetaData.main.file_time = floor(now());

stcMetaData.main.files = struct();
filenum = 1;
for i=1:length(lstImageFiles)

    if(lstImageFiles(i).isdir == 1)
        continue;
    end
    
    stcMetaData.main.files.(strcat('file',num2str(filenum))) = struct();
    temp = ReadMicroscopyData(strcat(stgObj.data_imagepath,'/',lstImageFiles(i).name));
    
    stcMetaData.main.files.(strcat('file',num2str(filenum))).location   = stgObj.data_imagepath;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).name       = lstImageFiles(i).name;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).dim_x      = temp.NX;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).dim_y      = temp.NY;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).dim_z      = temp.NZ;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).num_channels   =   temp.NC;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).num_timepoints =   temp.NT;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).pixel_type     =   temp.PixelType;
    
    filenum = filenum + 1;
    
end


% ---------------------------- SAVING XML FILE ----------------------------

struct2xml(stcMetaData, strcat(stgObj.data_imagepath,'/','meta.xml'));

end

