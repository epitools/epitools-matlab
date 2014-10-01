function [ varargout ] = DiscardAnalysisModules( curModuleName, stgObj )
%DISCARDANALYSISMODULES Summary of this function goes here
%   Detailed explanation goes here
varargout{1} = true;

% Get the module names
arrayStgFields = fields(stgObj.analysis_modules);

% Find position on the modules array of the current module
intIDX = find(strcmp(arrayStgFields, curModuleName));



% Delete all the downstream modules 
for i=(intIDX+1):length(arrayStgFields)

    if (isempty(stgObj.analysis_modules.(char(arrayStgFields(i))).results));continue;end
    % Move results into backup folder
    arrayResults = fields(stgObj.analysis_modules.(char(arrayStgFields(i))).results);
    
    for o=1:numel(arrayResults) 
        
        if(strcmp(arrayResults,'tracking_file_path'));continue;end
        
        % File name
        strSourceFileName = stgObj.analysis_modules.(char(arrayStgFields(i))).results.(char(arrayResults(o)));
        
        % File location 
        strSourceFilePath = stgObj.data_analysisoutdir;
        
        % Check existance backup directory
        
        if(~exist([strSourceFilePath,'/Backups'],'dir'))
            mkdir([strSourceFilePath,'/Backups']);
        end
        
        if(strcmp(char(arrayStgFields(i)), 'Skeletons'))
        
        if(~exist([strSourceFilePath,'/Backups/skeletons'],'dir'))
            mkdir([strSourceFilePath,'/Backups/skeletons']);
        end
        
        end
        
        
        
        % Copy file  [strSourceFilePath,'/',strSourceFileName]
        if(exist([strSourceFilePath,'/',strSourceFileName],'file')==2)
            copyfile([strSourceFilePath,'/',strSourceFileName], [strSourceFilePath,'/Backups/',strSourceFileName]);
        else
            continue;
        end
        
        % Remove file
        delete([strSourceFilePath,'/',strSourceFileName]);
        
    end
    
    % Destroy module
    stgObj.DestroyModule(arrayStgFields(i));
    
end

end

