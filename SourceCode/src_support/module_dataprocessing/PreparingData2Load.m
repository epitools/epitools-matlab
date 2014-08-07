function [ output_args ] = PreparingData2Load( stgObj )
%PREPARINGDATA2LOAD This function will prepare your data to be loaded in
%Epitools. This allows the programm to load only the files you previously
%set to be sent to further analysis steps.

% Given the setting object populated with images metadata file, extract the
% list of files and fill a cell list containing all the informations regard
% accessing data files.


%% Prepare Planes (z) Z axis
    idxPoints.Z = convertChar2Mat(9);

%% Prepare Planes (c) Channels
    idxPoints.C = convertChar2Mat(10);

%% Prepare Planes (t) Time Points
    idxPoints.T = convertChar2Mat(11);


%% Help functions
% @convertChar2Mat
% Function to convert user char inputs into single points to pass
% to further analysis steps

    function idxPoints = convertChar2Mat(intItem2Extract)
        
        idxPoints = [];
        % Prepare vector containing indexes of time points to consider:
        % all the ranges
        ans1 = regexp(regexp(char(stgObj.analysis_modules.Main.data(i,intItem2Extract)), '([0-9]*)-([0-9]*)', 'match'),'-','split');
        
        for o=1:length((ans1))
            
            idxPoints = [idxPoints,str2double(ans1{o}{1}):str2double(ans1{o}{2})];
            
        end
        
        % all the singles *ATT: it can generate NAN values (getting rid of
        % them with line > 51
        ans2 = regexp(char(stgObj.analysis_modules.Main.data(i,intItem2Extract)), '([0-9]*)-([0-9]*)', 'split');
        
        for o=1:length(ans2)
            
            comma_separated_values = regexp (ans2{o}, '_', 'split');
            
            idxPoints = [idxPoints,str2double(comma_separated_values)];
            
        end
        
        idxPoints = idxPoints(~isnan(idxPoints));
        idxPoints = sort(idxPoints);
        
    end


end

