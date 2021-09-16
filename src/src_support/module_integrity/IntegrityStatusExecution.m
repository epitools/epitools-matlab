function [status,argout] = IntegrityStatusExecution( input_args,varargin )
%INTEGRITYSTATUSEXECUTION This function check the running status of a program in the 
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
addRequired(p,'ForceExecution',@islogical);
%addOptional(p,'description',@ischar);
parse(p,'ForceExecution',varargin{:});

for i = 1:numel(input_args)
    
[status,result] = system('tasklist /FI "imagename eq icy.exe" /fo table /nh')
% If the searched program is not running,  if ForceExection parameter is passed to the function,
% then try to place a call to the system.
if p.Results.ForceExecution && isempty(result)
   system( input_args{i}
end
end
end

