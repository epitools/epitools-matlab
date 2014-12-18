function handle  = addVariable2Memory( input_args, varargin )
%ADDVARIABLE2MEMORY Append variable to execution memory
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function stores a variable in the execution memory structure. All the data  
% is then copied into a placeholder initialized during EpiTools loading.
% All the informations stored during execution will be deleted on EpiTool
% closing. 
%
% INPUT
%   1. input_args:  variable to append to execution list
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
% DATE:     14.12.14 V0.1 for EpiTools 2.0 beta
% 
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the 
% original author is referenced and attributed as such. The original author maintains the right 
% to be solely associated with this work.
% 
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
if nargin < 2; varargin = {} ; end
tmp = getappdata(getappdata(0,'hMainGui'),'execution_memory');
% Initialization new handle
handle = string_generator(20);
while sum(strcmp(fieldnames(tmp),handle))>0;handle = string_generator(20);end
% Append variable to memory structure
tmp.(char(handle)) = input_args;
% Move memory variable back to calling environment
setappdata(getappdata(0,'hMainGui'),'execution_memory',tmp);

%% Helping function
    function str = string_generator(strlength)
        % Character Set
        character_set = char(['a':'z' '0':'9']) ;
        % Pick N numbers
        length_string = strlength ; 
        i = ceil(length(character_set)*rand(1,length_string)) ; % with repeat
        % Generate string
        str = ['x',character_set(i)];
    end
end

