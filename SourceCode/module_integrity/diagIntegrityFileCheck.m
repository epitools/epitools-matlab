function varargout = diagIntegrityFileCheck(varargin)

if(varargin)
    lstDirectory2Check = varargin{1};
end

hMainGui = getappdata(0, 'hMainGui');

if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        stgObj = getappdata(hMainGui,'settings_objectname');
    end
end

fig = figure('Visible','off',...
    'Name',['Directory integrity check [Not Passed for',lstDirectory2Check(1,1),']'],...
    'Toolbar', 'none',...
    'Resize', 'off',...
    'NumberTitle', 'off',...
    'Position',[0,0,520,100]);

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(fig,'Color',defaultBackground)

%set up app-data
setappdata(fig, 'directorypath', 'none');


ctrlConfirm  = uicontrol('Parent', fig,'Style','pushbutton',...
             'String','Confirm','Position',[435,10,70,25],...
             'Callback',{@ctrlDirConfirm_callback});

ctrlAbort = uicontrol('Parent', fig,'Style','pushbutton',...
             'String','Abort','Position',[360,10,70,25],...
             'Callback',{@ctrlDirAbort_callback});

txtCaption = uicontrol('Parent', fig,'Style','text',...
                'String',['Directory stored for:',lstDirectory2Check(1,1)],...
                'Position',[10 70 130 20],...
                 'HorizontalAlignment', 'left');
            
txtDirectoryPath = uicontrol('Parent', fig,'Style','edit',...
                'String',lstDirectory2Check(1,2),...
                'Tag','DirectoryPath',...
                'Position',[10, 50, 350, 20],...
                 'HorizontalAlignment', 'left');

ctrlDirSelection = uicontrol('Parent', fig,'Style','pushbutton',...
                            'String','Select','Position',[360,47,70,25],...
                            'Callback',{@ctrlDirSelection_callback});

         
% Move the GUI to the center of the screen.
movegui(fig,'center')
% No menu bar
set(fig,'MenuBar', 'None')
% Make the GUI visible.
set(fig,'Visible','on')

uiwait(fig);

    %% Select a directory and pass the value to the GUI variable
    
    function varargout = ctrlDirSelection_callback(hObject,eventdata,handles)

        strDirectoryPath = uigetdir('~','Select the directory');
        
        if (strDirectoryPath)
            varargout{1} = strDirectoryPath;
        end
        
        set(txtDirectoryPath,'String',strDirectoryPath);
        
end

    %% Confirm the changes and close the gui
    function varargout = ctrlDirConfirm_callback(hObject,eventdata,handles)
        
        delete(fig);
    end

    %% Abort the process
    function varargout = ctrlDirAbort_callback(hObject,eventdata,handles)
        delete(fig);
    end
end
