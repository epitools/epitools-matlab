function [status, argout ] = RetrieveData2Load(varargin)
%RETRIEVEDATA2LOAD Retrieve data to be passed to the calling function
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function load data structures required by the calling function. It
% checks the active pool, it looks for the required tag in the pool and it
% load the linked file. 
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
% DATE:     26.02.15 V0.1 for EpiTools 2.0 beta
% 
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the 
% original author is referenced and attributed as such. The original author maintains the right 
% to be solely associated with this work.
% 
% Copyright by A. Tournier, A. Hoppe, D. Heller, L. Gatti
% ------------------------------------------------------------------------------
%% Initialization arguments
p = inputParser;
% Define function parameters
addParameter(p,'TagID','',@ischar);
%addOptional(p,'ClientName','',@ischar);
% Parse function parameters
parse(p,varargin{:});
%% Procedure
status = 0;
argout = [];
%% Get pool reference and open active pool on graphic tag passed on module dependence
% Get pool handles
pool_instances = getappdata(getappdata(0, 'hMainGui'), 'pool_instances');
%% Elaboration
% Storing execution variables into memory and retrieve tag from pool
for i = 2:size(pool_instances,2)
    if (pool_instances(i).ref.active); o = pool_instances(i).ref.getTag(p.Results.TagID); end
end
% Try to open the attribute structure on class 'file' if tag class is
% 'graphics'
try 
    if (strcmp(o.class,'graphics')); t = o.attributes.attribute(strcmp({o.attributes.attribute.class},'file')); end
catch err
    disp(err);
end
% If mat, then check content and select for integer matrix
if regexp(t.path, '.mat')>0
    s = load(t.path);
    s_fields = fieldnames(s);
    for i = 1:numel(s_fields); argout = s.(char(s_fields(i))); end
end
status = 1;
end

