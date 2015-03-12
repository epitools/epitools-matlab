function log2dev(strLogContent, intLogCode, intOutputDev, pntDevice, pntHandle, argvar)
%LOG2DEV This function stores log directives printed by the program.
% The advantage of using this function instead of @disp or @cprintf is 
% given by its obiquitous outputs and automatic redirection.
%   Examples:
%   log2dev('string-to-parse', 'hMainGui', 'statusbar', 0 );
%   log2dev('string-to-parse', 'INFO',0,'hMainGui', 'statusbar',{min,max,value});
%
if nargin < 3 
    intOutputDev = [];
    pntDevice = [];
    pntHandle = [];
    argvar = {};
elseif nargin == 5
    argvar = {};
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
        if (isfield(SettingsExecution.logs.devices.ctl_outdevices, 'actived'))
            if isempty(intOutputDev)
                intOutputDev = find(SettingsExecution.logs.devices.ctl_outdevices.actived);
            end
        end
        % Log levels to print
        if (isfield(SettingsExecution.logs.levels.ctl_levelsvalue, 'values'))
            listLevels = SettingsExecution.logs.levels.ctl_levelsvalue.values(find(SettingsExecution.logs.levels.ctl_levelsvalue.actived));
        end
        % Retrieve log file name
        settings_executionuid = getappdata(hMainGui,'settings_executionuid');
        stgObj = getappdata(hMainGui,'settings_objectname');
        if(isempty(stgObj))    
            fullpath = '~/';     
        else
            settings_executionuid = getappdata(hMainGui,'settings_executionuid');
            fullpath = stgObj.data_fullpath;
        end
        logfilepath = [fullpath,'/',settings_executionuid];
    end
else
    local_var = evalin('base', 'log_settings');
    % Log devices
    if (isfield(local_var, 'log_device'))
            intOutputDev = local_var.log_device;
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
if (~strcmp(intLogCode, listLevels)); return; end
%% Execute according the directives
for i=1:numel(intOutputDev)
    output_device = intOutputDev(i);
    switch output_device
        case 0 % Log to GUI device (statusbar)
            try
                sb = statusbar(getappdata(0,pntDevice), '');
                set(sb, 'Visible',true, 'Text', [datestr(now,0),' | [',intLogCode,'] | ',strLogContent]);
                %set(tmpHandleContenitor.(pntHandle), 'String', strcat(datestr(now,0),' | [',intLogCode,'] | ',strLogContent));
            catch err
                %disp(err)
            end            
            if ~isempty(argvar)
                try
                    set(sb.ProgressBar, 'Visible',true, 'Minimum',argvar{1}, 'Maximum',argvar{2}, 'Value',argvar{3});
                    if (argvar{2} == argvar{3});set(sb.ProgressBar, 'Visible',false); end
                catch err
                    %disp(err)
                end
            else
                try
                set(sb.ProgressBar, 'Visible',false);
                catch err
                    %disp(err)
                end
            end
        case 1 % Log to FILE device
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
        case 2 % Log to generic GUI device
            tmpDeviceContenitor = getappdata(0,pntDevice);
            tmpHandleContenitor = guidata(tmpDeviceContenitor);
            
            set(tmpHandleContenitor.(pntHandle), 'String', strLogContent);
        case 3 % Log to CONSOLE device
            disp([datestr(now,0),sprintf(' : %s\t:  %s ',intLogCode,strLogContent)]); 
        case 4 % Log to LOG GUI DEVICE device
            log_guidevice([datestr(now,0),sprintf(' : %s\t:  %s ',intLogCode,strLogContent)])
        otherwise
            return;    
    end % case 
end % for
end % function

