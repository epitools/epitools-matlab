function [ status, argout ] = exportTiffImages(input_args,varargin)
%EXPORTTIFFIMAGE Export mat files into multidimensional tiff files
% ------------------------------------------------------------------------------
% PREAMBLE
% This function trasform a integer multidimensional matrix into a multidimensional 
% tiff files.
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
% DATE:     15.01.15 V0.1 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.
%
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
%% Procedure initialization
status = 1;
%% Initialization arguments
p = inputParser;
addRequired(p,'filename',@ischar);
%addOptional(p,'description',@ischar);
parse(p,'filename',varargin{:});
%% Initialisation variables
metadata = createMinimalOMEXMLMetadata(input_args);
%% Save
bfsave(input_args, p.Results.filename, 'metadata', metadata);
%% Status execution update
status = 0;
argout = [];