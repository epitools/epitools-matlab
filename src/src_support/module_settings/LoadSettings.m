function [status] = LoadSettings(settingfilepath)

% check if [settingfilepath] is not empty
if (isempty(settingfilepath))
    
    error('No file path has been specified');
    
    status = 1;
    return 
end

% distinguish between supported extensions
[pathstr,name,ext] = fileparts(settingfilepath);

switch ext
    case '.etl'
        
        % load file as a mat file (same wrapped content)
        load(settingfilepath, '-mat');
        
    case '.txt'
        
        % call parser for txt files
        
    case '.dat'
        
        % call parser for ascii files
        
    case '.mat'
        
        % load file as an etl file (same wrapped content)
        load(settingfilepath);
        
        
    otherwise
        
        status = 1;
        error('The specified file %s is not supported',name);
        
end

% return a successfull status            
status = 0;           
end