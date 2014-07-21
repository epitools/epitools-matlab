function [ out_status ] = CreateMetadata( varargin )
%CREATEMETADATA Create a metadata file containing the informations to
%access the image files found in [data] directory
%
% Auth: L. Gatti
% Date: 16-July-2014 
% Update: 21-July-2014
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
% This program contains code licensed under Creative Commons BY-NC-SA 3.0,
% published in the following documents:
%
% - "Gatti L., Trotti A., Rosenblatt Perceptron Algorithm implementation and application in gene 
%                         function prediction in Saccharomyces cerevisiae, 
%                         May 2011, University of Milan (IT), All Rights Reserved".
%
% - "Del Bene L.,Gatti L.,Koletou M., Yudzin A.,  Epidemic models of Flu outbreaks - Bayesian Data Assimilation 
%                                                 and Uncertainty Quantification for a SIR-variant model,
%                                                 July 2013, Eidgen?ssische Technische Hochschule Z?rich (CH),
%                                                 All Rights Reserved".
%
% => Plese quote the author when used in a publication.
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

% --------------------------- XML File DISCOVERY -------------------------- 
% Listing files in directory
lstFiles = dir(stgObj.data_imagepath);

% Supported metadata files
regexXML = {'\w*(?=.xml)'};

a = struct2cell(lstFiles);

% in case a xml file has been found
if(isempty(cell2mat(regexp(a(1,:),regexXML))) == 0)
    
    intXMLFileidx = find(~cellfun(@isempty,regexp(a(1,:),regexXML)));
    
    out_status = sprintf('File %s has been found in %s', char(a(1,intXMLFileidx)), strcat(stgObj.data_imagepath));
   
    outDLG = questdlg(sprintf('A Metadata xml file has been found in the specified folder.\n\n How do you want to proceed?'), 'Loading xml metadata files','Use the xml file found', 'Generate a new one', 'Generate a new one');
    
    switch outDLG
        case 'Use the xml file found'
            
            return;
        
        case 'Generate a new one'
            
           out_status = CreateMetadataFile(stgObj);

    end
    
else

   out_status = CreateMetadataFile(stgObj);

end
    
end


function argout = CreateMetadataFile(stgObj)
% Listing files in directory
lstFiles = dir(stgObj.data_imagepath);

% Initialization metadata struct variable: metadata main file
stcMetaData = struct();
stcMetaData.main = struct();
stcMetaData.main.file_analysis_name = stgObj.analysis_name;
stcMetaData.main.file_analysis_code = stgObj.analysis_code;
stcMetaData.main.file_date = date();
stcMetaData.main.file_time = floor(now());

% Initialization metadata struct variable: struct for image files
stcMetaData.main.files = struct();

% Discovered file counter
filenum = 1;

% Supported image files
regexFIG = {'\w*(?=.tif|.tiff|.jpg|.jpeg)'};

% Loop over discovered files
for i=1:length(lstFiles)

    if (isempty(cell2mat(regexp(lstFiles(i).name,regexFIG))) == 1)
        continue;
    end
    
    stcMetaData.main.files.(strcat('file',num2str(filenum))) = struct();
    temp = ReadMicroscopyData(strcat(stgObj.data_imagepath,'/',lstFiles(i).name));
    
    stcMetaData.main.files.(strcat('file',num2str(filenum))).location   = stgObj.data_imagepath;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).name       = lstFiles(i).name;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).dim_x      = temp.NX;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).dim_y      = temp.NY;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).dim_z      = temp.NZ;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).num_channels   =   temp.NC;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).num_timepoints =   temp.NT;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).pixel_type     =   temp.PixelType;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).exec           = 1;
    stcMetaData.main.files.(strcat('file',num2str(filenum))).exec_dim_z     = strcat('1-',temp.NZ);
    stcMetaData.main.files.(strcat('file',num2str(filenum))).exec_channels  =  strcat('1-',temp.NC);
    stcMetaData.main.files.(strcat('file',num2str(filenum))).exec_num_timepoints =   strcat('1-',temp.NT);
    
    filenum = filenum + 1;
    
end


% ---------------------------- SAVING XML FILE ----------------------------
argout = sprintf('Metadata file created correctly at %s', strcat(stgObj.data_imagepath,'/','meta.xml'));
struct2xml(stcMetaData, strcat(stgObj.data_imagepath,'/','meta.xml'));

% --------------------------- READING XML FILE ----------------------------

%struct.data = xml_read(strcat(stgObj.data_imagepath,'/','meta.xml'));

end

