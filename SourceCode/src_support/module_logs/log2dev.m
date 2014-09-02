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

    intOutputDev = 3;
    pntDevice = [];
    pntHandle = [];
             
end

% Disable logging if run in commandline mode. 
globalSettings = whos('global');
if(~isempty(globalSettings))

    return;

end

%% Check where the user has selected to store the log statements
% Recall setting object
hMainGui = getappdata(0, 'hMainGui');

if(isappdata(hMainGui,'settings_execution'))
    SettingsExecution = getappdata(hMainGui,'settings_execution');
    stgObj = getappdata(hMainGui,'settings_objectname');
    
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
        
        

    % Log to generic GUI device
    case 2 
       
        tmpDeviceContenitor = getappdata(0,pntDevice);
        tmpHandleContenitor = guidata(tmpDeviceContenitor);
        
        set(tmpHandleContenitor.(pntHandle), 'String', strLogContent);


    % Log to CONSOLE device
    case 3

        disp([datestr(now,0),sprintf(' : %s\t:  %s ',intLogCode,strLogContent)]);


    otherwise



    end

end

end

