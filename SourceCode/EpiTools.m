function varargout = EpiTools(varargin)
% EPITOOLS MATLAB code for EpiTools.fig
%      EPITOOLS, by itself, creates a new EPITOOLS or raises the existing
%      singleton*.
%
%      H = EPITOOLS returns the handle to a new EPITOOLS or the handle to
%      the existing singleton*.
%
%      EPITOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EPITOOLS.M with the given input arguments.
%
%      EPITOOLS('Property','Value',...) creates a new EPITOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EpiTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EpiTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EpiTools

% Last Modified by GUIDE v2.5 26-Jul-2014 19:06:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EpiTools_OpeningFcn, ...
                   'gui_OutputFcn',  @EpiTools_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EpiTools is made visible.
function EpiTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EpiTools (see VARARGIN)

% Choose default command line output for EpiTools
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

stsFunOut = LoadEpiTools();

% UIWAIT makes EpiTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%set up app-data
setappdata(0  , 'hMainGui'    , gcf);
setappdata(gcf, 'data_specifics', 'none');
setappdata(gcf, 'icy_is_used', 0);
setappdata(gcf, 'icy_is_loaded', 0);
setappdata(gcf, 'icy_path', 'none');
setappdata(gcf, 'settings_objectname', '');
setappdata(gcf, 'status_application',stsFunOut);

%obtain absolute location on system
current_script_path = mfilename('fullpath');
[file_path,~,~] = fileparts(current_script_path);
setappdata(gcf, 'settings_rootpath', file_path);

handles_connection(hObject,handles)

% --- Outputs from this function are returned to the command line.
function varargout = EpiTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA

diary off;
% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function handles_connection(hObject,handles)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
hMainGui = getappdata(0, 'hMainGui');

% -------------------------------------------------------------------------
% Log status of previous operations on GUI
% set(handles.statusbar, 'String',getappdata(hMainGui, 'status_application') );
log2dev( getappdata(hMainGui, 'status_application'), 'hMainGui', 'statusbar', 'FR0001' , 0 );
% -------------------------------------------------------------------------

if(isappdata(hMainGui,'settings_objectname'))
    
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
    
        stgObj = getappdata(hMainGui,'settings_objectname');

        set(handles.mainTextBoxImagePath,'string',stgObj.data_imagepath);
        set(handles.mainTextBoxSettingPath,'string',stgObj.data_fullpath);
        set(handles.figure1, 'Name', ['EpiTools | ', stgObj.analysis_code, ' - ' , stgObj.analysis_name])
        LoadControls(hMainGui, stgObj);
        
        % -------------------------------------------------------------------------
        % Log status of previous operations on GUI
        log2dev(sprintf('A setting file %s%s%s has been correctly loaded in the framework', stgObj.analysis_name, stgObj.analysis_version,stgObj.data_extensionmask  ), 'hMainGui', 'statusbar', 'LD0001', 0 );
        % -------------------------------------------------------------------------
        
    end 
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in use_icy_checkbox.
function use_icy_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to use_icy_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_icy_checkbox

hMainGui = getappdata(0, 'hMainGui');

if (get(hObject,'Value') == get(hObject,'Max'))
    %only enter when tick is activated
    
    %get app data
    icy_path =      getappdata(hMainGui,'icy_path');
    icy_is_loaded = getappdata(hMainGui,'icy_is_loaded');
    icy_is_used =   getappdata(hMainGui,'icy_is_used');
    
    %Check if icy's path was specified
    if(strcmp(icy_path,'none'))
        %user specification if none defined
        icy_path = uigetdir('~/','Please locate /path/to/Icy/plugins/ylemontag/matlabcommunicator');
        if(icy_path == 0) %user cancel
            icy_path = 'none';
        end
    end

    %Check if icy functions are already loaded
    if(~icy_is_loaded)
        if(exist([icy_path,'/icy_init.m'],'file'))
            fprintf('Successfully detected ICY at:%s\n',icy_path);
            addpath(icy_path);
            icy_init();
            icy_is_used = 1;
            icy_is_loaded = 1;
        else
            fprintf('ERROR, current icy path is not valid: %s\n',icy_path);
            icy_path = 'none';
        end
    else
        icy_is_used = 1;
    end
    
    %Check if icy is used
    if(icy_is_used ~= 1) 
        %do not check if icy_path was not set
        set(hObject,'Value',get(hObject,'Min'));
    end
    
    %set app data
    setappdata(hMainGui,'icy_path',icy_path);
    setappdata(hMainGui,'icy_is_loaded',icy_is_loaded);
    setappdata(hMainGui,'icy_is_used',icy_is_used);
    
