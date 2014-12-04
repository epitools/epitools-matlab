function [status,argout] = np02_test( input_args, varargin )
%NP02_TEST Toy function demonstrating server-client functionalities
% ------------------------------------------------------------------------------
% PREAMBLE 
% In this section describing function purpose and execution. This is a toy demo 
% of function new style.
% INPUT 
%   1. input_args:  variable containing a string of characters
%   2. varargin:    variable containing extra parameters for ref association 
%                   during output formatting (might not be implemented)
% OUTPUT
%   1. status:  status elaboration (0  executed correctly; > 0 fatal error)
%   2. argout:  variable containing a structure with output objects, description 
%               and ref association
% REFERENCE
% AUTHOR:   Lorenzo Gatti (lorenzo.gatti.89@gmail.com)
% DATE:     4.12.14 V1.0 for EpiTools 2.0 beta
% ------------------------------------------------------------------------------
%% Retrieve supplementary arguments
if (nargin<2)
    varargin(1:2) = {'OUT1', 'OUT2'};
end
%% Status initialization
status = 1;
%% Elaboration
% Count characters in the string
numelements = numel(input_args);
% Histogram characters in a string
c = cellstr(input_args')';
dim=2;
%Initialize the 'cell_array'
cell_array=cell([2 size(c,dim)]);
inc=1;
for i=1:size(c,dim)
    %Compare the elements in the 'cell_array' with the elements in 'c'
   if(strcmp(cell_array(1,:),c(i))==0)
    %If the element is not present, then add it to 'cell_array'.
    cell_array(1,inc)=c(i);
    %Find the number of occurence of the element
    num=   sum(strcmp(c(i),c));
    cell_array(2,inc)=num2cell(num);
    inc=inc+1;
   else
    %Delete if the element is already present in the 'cell_array'.
    cell_array(:,inc)='';
   end
end
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
argout(1).description = 'Number of input characters';
argout(1).ref = varargin(1);
argout(1).object = numelements;
% Second output variable
argout(2).description = 'Distribution of characters in the string';
argout(2).ref = '';
argout(2).object = cell_array;
%% Status execution update 
status = 0;
end

