function [ status, argout ] = LoadEtMetaData( input_args, varargin )
%LOADETMETADATA Loads predifined epitool_metadata xml file
% ------------------------------------------------------------------------------
% PREAMBLE
%
% Given a settings object file with defined MAIN module this function populates the module with 
% the data strucuture summarizing the images that will be analyzed.
%
% INPUT 
%   1. input_args:  variable containing the analysis object
%   2. varargin:    variable containing extra parameters for ref association 
%                   during output formatting (might not be implemented)
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
if (nargin<2)
    varargin(1:2) = {'OUT1'};
end
%% Status initialization
status = 1;
% Check for the presence of a Main module in the main analysis object   
if ~input_args.hasModule('Main')
    errordlg('No Main Module found!');
    argout = struct();
    return
end
% Check for the presence of a metadata file in the directory
metafile_file = [input_args.data_imagepath,'/epitool_metadata.xml'];
if ~exist(metafile_file, 'file')
    errordlg('No Metafile found at image_path!');
    argout = struct();
    return
end
% Read metadata file
MetadataFIGXML = xml_read(metafile_file);
vecFields = fields(MetadataFIGXML.files);
for i=1:length(vecFields)
    MetadataFIGXML.files.(char(vecFields(i))).exec = logical(MetadataFIGXML.files.(char(vecFields(i))).exec);
    MetadataFIGXML.files.(char(vecFields(i))).exec_dim_z = num2str(MetadataFIGXML.files.(char(vecFields(i))).exec_dim_z);
    MetadataFIGXML.files.(char(vecFields(i))).exec_channels = num2str(MetadataFIGXML.files.(char(vecFields(i))).exec_channels);
    MetadataFIGXML.files.(char(vecFields(i))).exec_num_timepoints = num2str(MetadataFIGXML.files.(char(vecFields(i))).exec_num_timepoints);
    arrFiles(i,:) = struct2cell(MetadataFIGXML.files.(char(vecFields(i))));
end

%First time load, skip location path (1)
input_args.AddSetting('Main','data',arrFiles(:,2:end));
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
argout(1).description = 'Indices required to load image files';
argout(1).ref = varargin(1);
argout(1).object = idxPoints;
%% Status execution update 
status = 0;
end

