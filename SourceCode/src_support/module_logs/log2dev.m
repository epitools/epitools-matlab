function log2dev(strLogContent, intLogCode, intOutputDev, pntDevice, pntHandle)
%LOG2DEV This function stores log directives printed by the program.
%   The advantage of using this function instead of @disp or @cprintf is given by
%   its obiquitous outputs and automatic redirection.
%   Example
%
%   log2dev( getappdata(hMainGui, 'status_application'), 'hMainGui', 'statusbar', 0 );
%
%

if nargin < 3
    
    intOutputDev = [];
    pntDevice = [];
    pntHandle = [];
    
end

W = evalin('base','whos'); %or 'base'
doesAexist = sum(strcmp({W(:).name},'log_settings'));

% In case of no-gui execution
if(~doesAexist)
    
    %% Check where the user has selected to store the log statements
    % Recall setting object
    hMainGui = getappdata(0, 'hMainGui');
    
    if(isappdata(hMainGui,'settings_execution'))
        SettingsExecution = getappdata(hMainGui,'settings_execution');
        
        
        % Log devices
        if (isfield(SettingsExecution, 'log_device'))
            
            if isempty(intOutputDev)
                intOutputDev = SettingsExecution.log_device;
            end
        end
        
        % Log levels to print
        if (isfield(SettingsExecution, 'log_level'))
            listLevels = SettingsExecution.log_level;
        end
        
        % Retrieve log file name
        
        settings_executionuid = getappdata(hMainGui,'settings_executionuid');
        stgObj = getappdata(hMainGui,'settings_objectname');
        if(isempty(stgObj))
                
            fullpath = '~/';
                
        else
            settings_executionuid = getappdata(hMainGui,'settings_executionuid');
            
            %if(exists(['~/',settings_executionuid])) 
                % if initial log file exist, then copy lines in the new one
                % and remove it. 
                
                
                % remove file
            %end
            fullpath = stgObj.data_fullpath;
        end
        
        
        logfilepath = [fullpath,'/',settings_executionuid];
    end
    
else
    
    
    local_var = evalin('base', 'log_settings');
    
    % Log devices
    if (isfield(local_var, 'log_device'))
        
        %if isempty(intOutputDev)
            intOutputDev = local_var.log_device;
        %end
    else
        return;
    end
    
    % Log levels to print
    if (isfield(local_var, 'log_level'))
        listLevels = local_var.log_level;
    else
        return;
    end
    
end
% If the log level is not specified in the current execution settings, then
% suppress it from printing.

if (~strcmp(intLogCode, listLevels))
    return;
end


%% Execute according the directives
for i=1:numel(intOutputDev)
    
    output_device = intOutputDev(i);
    
    
    switch output_device
        
        % Log to GUI device (status bar)
        case 0
            tmpDeviceContenitor = getappdata(0,pntDevice);
            tmpHandleContenitor = guidata(tmpDeviceContenitor);
            
            
            set(tmpHandleContenitor.(pntHandle), 'String', strcat(datestr(now,0),' | [',intLogCode,'] | ',strLogContent));
            
            
            % Log to FILE device
        case 1
            
            % Prepare log line
            string2print = [datestr(now,0),sprintf(' : %s\t:  %s ',intLogCode,strLogContent)];
            
            % Test if the log file is available
            test = fopen(logfilepath, 'a');  
            if (test == -1)
                log2dev(sprintf('Log file not found @ %s',logfilepath),'WARN',[3,4]);
            else

                % Now write the log line to the log file                                                        
                write = fprintf(test, '%s\n', string2print);
                % Close file 
                fclose(test);
            
            end
            
            % Log to generic GUI device
        case 2
            
            tmpDeviceContenitor = getappdata(0,pntDevice);
            tmpHandleContenitor = guidata(tmpDeviceContenitor);
            
            set(tmpHandleContenitor.(pntHandle), 'String', strLogContent);
            
            
            % Log to CONSOLE device
        case 3
            
            disp([datestr(now,0),sprintf(' : %s\t:  %s ',intLogCode,strLogContent)]);
            
            
            % Log to LOG GUI DEVICE device
        case 4
            
            log_guidevice([datestr(now,0),sprintf(' : %s\t:  %s ',intLogCode,strLogContent)])
            
        otherwise
            
            return;
            
    end
    
end

end