else
    %checkbox is deselected
    setappdata(hMainGui,'icy_is_used',0);
end

% --- Executes during object creation, after setting all properties.
function use_icy_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to use_icy_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function A_Proj_Callback(hObject, eventdata, handles)
% hObject    handle to A_Proj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Projection';

if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        if(sum(strcmp(fields(stgObj.analysis_modules), strModuleName)) == 1)
            
           out = questdlg(sprintf('If you proceed with this action, I will delete some previously generated results...\n\n Would you like to override %s results?', strModuleName), 'Override analysis module','Yes', 'No','No');

            switch out
                case 'Yes'
                    GBL_SaveAnalysis(hObject, handles);
    
                case 'No'
                    helpdlg(sprintf('Allright, everything is perfectly fine... \n I used my magic powers and all your results are safe and sound!'), 'Analysis restoring...');
                    return;
            end 
            
        else
            
            stgObj.CreateModule(strModuleName);
            setappdata(hMainGui, 'settings_objectname', stgObj);
            
        end
    end
    
end
out = ProjectionGUI(stgObj);
uiwait(out);
handles_connection(hObject,handles)


% --------------------------------------------------------------------
function A_StackReg_Callback(hObject, eventdata, handles)
% hObject    handle to A_StackReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Stack_Registration';

if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        if(sum(strcmp(fields(stgObj.analysis_modules), strModuleName)) == 1)
            
           out = questdlg(sprintf('If you proceed with this action, I will delete some previously generated results...\n\n Would you like to override %s results?', strModuleName), 'Override analysis module','Yes', 'No','No');

            switch out
                case 'Yes'
                    GBL_SaveAnalysis(hObject, handles);
    
                case 'No'
                    helpdlg(sprintf('Allright, everything is perfectly fine... \n I used my magic powers and all your results are safe and sound!'), 'Analysis restoring...');
                    return;
            end 
            
        else
            
            stgObj.CreateModule(strModuleName);
            setappdata(hMainGui, 'settings_objectname', stgObj);
            
        end
    end
    
end
out = RegistrationGUI(stgObj);
uiwait(out);
handles_connection(hObject,handles)


% --------------------------------------------------------------------
function A_CLAHE_Callback(hObject, eventdata, handles)
% hObject    handle to A_CLAHE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Contrast_Enhancement';

if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        if(sum(strcmp(fields(stgObj.analysis_modules), strModuleName)) == 1)
            
           out = questdlg(sprintf('If you proceed with this action, I will delete some previously generated results...\n\n Would you like to override %s results?', strModuleName), 'Override analysis module','Yes', 'No','No');

            switch out
                case 'Yes'
                    GBL_SaveAnalysis(hObject, handles);
    
                case 'No'
                    helpdlg(sprintf('Allright, everything is perfectly fine... \n I used my magic powers and all your results are safe and sound!'), 'Analysis restoring...');
                    return;
            end 
            
        else
            
            stgObj.CreateModule(strModuleName);
            setappdata(hMainGui, 'settings_objectname', stgObj);
            
        end
    end
    
end
out = ImproveContrastGUI(stgObj);
uiwait(out);
handles_connection(hObject,handles)


% --------------------------------------------------------------------
function A_Segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to A_Segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Segmentation';

