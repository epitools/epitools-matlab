function [ idxPoints ] = PreparingData2Load( stgObj )
%PREPARINGDATA2LOAD This function will prepare your data to be loaded in
%Epitools. This allows the programm to load only the files you previously
%set to be sent to further analysis steps.

% Given the setting object populated with images metadata file, extract the
% list of files and fill a cell list containing all the informations regard
% accessing data files.

%% Prepare Planes (idx) ID images
idxPoints.I = convertInput2Mat(8);

%% Prepare Planes (z) Z axis
idxPoints.Z = convertInput2Mat(9);

%% Prepare Planes (c) Channels
idxPoints.C = convertInput2Mat(10);

%% Prepare Planes (t) Time Points
idxPoints.T = convertInput2Mat(11);


%% Help functions

    function idxPoints = convertInput2Mat(intItem2Extract)
    % @convertInput2Mat
    % Function to convert user char inputs into single points to pass to
    % further analysis steps.

        % Prepare vector containing indexes of time points to consider:
        idxPoints = [];
        
        % Table readout from MAIN module
        for i=1:size(stgObj.analysis_modules.Main.data,1);
            
            tmpidxPoints = [];
            
            switch intItem2Extract
                
                case 8
                
                    % Discard files where exec property is 0
                    if(logical(cell2mat(stgObj.analysis_modules.Main.data(i,8))) == false)
                        continue;
                    else
                        idxPoints = [idxPoints,i];
                    end
                
                otherwise
                                    
                    % Discard files where exec property is 0
                    if(logical(cell2mat(stgObj.analysis_modules.Main.data(i,8))) == false)
                        continue;
                    end
                    
                    % all the ranges
                    ans1 = regexp(regexp(char(stgObj.analysis_modules.Main.data(i,intItem2Extract)), '([0-9]*)-([0-9]*)', 'match'),'-','split');
                    
                    for o=1:length((ans1))
                        
                        %idxPoints(i,:) = [idxPoints(i,:),str2double(ans1{o}{1}):str2double(ans1{o}{2})];
                        tmpidxPoints = [tmpidxPoints,str2double(ans1{o}{1}):str2double(ans1{o}{2})];
                        
                    end
                    
                    
                    % all the singles *ATT: it can generate NAN values (getting rid of
                    % them with line > 51
                    ans2 = regexp(char(stgObj.analysis_modules.Main.data(i,intItem2Extract)), '([0-9]*)-([0-9]*)', 'split');
                    
                    for o=1:length(ans2)
                        
                        comma_separated_values = regexp (ans2{o}, '_', 'split');
                        
                        tmpidxPoints = [tmpidxPoints,str2double(comma_separated_values)];
                        
                    end
                    
                    tmpidxPoints = tmpidxPoints(~isnan(tmpidxPoints));
                    tmpidxPoints = sort(tmpidxPoints);
                    
                    idxPoints(i,:) = tmpidxPoints;
                    
            end
        end
    end


end

