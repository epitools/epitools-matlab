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

    % Move results into backup folder
    arrayResults = fields(stgObj.analysis_modules.(char(arrayStgFields(i))).results);
    
    for o=1:numel(arrayResults) 
       
        % File name
        strSourceFileName = stgObj.analysis_modules.(char(arrayStgFields(i))).results.(char(arrayResults(o)));
        
        % File location 
        strSourceFilePath = stgObj.data_analysisoutdir;
        
        % Check existance backup directory
        
        if(~exist([strSourceFilePath,'/Backups'],'dir'))
            mkdir([strSourceFilePath,'/Backups']);
        end
            

        % Copy file
        copyfile([strSourceFilePath,'/',strSourceFileName], [strSourceFilePath,'/Backups/',strSourceFileName]);
        
        % Remove file
        delete([strSourceFilePath,'/',strSourceFileName]);
        
    end
    
    % Destroy module
    stgObj.DestroyModule(arrayStgFields(i));
    
end

end

