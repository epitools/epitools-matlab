function [ status, argout ] = PreparingData2Load( input_args, varargin )
%PREPARINGDATA2LOAD Creating indeces for selected files to load
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
%% Elaboration
% Prepare Planes (idx) ID images
idxPoints.I = convertInput2Mat(8);
% Prepare Planes (z) Z axis
idxPoints.Z = convertInput2Mat(9);
% Prepare Planes (c) Channels
idxPoints.C = convertInput2Mat(10);
% Prepare Planes (t) Time Points
idxPoints.T = convertInput2Mat(11);
%% Help functions
    function idxPoints = convertInput2Mat(intItem2Extract)
    % @convertInput2Mat
    % Function to convert user char inputs into single points to pass to
    % further analysis steps.
        % Prepare struct containing indexes of time points to consider:
        idxPoints = [];
        % Table readout from MAIN module
        for i=1:size(input_args.analysis_modules.Main.data,1);
            tmpidxPoints = [];
            switch intItem2Extract 
                case 8
                    % Discard files where exec property is 0
                    if(logical(cell2mat(input_args.analysis_modules.Main.data(i,8))) == false)
                        continue;
                    else
                        idxPoints = [idxPoints,i];
                    end
                otherwise                
                    % Discard files where exec property is 0
                    if(logical(cell2mat(input_args.analysis_modules.Main.data(i,8))) == false)
                        continue;
                    end
                    % all the ranges
                    ans1 = regexp(regexp(char(input_args.analysis_modules.Main.data(i,intItem2Extract)), '([0-9]*)-([0-9]*)', 'match'),'-','split');
                    for o=1:length((ans1))
                        %idxPoints(i,:) = [idxPoints(i,:),str2double(ans1{o}{1}):str2double(ans1{o}{2})];
                        tmpidxPoints = [tmpidxPoints,str2double(ans1{o}{1}):str2double(ans1{o}{2})]; 
                    end
                    % all the singles *ATT: it can generate NAN values (getting rid of
                    % them with line -> 79
                    ans2 = regexp(char(input_args.analysis_modules.Main.data(i,intItem2Extract)), '([0-9]*)-([0-9]*)', 'split');
                    for o=1:length(ans2)
                        comma_separated_values = regexp (ans2{o}, ',', 'split');
                        tmpidxPoints = [tmpidxPoints,str2double(comma_separated_values)];
                    end
                    tmpidxPoints = tmpidxPoints(~isnan(tmpidxPoints));
                    tmpidxPoints = sort(tmpidxPoints);
                    idxPoints{i} = tmpidxPoints;
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
argout(1).description = 'Indices required to load image files';
argout(1).ref = varargin(1);
argout(1).object = idxPoints;
%% Status execution update 
status = 0;
end