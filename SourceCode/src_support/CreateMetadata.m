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
            
            outDlgFilesNum  = questdlg(sprintf('In the directory specified I have found %u files.\nLoading process might take some time. \n\n How do you want to proceed?', (length(lstFiles)-2)), 'Loading xml metadata files','Proceed', 'Abort', 'Abort');
            switch outDlgFilesNum
                case 'Proceed'
                    out_status = CreateMetadataFile(stgObj);
                case 'Abort'
                    return
            end
    end
    
else
    
    out_status = CreateMetadataFile(stgObj);
    
end

end


function argout = CreateMetadataFile(stgObj)
% This function is parallelized in order to decrease the time needed to
% collect image informations.

% Listing files in directory
lstFiles = dir(stgObj.data_imagepath);

% Progress output
%progressbar('Discovering image files...');


% Initialization metadata struct variable: metadata main file
stcMetaData = struct();
stcMetaData.main = struct();
stcMetaData.main.file_analysis_name = stgObj.analysis_name;
stcMetaData.main.file_analysis_code = stgObj.analysis_code;
stcMetaData.main.file_date = date();
stcMetaData.main.file_time = floor(now());

% Initialization metadata struct variable: struct for image files
stcMetaData.main.files = struct();
tmpFileStruct = struct();

% Supported image files
regexFIG = {'\w*(?=.tif|.tiff|.jpg|.jpeg)'};

a = struct2cell(lstFiles);
intIMGFileidx = find(~cellfun(@isempty,regexp(a(1,:),regexFIG)));

% In case this process is run in parallel mode, then this computes the real
% progression of each single worker.
%pbar = progressbar_parallel(length(intIMGFileidx));
ppm = ParforProgressStarter2('Discovering image files...', length(intIMGFileidx), 0.1, 0, 0, 1);

%if stgObj.platform_units ~= 1 ; matlabpool('local',stgObj.platform_units); end

% =========================================================================
%
% To the workers:   stgObj.data_imagepath  => image_path
%                                   
% =========================================================================

image_path = stgObj.data_imagepath;

% Loop over discovered files
parfor i=1:length(intIMGFileidx)
    
    temp = ReadOMEMetadata(strcat(image_path,'/',lstFiles(intIMGFileidx(i)).name));
    tmpFileStruct(i).location   = image_path;
    tmpFileStruct(i).name       = lstFiles(intIMGFileidx(i)).name;
    tmpFileStruct(i).dim_x      = temp.NX;
    tmpFileStruct(i).dim_y      = temp.NY;
    tmpFileStruct(i).dim_z      = temp.NZ;
    tmpFileStruct(i).num_channels   =   temp.NC;
    tmpFileStruct(i).num_timepoints =   temp.NT;
    tmpFileStruct(i).pixel_type     =   temp.PixelType;
    tmpFileStruct(i).exec           = 1;
    tmpFileStruct(i).exec_dim_z     = strcat('1-',num2str(temp.NZ));
    tmpFileStruct(i).exec_channels  =  strcat('1-',num2str(temp.NC));
    tmpFileStruct(i).exec_num_timepoints =   strcat('1-',num2str(temp.NT));
    
    % Computing worker progression
    %percent = pbar.progress;
    %progressbar(percent);
    ppm.increment(i)
    
end

% Reassing splitted arrays from workers to the main structure

for i=1:length(intIMGFileidx)
    %stcMetaData.main.files.(strcat('file',num2str(i))) = tmpFileStruct(:,i);
    
    stcMetaData.main.files.(strcat('file',num2str(i))).location       = tmpFileStruct(i).location;
    stcMetaData.main.files.(strcat('file',num2str(i))).name           = tmpFileStruct(i).name;
    stcMetaData.main.files.(strcat('file',num2str(i))).dim_x          = tmpFileStruct(i).dim_x;
    stcMetaData.main.files.(strcat('file',num2str(i))).dim_y          = tmpFileStruct(i).dim_y;
    stcMetaData.main.files.(strcat('file',num2str(i))).dim_z          = tmpFileStruct(i).dim_z;
    stcMetaData.main.files.(strcat('file',num2str(i))).num_channels   = tmpFileStruct(i).num_channels;
    stcMetaData.main.files.(strcat('file',num2str(i))).num_timepoints = tmpFileStruct(i).num_timepoints;
    stcMetaData.main.files.(strcat('file',num2str(i))).pixel_type     = tmpFileStruct(i).pixel_type;
    stcMetaData.main.files.(strcat('file',num2str(i))).exec           = tmpFileStruct(i).exec;
    stcMetaData.main.files.(strcat('file',num2str(i))).exec_dim_z     = tmpFileStruct(i).exec_dim_z;
    stcMetaData.main.files.(strcat('file',num2str(i))).exec_channels  = tmpFileStruct(i).exec_channels;
    stcMetaData.main.files.(strcat('file',num2str(i))).exec_num_timepoints =   tmpFileStruct(i).exec_num_timepoints;
    
end

% ---------------------------- SAVING XML FILE ----------------------------
argout = sprintf('Metadata file created correctly at %s', strcat(stgObj.data_imagepath,'/','meta.xml'));
struct2xml(stcMetaData, strcat(stgObj.data_imagepath,'/','meta.xml'));


%percent = pbar.stop;
%progressbar(percent);
delete(ppm)
%if stgObj.platform_units ~= 1 ; matlabpool close; end

% --------------------------- READING XML FILE ----------------------------

%struct.data = xml_read(strcat(stgObj.data_imagepath,'/','meta.xml'));

end

