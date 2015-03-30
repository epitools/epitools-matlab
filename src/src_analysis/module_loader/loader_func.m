function [ status, argout ] = loader_func( input_args, varargin )
%DATAINDEXING_FUNC Creating indeces for selected files to load
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function will prepare your data to be loaded in Epitools. This allows the 
% programm to load only the files you previously set to be sent to further analysis 
% steps. Given the setting object populated with images metadata file, extract the
% list of files and fill a cell list containing all the informations regard
% accessing data files.
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
%           11.03.15 V0.3 for EpiTools 2.0 stable
% 
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the 
% original author is referenced and attributed as such. The original author maintains the right 
% to be solely associated with this work.
% 
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
%% Retrieve supplementary arguments (they are exported as reported in the tags.xml file)
if (nargin<2); varargin(1) = {'LOADERVARIABLE'}; end
status = 1;
%% Retrieve message handle
execMessageUID = input_args{strcmp(input_args(:,1),'ExecutionMessageUID'),2};
%% Open Connection to Server 
server_instances = getappdata(getappdata(0, 'hMainGui'), 'server_instances');
server = server_instances(2).ref;
%% Procedure
% Get indices 
handleSettings = input_args{strcmp(input_args(:,1),'ExecutionSettingsHandle'),2};
tmp = getappdata(getappdata(0,'hMainGui'),'execution_memory');
stgMain = tmp.(char(handleSettings));
% Remapping variables
indices = stgMain.analysis_modules.Indexing.results.indices;
% Export tag according to indices
if ~isempty(indices.I)
    server.setMessageParameter(execMessageUID, 'Level','tags','Action','add','Argvar','Generic_Image');
    % Export Generic_Image_ZSerie if more than a Z plane is found
    if isa(indices.Z, 'cell')
        if sum(cellfun(@length,indices.Z)) > 1
            server.setMessageParameter(execMessageUID, 'Level','tags','Action','add','Argvar','Generic_Image_ZSerie');
        end
    else
        if sum(arrayfun(@length,indices.Z)) > 1
            server.setMessageParameter(execMessageUID, 'Level','tags','Action','add','Argvar','Generic_Image_ZSerie');
        end
    end
    % Export Generic_Image_TSerie if more than a T step is found
    if isa(indices.T, 'cell')
        if sum(cellfun(@length,indices.T)) > 1
            server.setMessageParameter(execMessageUID, 'Level','tags','Action','add','Argvar','Generic_Image_TSerie');
        end
    else
        if sum(arrayfun(@length,indices.T)) > 1
            server.setMessageParameter(execMessageUID, 'Level','tags','Action','add','Argvar','Generic_Image_TSerie');
        end
    end   
end
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
argout(1).description = 'Variable storing indications for data source loading';
argout(1).ref = varargin(1);
argout(1).object = 'source=file';
%% Status execution update 
status = 0;
end