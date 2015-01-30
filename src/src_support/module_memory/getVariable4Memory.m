function argout  = getVariable4Memory( input_args, varargin )
%SETVARIABLE4MEMORY Retrieve variable from memory passing a handle
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function retrieves a variable from the execution memory structure   
% previously copied into a placeholder initialized during EpiTools loading.
%
% INPUT
%   1. input_args:  memory object handle
%   2. varargin:    [not implemented]
%
% OUTPUT
%   1. handle:  variable containing a structure with output objects, description
%               and ref association
%
% REFERENCES
%
% AUTHOR:   Lorenzo Gatti (lorenzo.gatti@alumni.ethz.ch)
%
% DATE:     26.01.15 V0.1 for EpiTools 2.0 beta
% 
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the 
% original author is referenced and attributed as such. The original author maintains the right 
% to be solely associated with this work.
% 
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
if nargin < 2; varargin = {} ; end
argout = '';
% Get memory object 
tmp = getappdata(getappdata(0,'hMainGui'),'execution_memory');
% Open on handle reference
fieldsmem = fields(tmp);
if sum(strcmp(fieldsmem,char(input_args))) > 0;argout = tmp.(char(input_args));end
end