if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        if(sum(strcmp(fields(stgObj.analysis_modules), strModuleName)) == 1)
            
           out = questdlg(sprintf('If you proceed with this action, I will delete some previously generated results...\n\n Would you like to override %s results?', strModuleName), 'Override analysis module','Yes', 'No','No');

            switch out
                case 'Yes'
                    GBL_SaveAnalysis(hObject, handles);
    
                case 'No'
                    helpdlg(sprintf('Allright, everything is perfectly fine... \n I used my magic powers and all your results are safe and sound!'), 'Analysis restoring...');
                    return;
            end 
            
        else
            
            stgObj.CreateModule(strModuleName);
            setappdata(hMainGui, 'settings_objectname', stgObj);
            
        end
    end
    
end
out = SegmentationGUI(stgObj);
uiwait(out);
handles_connection(hObject,handles);


% --------------------------------------------------------------------
function A_Tracking_Callback(hObject, eventdata, handles)
% hObject    handle to A_Tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Tracking';

if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        if(sum(strcmp(fields(stgObj.analysis_modules), strModuleName)) == 1)
            
           out = questdlg(sprintf('If you proceed with this action, I will delete some previously generated results...\n\n Would you like to override %s results?', strModuleName), 'Override analysis module','Yes', 'No','No');

            switch out
                case 'Yes'
                    GBL_SaveAnalysis(hObject, handles);
    
                case 'No'
                    helpdlg(sprintf('Allright, everything is perfectly fine... \n I used my magic powers and all your results are safe and sound!'), 'Analysis restoring...');
                    return;
            end 
            
        else
            
            stgObj.CreateModule(strModuleName);
            setappdata(hMainGui, 'settings_objectname', stgObj);
            
        end
    end
    
end
out = TrackingIntroGUI(stgObj);
uiwait(out);
handles_connection(hObject,handles)


% --------------------------------------------------------------------
function A_Skeletons_Callback(hObject, eventdata, handles)
% hObject    handle to A_Skeletons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Skeletons';

if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        if(sum(strcmp(fields(stgObj.analysis_modules), strModuleName)) == 1)
            
           out = questdlg(sprintf('If you proceed with this action, I will delete some previously generated results...\n\n Would you like to override %s results?', strModuleName), 'Override analysis module','Yes', 'No','No');

            switch out
                case 'Yes'
                    GBL_SaveAnalysis(hObject, handles);
    
                case 'No'
                    helpdlg(sprintf('Allright, everything is perfectly fine... \n I used my magic powers and all your results are safe and sound!'), 'Analysis restoring...');
                    return;
            end 
            
        else
            
            stgObj.CreateModule(strModuleName);
            setappdata(hMainGui, 'settings_objectname', stgObj);
            
        end
    end
    
end
SkeletonConversion(stgObj);
uiwait;
handles_connection(hObject,handles)


