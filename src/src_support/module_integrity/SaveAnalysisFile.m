function argout = SaveAnalysisFile(analysis_struct,varargin)
%SAVEANALYSISFILE This function check the running status of a program in the 
% system task lists
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function is required to verify the running status of a software independently 
% Matlab execution. This function has been developed for checking ICY running status
% and in case 
%
% INPUT
%   1. input_args:  variable containing the server pool addresses
%   2. varargin:    not yet implemented
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
% DATE:     8.12.14 V0.1 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.

% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
%% Initialization arguments
p = inputParser;
% Define function parameters
addOptional(p,'ForceSave',false,@islogical);
% Parse function parameters
parse(p,varargin{:});
%% Procedure
if p.Results.ForceSave % case if ForceSave is true
    % Call method to export analysis to xml file
    analysis_struct.GenerateXMLFile
    % Status execution
    argout = 1;
else     % case ForceSave is false as default
    out = questdlg('Would you like to save the current analysis?', 'Save analysis','Yes', 'No','Abort', 'Abort');
    switch out
        case 'Yes'
            % Call method to export analysis to xml file
            analysis_struct.GenerateXMLFile
            argout = 0;
        case 'No'
            argout = 0;
        case 'Abort'
            argout = 1;
    end
end