% --------------------------------------------------------------------
function F_New_Callback(hObject, eventdata, handles)
% hObject    handle to F_New (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');

% Check if there is setting file loaded in the application
if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        % Ask if you want to save it before generate a new one
        interrupt = GBL_SaveAnalysis(hObject, handles);
        
        if (interrupt == 1)
            return;
        end
        
        
    end
end

% Initialize a new setting file and call the form FilePropertiesGUI
stgObj = settings();
stgObj.CreateModule('Main');
setappdata(hMainGui, 'settings_objectname', stgObj);

out = FilePropertiesGUI(getappdata(hMainGui,'settings_objectname'));
uiwait(out);

GBL_SaveAnalysis(hObject, handles, 1);
stgObj = getappdata(hMainGui,'settings_objectname');

% logging on external device
diary(strcat(stgObj.data_fullpath,'/out-',datestr(now,30),'.log'));
diary on;

% Parallel
installed_toolboxes=ver;
if(any(strcmp('Parallel Computing Toolbox', {installed_toolboxes.Name})))
    if(stgObj.platform_units ~= 1); 
        matlabpool('local',stgObj.platform_units); 
    end
end

% Update handles structure
handles_connection(hObject, handles)

% --------------------------------------------------------------------
function F_Open_Callback(hObject, eventdata, handles)
% hObject    handle to F_Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMainGui = getappdata(0, 'hMainGui');


[strSettingFileName,strSettingFilePath,~] = uigetfile('~/*.etl','Select analysis file');

% If the user select a file to open
if(strSettingFilePath ~= 0)

    load([strSettingFilePath,strSettingFileName], '-mat');
    setappdata(hMainGui, 'settings_objectname', stgObj);
    
    h = msgbox(sprintf('Name: %s  \nVersion: %s \nAuthor: %s \n\ncompleted with success!',...
        stgObj.analysis_name,...
        stgObj.analysis_version,...
        stgObj.user_name ),... 
        'Operation succesfully completed','help');
    
end

% Parallel
installed_toolboxes=ver;
if(any(strcmp('Parallel Computing Toolbox', {installed_toolboxes.Name})))
    if(stgObj.platform_units ~= 1);
        matlabpool('local',stgObj.platform_units);
    end
end

diary(strcat(stgObj.data_fullpath,'out-',datestr(now,30),'log'));
diary on;
handles_connection(hObject, handles)


% --------------------------------------------------------------------
function F_ImportSettings_Callback(hObject, eventdata, handles)
% hObject    handle to F_ImportSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strRootPath = getappdata(hMainGui,'settings_rootpath');
stgObj = getappdata(hMainGui, 'settings_objectname');

copyfile(fullfile(strRootPath,...
         'images','emblem-notice.png'));
[icoInformation] = imread('emblem-notice.png'); 


[strSettingFileName,strSettingFilePath,~] = uigetfile('~/*.etl','Select an analysis file to copy the settings from');

% If the user select a file to open
if(strSettingFilePath ~= 0)

    tmp = load([strSettingFilePath,strSettingFileName], '-mat', 'stgObj');
    
    stgObj.analysis_modules = tmp.stgObj.analysis_modules;
    
    setappdata(hMainGui, 'settings_objectname', stgObj);
    
    h = msgbox([sprintf('For the current analysis file \n\n analysis>  %s  \n\n',...
                strcat(stgObj.analysis_code,' | ',stgObj.analysis_name,' -  version> ',stgObj.analysis_version)),...
                sprintf('you imported from the analysis file \n\n analysis>  %s \n\n',...
                strcat(tmp.stgObj.analysis_code,' | ',tmp.stgObj.analysis_name,' -  version>',tmp.stgObj.analysis_version)),...
                'all available modules. The operation concluded successfully!'],... 
        'Importing operation succesfully completed','custom',icoInformation);
    
end

handles_connection(hObject, handles)

% --------------------------------------------------------------------
function E_Undo_Callback(hObject, eventdata, handles)
% hObject    handle to E_Undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function E_Redo_Callback(hObject, eventdata, handles)
% hObject    handle to E_Redo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function E_Preferences_Callback(hObject, eventdata, handles)
% hObject    handle to E_Preferences (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function F_Save_Callback(hObject, eventdata, handles)
% hObject    handle to F_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GBL_SaveAnalysis(hObject, handles);

% --------------------------------------------------------------------
function F_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to F_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GBL_SaveAnalysis(hObject, handles);
out = parcluster;
if (out.NumWorkers > 1); matlabpool close; end
close(handles.figure1);


% --------------------------------------------------------------------
function MHelp_Callback(hObject, eventdata, handles)
% hObject    handle to MHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MCredits_Callback(hObject, eventdata, handles)
% hObject    handle to MCredits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function mainTextBoxImagePath_Callback(hObject, eventdata, handles)
% hObject    handle to mainTextBoxImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mainTextBoxImagePath as text
%        str2double(get(hObject,'String')) returns contents of mainTextBoxImagePath as a double

% --- Executes during object creation, after setting all properties.
function mainTextBoxImagePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainTextBoxImagePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mainTextBoxSettingPath_Callback(hObject, eventdata, handles)
% hObject    handle to mainTextBoxSettingPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mainTextBoxSettingPath as text
%        str2double(get(hObject,'String')) returns contents of mainTextBoxSettingPath as a double


% --- Executes during object creation, after setting all properties.
function mainTextBoxSettingPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainTextBoxSettingPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function F_Properties_Callback(hObject, eventdata, handles)
% hObject    handle to F_Properties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMainGui = getappdata(0, 'hMainGui');

if(getappdata(hMainGui,'settings_objectname') ~= 0)

    out = FilePropertiesGUI(getappdata(hMainGui,'settings_objectname'));
    uiwait(out);
else
    msgbox('No analysis file loaded!'); 
end

% Update handles structure
handles_connection(hObject, handles)


function argout = GBL_SaveAnalysis(hObject, handles, intForce)
hMainGui = getappdata(0, 'hMainGui');
strRootPath = getappdata(hMainGui,'settings_rootpath');
stgObj = getappdata(hMainGui,'settings_objectname');

if nargin < 3

    intForce = 0;

end


if (intForce == 1)
    
    save(strcat(stgObj.data_fullpath,'/',stgObj.analysis_name,'.',stgObj.analysis_version,'.etl'), 'stgObj');

else
    
       
    out = questdlg('Would you like to save the current analysis?', 'Save analysis','Yes', 'No','Abort', 'Abort');
    
    switch out
        case 'Yes'
            
            save(strcat(stgObj.data_fullpath,'/',stgObj.analysis_name,'.',stgObj.analysis_version,'.etl'), 'stgObj');
            argout = 0;
        case 'No'
            
            msgbox('Changes have been discarded');
            argout = 0;
        case 'Abort'
            argout = 1;
    end
end


% --------------------------------------------------------------------
function A_Polycrop_Callback(hObject, eventdata, handles)
% hObject    handle to A_Polycrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strRootPath = getappdata(hMainGui,'settings_rootpath');
stgObj = getappdata(hMainGui,'settings_objectname');

strModuleName = 'Polygon_Masking';

if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        if(sum(strcmp(fields(stgObj.analysis_modules), strModuleName)) == 1)
            
           out = questdlg(sprintf('If you proceed with this action, I will delete some previously generated results...\n\n Would you like to override %s results?', strModuleName), 'Override analysis module','Yes', 'No','No');

            switch out
                case 'Yes'
                    GBL_SaveAnalysis(hObject, handles);
    
                case 'No'
                    helpdlg(sprintf('Allright, everything is perfectly fine... \n I used my magic powers and all your results are safe and sound!'), 'Analysis restoring...');
                    return;
            end 
            
        else
            
            stgObj.CreateModule(strModuleName);
            setappdata(hMainGui, 'settings_objectname', stgObj);
            
        end
    end
    
end

tmpSegObj = load([stgObj.data_analysisdir,'/SegResults']);
tmpRegObj = load([stgObj.data_analysisdir,'/RegIm']);

[polygonal_mask, cropped_CellLabelIm] = PolygonCrop(tmpRegObj.RegIm, tmpSegObj.CLabels);

save([stgObj.data_analysisdir,'/PoligonalMask'],'polygonal_mask');
save([stgObj.data_analysisdir,'/CroppedCellLabels'],'cropped_CellLabelIm');

stgObj.AddResult(strModuleName,'polygonal_mask_path',strcat(stgObj.data_analysisdir,'/PoligonalMask'));
stgObj.AddResult(strModuleName,'cropped_cell_labels',strcat(stgObj.data_analysisdir,'/CroppedCellLabels'));

waitfor(polygonal_mask);

handles_connection(hObject,handles)


% --- Executes when uipanel5 is resized.
function uipanel5_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
