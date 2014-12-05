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

% Last Modified by GUIDE v2.5 27-Nov-2014 12:09:03

% Begin initialization code - DO NOT EDIT
%
% Add a splash screen before EpiTools loading
if ~nargin
SplashScreen;
end


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

% -------------------------------------------------------------------------
% Exec splash screen 
SplashHandle = findobj('tag','SplashScreenTag');
if ishandle(SplashHandle)
   close(SplashHandle);
end

% -------------------------------------------------------------------------
% Choose default command line output for EpiTools
handles.output = hObject;

% -------------------------------------------------------------------------
% Update handles structure
guidata(hObject, handles);

% -------------------------------------------------------------------------
% Disable warnings for structOnObject (occours when struct is saved in xml)
warning off MATLAB:structOnObject

% -------------------------------------------------------------------------
% Load libraries
stsFunOut = LoadEpiTools();

% -------------------------------------------------------------------------
%set up app-data
setappdata(0  , 'hMainGui'    , gcf);
setappdata(gcf, 'data_specifics', 'none');
setappdata(gcf, 'icy_is_used', 0);
setappdata(gcf, 'icy_is_loaded', 0);
setappdata(gcf, 'icy_path', 'none');
setappdata(gcf, 'settings_objectname', '');
setappdata(gcf, 'settings_execution', '');
setappdata(gcf, 'status_application',stsFunOut);
setappdata(gcf, 'settings_release',[]);
setappdata(gcf, 'settings_licence',[]);
setappdata(gcf, 'server_instances',struct());
setappdata(gcf, 'client_modules',struct());
setappdata(gcf, 'pool_instances',struct());
setappdata(gcf, 'settings_executionuid',...
                ['epitools-',...
                getenv('USER'),...
                '@',...
                char(getHostName(java.net.InetAddress.getLocalHost)),...
                '-',...
                datestr(now,29),...
                '.log']);

% Load release and licence files in EpiTools
if(exist('release.xml','file')==2); release = xml_read('release.xml'); setappdata(gcf, 'settings_release',release);end
if(exist('licence.xml','file')==2); licence = xml_read('licence.xml'); setappdata(gcf, 'settings_licence',licence);end

% -------------------------------------------------------------------------
% Prepare struct containing handles for UI
hUIControls = struct();
setappdata(gcf, 'hUIControls', hUIControls);

% -------------------------------------------------------------------------
%obtain absolute location on system
current_script_path = mfilename('fullpath');
[file_path,~,~] = fileparts(current_script_path);
setappdata(gcf, 'settings_rootpath', file_path);

% -------------------------------------------------------------------------
% Set log settings *device and level*
if(~exist('usersettings.xml', 'file'));generate_empty_settingsfile();end
    
settingsobj = xml_read('usersettings.xml');
setappdata(gcf, 'settings_execution', settingsobj);


% Open log window
log2dev('***********************************************************','INFO');
log2dev('*      EPITOOLS - IMAGE PROCESSING TOOL FOR EPITHELIA     * ','INFO');
log2dev('***********************************************************','INFO');

% -------------------------------------------------------------------------
% Add special procedure when the main windows is closed
hMainGui = getappdata(0,'hMainGui');
set(hMainGui, 'CloseRequestFcn', {@onMainWindowClose});

set(hMainGui,'Position',[0 0 400 100]);
movegui(hMainGui,'center');

% Installing Clients
installClients();

% Display discaimer
if(strcmp(settingsobj.licence.NDA.ctl_activate.values(find(settingsobj.licence.NDA.ctl_activate.actived)),'on'))
    out = disclaimerGUI();
    waitfor(out);
        if strcmp(out,'Exit')
            onMainWindowClose(hObject, eventdata, handles);
            return;
        end
end
handles_connection(hObject,handles);
% --- Outputs from this function are returned to the command line.
function varargout = EpiTools_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA

diary off;
% Get default command line output from handles structure
%varargout{1} = handles.output;
% --------------------------------------------------------------------
function handles_connection(hObject,handles)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
hMainGui = getappdata(0, 'hMainGui');
% -------------------------------------------------------------------------
% Log status of previous operations on GUI
% set(handles.statusbar, 'String',getappdata(hMainGui, 'status_application') );
log2dev( getappdata(hMainGui, 'status_application'), 'INFO', 0, hMainGui, 'statusbar' );
% -------------------------------------------------------------------------
if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        stgObj = getappdata(hMainGui,'settings_objectname');
        set(handles.figure1, 'Name', ['EpiTools | ', num2str(stgObj.analysis_code), ' - ' , stgObj.analysis_name])
        LoadControls(hMainGui, stgObj);
        % -------------------------------------------------------------------------
        % Log status of previous operations on GUI
        log2dev(sprintf('A setting file %s%s%s has been correctly loaded in the framework',...
                        stgObj.analysis_name,...
                        num2str(stgObj.analysis_version),...
                        stgObj.data_extensionmask),...
                'INFO', 0, hMainGui, 'statusbar' );
        % -------------------------------------------------------------------------  
    end 
end
% Update handles structure
guidata(hObject, handles);
% --------------------------------------------------------------------
function A_Proj_Callback(hObject, eventdata, handles)
% hObject    handle to A_Proj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Projection';

[intOut,stgObj] = SaveAnalysisModule(hObject, handles, strModuleName);
if(intOut)
    out = ProjectionGUI(stgObj);
    uiwait(out);
end

statusExecution = SaveAnalysisFile(hObject, handles, 1);

handles_connection(hObject,handles)
% --------------------------------------------------------------------
function A_StackReg_Callback(hObject, eventdata, handles)
% hObject    handle to A_StackReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Stack_Registration';


[intOut,stgObj] = SaveAnalysisModule(hObject, handles, strModuleName);


if(intOut)
    out = RegistrationGUI(stgObj);
    uiwait(out);
end

statusExecution = SaveAnalysisFile(hObject, handles, 1);

handles_connection(hObject,handles)
% --------------------------------------------------------------------
function A_CLAHE_Callback(hObject, eventdata, handles)
% hObject    handle to A_CLAHE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Contrast_Enhancement';

[intOut,stgObj] = SaveAnalysisModule(hObject, handles, strModuleName);


if(intOut)
    out = ImproveContrastGUI(stgObj);
    uiwait(out);
end

statusExecution = SaveAnalysisFile(hObject, handles, 1);

handles_connection(hObject,handles)
% --------------------------------------------------------------------
function A_Segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to A_Segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Segmentation';

[intOut,stgObj] = SaveAnalysisModule(hObject, handles, strModuleName);

if(intOut)
    out = SegmentationGUI(stgObj);
    uiwait(out);
end

statusExecution = SaveAnalysisFile(hObject, handles, 1);

handles_connection(hObject,handles);
% --------------------------------------------------------------------
function A_Tracking_Callback(hObject, eventdata, handles)
% hObject    handle to A_Tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Tracking';

[intOut,stgObj] = SaveAnalysisModule(hObject, handles, strModuleName);


if(intOut)
    out = TrackingIntroGUI(stgObj);
    uiwait(out);
end

statusExecution = SaveAnalysisFile(hObject, handles, 1);

handles_connection(hObject,handles)
% --------------------------------------------------------------------
function A_Skeletons_Callback(hObject, eventdata, handles)
% hObject    handle to A_Skeletons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
strModuleName = 'Skeletons';

[intOut,stgObj] = SaveAnalysisModule(hObject, handles, strModuleName);


if(intOut)
    out = SkeletonConversionGUI(stgObj);
    waitfor(out);
end

statusExecution = SaveAnalysisFile(hObject, handles, 1);

handles_connection(hObject,handles);
% --------------------------------------------------------------------
function A_Polycrop_Callback(hObject, eventdata, handles)
% hObject    handle to A_Polycrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
stgObj = getappdata(hMainGui,'settings_objectname');

strModuleName = 'Polygon_Masking';

intOut = SaveAnalysisModule(hObject, handles, strModuleName);

if(intOut)
    out = PolygonMaskingGUI(stgObj);
    waitfor(out);
end 

statusExecution = SaveAnalysisFile(hObject, handles, 1);

handles_connection(hObject,handles)
% --------------------------------------------------------------------
function A_ReSegmentation_Callback(hObject, eventdata, handles)
% hObject    handle to A_ReSegmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMainGui = getappdata(0, 'hMainGui');
stgObj = getappdata(hMainGui,'settings_objectname');

strModuleName = 'ReSegmentation';

intOut = SaveAnalysisModule(hObject, handles, strModuleName);

if(intOut)
    out = ReSegmentationGUI(stgObj);
    waitfor(out);
end 

statusExecution = SaveAnalysisFile(hObject, handles, 1);

handles_connection(hObject,handles)
% --------------------------------------------------------------------
function E_Undo_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function E_Redo_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function E_Preferences_Callback(hObject, eventdata, handles)
% hObject    handle to E_Preferences (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UserSettingsGUI();
% --------------------------------------------------------------------
function F_New_Callback(hObject, eventdata, handles)
% hObject    handle to F_New (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
% Graphics
uihandles_deletecontrols('all');
SandboxGUIRedesign(0);
set(handles.('figureA'), 'Visible', 'off')
a3 = get(handles.('figureA'), 'Children');
set(a3,'Visible', 'off');

stsFunOut = [];
% Check if there is setting file loaded in the application
if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        % Ask if you want to save it before generate a new one
        interrupt = SaveAnalysisFile(hObject, handles);
        
        if (interrupt == 1)
            return;
        end
        
        
    end
end
% Ask to the user to specify the image directory and the fullpath where the
% analysis file will be stored
strPathAnalysisFile = uigetdir('~','Select the directory where your analysis file will be stored');
if(strPathAnalysisFile)
    % Initialize a new setting file and call the form FilePropertiesGUI
    stgObj = settings();
    stgObj.CreateModule('Main');
    setappdata(hMainGui, 'settings_objectname', stgObj);
    stgObj.data_fullpath = strPathAnalysisFile;
    
else
    return;
end
while(isempty(stsFunOut)==1)
    strPathImages = uigetdir('~','Select the directory containing your images');
    if(strPathImages)
        stgObj.data_imagepath = strPathImages;
        stsFunOut = CreateMetadata(stgObj);
    else
        break;
    end
end
% Continue execution only if the previous passages has been completed
% correctly.
if ~isempty(stsFunOut)
    out = FilePropertiesGUI(getappdata(hMainGui,'settings_objectname'));
    uiwait(out);
    SaveAnalysisFile(hObject, handles, 1);
    
    stgObj = getappdata(hMainGui,'settings_objectname');

    % Logging on external device
    diary([stgObj.data_fullpath,'/out-',datestr(now,30),'.log']);
    diary on;
    % Status operations
    min = 0; max=100; value=10;
    log2dev('Parallel computing toolbox availability check...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    % Parallel
    installed_toolboxes=ver;
    if(any(strcmp('Parallel Computing Toolbox', {installed_toolboxes.Name})))
        if(stgObj.platform_units ~= 1);
            parpool('local',stgObj.platform_units);
        end
    end
    % Status operations
    min = 0; max=100; value=45;
    log2dev('Storing temporary variables...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    %Check if icy is in use
    stgObj.icy_is_used = getappdata(hMainGui,'icy_is_used');
    % Status operations
    min = 0; max=100; value=65;
    log2dev('Graphics initialization...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    % Update handles structure
    handles_connection(hObject, handles)
    % Status operations
    min = 0; max=100; value=75;
    log2dev('Pool connection establishing...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    % Execute procedures required by server-client modules
    disconnectPool
    %connectPool('clipro');% DEBUG
    connectPool(strcat(stgObj.analysis_name,'_',num2str(randi(100000000))));
    % Status operations
    min = 0; max=100; value=85;
    log2dev('Server connection establishing...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    % Connect to server instance
    connectServer();
    % Status operations
    min = 0; max=100; value=100;
    log2dev(sprintf('File loading completed for analysis %s generated by %s on %s', stgObj.analysis_name, stgObj.user_name, stgObj.platform_id),'INFO',0,'hMainGui', 'statusbar',{min,max,value});
end
% --------------------------------------------------------------------
function F_Open_Callback(hObject, eventdata, handles)
% hObject    handle to F_Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
% Graphics
uihandles_deletecontrols('all');
SandboxGUIRedesign(0);
set(handles.('figureA'), 'Visible', 'off')
a3 = get(handles.('figureA'), 'Children');
set(a3,'Visible', 'off');
% Status operations
min = 0; max=100; value=1;
log2dev('Loading file...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
% Check if there is setting file loaded in the application
if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        % Ask if you want to save it before generate a new one
        interrupt = SaveAnalysisFile(hObject, handles);
        
        if (interrupt == 1)
            return;
        end
        
        
    end
end
[strSettingFileName,strSettingFilePath,~] = uigetfile('~/*.xml','Select analysis file');
% If the user select a file to open
if(strSettingFilePath)
    stgObj = xml_read([strSettingFilePath,strSettingFileName]);
    % Check for validity
    % Status operations
    min = 0; max=100; value=5;
    log2dev('File integrity check running...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    % Storing as setting object
    stgObj = settings(stgObj);
    arrayFiles = fields(stgObj.analysis_modules.Main.data);
    tmpFileStruct = {};
    for i=1:numel(arrayFiles)
        idx = arrayFiles(i);
        stgObj.analysis_modules.Main.data.(char(idx)).exec = logical(stgObj.analysis_modules.Main.data.(char(idx)).exec);
        tmpFileStruct(i,:) = struct2cell(stgObj.analysis_modules.Main.data.(char(idx)))';
    end
    stgObj.analysis_modules.Main.data = tmpFileStruct;
    %load([strSettingFilePath,strSettingFileName], '-mat');
    setappdata(hMainGui, 'settings_objectname', stgObj);
    % Global integrity check
    if(DataIntegrityCheck(hObject, handles, strSettingFilePath))
        stgObj = getappdata(hMainGui, 'settings_objectname');
    end
    % Status operations
    min = 0; max=100; value=25;
    log2dev('Folder integrity check running...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    % Parallel
    installed_toolboxes=ver;
    if(any(strcmp('Parallel Computing Toolbox', {installed_toolboxes.Name})))
        if(stgObj.platform_units ~= 1);
            matlabpool('local',stgObj.platform_units);
        end
    end
    % Status operations
    min = 0; max=100; value=35;
    log2dev('Parallel computing toolbox availability check...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    %Check if icy is in use
    stgObj.icy_is_used = getappdata(hMainGui,'icy_is_used');
    settings_executionuid = getappdata(hMainGui,'settings_executionuid');
    diary([stgObj.data_fullpath,'/',settings_executionuid]);
    diary on;
    % Status operations
    min = 0; max=100; value=45;
    log2dev('Storing temporary variables...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    % Activate controls and refresh main window
    handles_connection(hObject, handles)
    % Status operations
    min = 0; max=100; value=65;
    log2dev('Graphics initialization...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    % Execute procedures required by server-client modules
    disconnectPool();
    % Status operations
    min = 0; max=100; value=75;
    log2dev('Pool connection establishing...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    %connectPool('clipro');% DEBUG
    connectPool(strcat(stgObj.analysis_name,'_',num2str(randi(100000000))));
    % Status operations
    min = 0; max=100; value=85;
    log2dev('Server connection establishing...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
    connectServer();
    min = 0; max=100; value=100;
    log2dev(sprintf('File loading completed for analysis %s generated by %s on %s', stgObj.analysis_name, stgObj.user_name, stgObj.platform_id),'INFO',0,'hMainGui', 'statusbar',{min,max,value});
else
    log2dev( getappdata(hMainGui, 'status_application'), 'INFO', 0, hMainGui, 'statusbar' );
end
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
    
    tmp = xml_read([strSettingFilePath,strSettingFileName]);
    %tmp = load([strSettingFilePath,strSettingFileName], '-mat', 'stgObj');
    
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
function F_Save_Callback(hObject, eventdata, handles)
% hObject    handle to F_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SaveAnalysisFile(hObject, handles);
% --------------------------------------------------------------------
function F_Properties_Callback(hObject, eventdata, handles)
% hObject    handle to F_Properties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMainGui = getappdata(0, 'hMainGui');

if(getappdata(hMainGui,'settings_objectname') ~= 0)
    
    out = FilePropertiesGUI(getappdata(hMainGui,'settings_objectname'));
    %uiwait(out);
else
    msgbox('No analysis file loaded!');
end

% Update handles structure
handles_connection(hObject, handles)
% --------------------------------------------------------------------
function F_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to F_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
onMainWindowClose(hObject, eventdata, handles);
% --------------------------------------------------------------------
function MHelp_Callback(hObject, eventdata, handles)
% hObject    handle to MHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://imls-bg-arthemis.uzh.ch/epitools/');
% --------------------------------------------------------------------
function MCredits_Callback(hObject, eventdata, handles)
% hObject    handle to MCredits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frmInfoSplash();
% --------------------------------------------------------------------
function uiNewAnalysisPush_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uiNewAnalysisPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
F_New_Callback(hObject, eventdata, handles);
% --------------------------------------------------------------------
function uiOpenAnalysisPush_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uiOpenAnalysisPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
F_Open_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function uiSaveAnalysisPush_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uiSaveAnalysisPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
F_Save_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function uiImportAnalysisPush_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uiImportAnalysisPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
F_ImportSettings_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function uiIcyVisualizationToggle_OffCallback(hObject, eventdata, handles)
% hObject    handle to uiIcyVisualizationToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
use_icy_checkbox_Callback(hObject, eventdata, handles, 0);
% --------------------------------------------------------------------
function uiIcyVisualizationToggle_OnCallback(hObject, eventdata, handles)
% hObject    handle to uiIcyVisualizationToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
use_icy_checkbox_Callback(hObject, eventdata, handles, 1);
% --------------------------------------------------------------------
function use_icy_checkbox_Callback(hObject, eventdata, handles, ToggleValue)
% --- Executes on button press in use_icy_checkbox.
hMainGui = getappdata(0, 'hMainGui');
settingsobj = getappdata(hMainGui, 'settings_execution');

if ToggleValue
    
    %only enter when tick is activated
    
    %get app data
    if(strcmp(settingsobj.output.icy.ctl_enableicyconnection.values(find(settingsobj.output.icy.ctl_enableicyconnection.actived)),'on'))
        icy_is_used = 1;
    else 
        icy_is_used = 0;
    end
    
    icy_path = settingsobj.output.icy.ctl_connectionstring.values;

    %icy_path    =   getappdata(hMainGui,'icy_path');
    %icy_is_used =   getappdata(hMainGui,'icy_is_used');
    icy_is_loaded = getappdata(hMainGui,'icy_is_loaded');
    
    
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
            
            log2dev(sprintf('Successfully detected ICY at:%s\n',icy_path),'INFO');
            addpath(icy_path);
            icy_init();
            icy_is_used = 1;
            icy_is_loaded = 1;
        else
            icy_path = 'none';
            log2dev(sprintf('Current icy path is not valid: %s\n',icy_path),'WARN');
        end
    else
        icy_is_used = 1;
    end
    
    %Check if icy is used
    if(icy_is_used ~= 1)
        %do not check if icy_path was not set
        set(handles.uiIcyVisualizationToggle,'State','off');
    end
    
    %set app data
    %setappdata(hMainGui,'icy_path',icy_path);
    setappdata(hMainGui,'icy_is_loaded',icy_is_loaded);
    setappdata(hMainGui,'icy_is_used',icy_is_used);
    
    if(icy_is_used);mtx = [1 0];else mtx = [0 1];end
    settingsobj.output.icy.ctl_enableicyconnection.actived = mtx;
    settingsobj.output.icy.ctl_connectionstring.values = icy_path;
    
    
    
else
    %checkbox is deselected
    set(handles.uiIcyVisualizationToggle,'State','off');
    setappdata(hMainGui,'icy_is_used',0);
    
end

setappdata(hMainGui, 'settings_execution',settingsobj);

%set preference in settings object if one exists
if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        stgObj = getappdata(hMainGui,'settings_objectname');
        stgObj.icy_is_used = getappdata(hMainGui,'icy_is_used');
    end
end

xml_write('usersettings.xml', settingsobj);
% --------------------------------------------------------------------
function uiExecuteServerQueue_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uiExecuteServerQueue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
server_instances = getappdata(hMainGui, 'server_instances');
client_modules = getappdata(hMainGui, 'client_modules');
pool_instances = getappdata(hMainGui, 'pool_instances');

server = server_instances(2).ref;
clients = client_modules(2).ref;

for i = 1:size(pool_instances(2:end),2)
    if (pool_instances(i+1).ref.active)
        %server.receiveMessage(clients(1),pool_instances(i+1).ref);
        server.receiveMessage(clients(4),pool_instances(i+1).ref);
    end
end
% --------------------------------------------------------------------
function uiManagePoolActivation_ClickedCallback(hObject, eventdata,handles)
hMainGui = getappdata(0, 'hMainGui');
pool_instances = getappdata(hMainGui, 'pool_instances');
if(numel(pool_instances) >=2)
    poold_PoolActivationManagerGUI;
end
% --------------------------------------------------------------------
function uiFlushServerQueue_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uiFlushServerQueue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ====================================================================
% Support Functions
% ====================================================================
function SplashScreenHandle = SplashScreen
% Splash screen before EpiTools loading
addpath('./src_support/module_xml');
logo = imread('./images/epitools_logo.png','png');
SplashScreenHandle = figure('MenuBar','None','NumberTitle','off','color',...
                            [1 1 1],'tag','SplashScreenTag','name',...
                            'EpiTools is loading...','color',[0.7,0.7,0.9],...
                            'Visible', 'off');
                        
iptsetpref('ImshowBorder','tight');
imshow(logo);

movegui(SplashScreenHandle,'center');
set(SplashScreenHandle, 'Visible', 'on');

if(exist('release.xml','file'))
    release = xml_read('release.xml');
else
    error('EpiTools installation is currupted. Exiting....');
end

if(exist('licence.xml','file'))
    licence = xml_read('licence.xml');

    
else
    warn('No licence file has been found in EpiTools directory');
    licence.customer.name = 'Unknown';
    licence.customer.lastname = '';
    licence.customer.email = '' ;
    licence.key.validity = 0;
end

text = uicontrol('Parent', SplashScreenHandle,...
                'Style','text',...
                'HorizontalAlignment', 'left',...
                'FontName','Helvetica Neue',...
                'String',sprintf('%s V%uR%uB%s licensed to %s %s (%s) for %u days',...
                                release.programm_name,...
                                release.version,...
                                release.release,...
                                release.build,...
                                licence.customer.name,...
                                licence.customer.lastname,...
                                licence.customer.email, ...
                                licence.key.validity),...
                'Units', 'normalized',...
                'Position', [0 0 1 0.05],...
                'BackgroundColor', [0 0 0],...
                'ForegroundColor', [1 1 1]);
 
            

drawnow;
% --------------------------------------------------------------------
function onMainWindowClose(hObject, eventdata, handles)
% On Main Windows Close function    
hMainGui = getappdata(0, 'hMainGui');
hLogGui = getappdata(0, 'hLogGui');
% Since the current function is invoked without passing handles, then
% recover them with
handles = guidata(hMainGui);

% Check if there is setting file loaded in the application
if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        % Ask if you want to save it before closing the application
        output = SaveAnalysisFile(hObject, handles);
        %waitfor(output);
        
        if (output == 1)
            return
        end
        
        stgObj = getappdata(hMainGui, 'settings_objectname');
        
        %matlabpool is unrecognized on platforms without the Paralell Computing toolbox
        if(stgObj.platform_units ~= 1)
            if (matlabpool('size') > 0); matlabpool close; end
        end
        
    end
end


settings_executionuid = getappdata(hMainGui, 'settings_executionuid');

log2dev('***********************************************************','INFO');
log2dev(sprintf('* End session %s * ',settings_executionuid),'INFO');
log2dev('***********************************************************','INFO');

if exist(['~/',settings_executionuid], 'file')
    delete(['~/',settings_executionuid]);
end
delete(hLogGui);
delete(hMainGui);
% --------------------------------------------------------------------
%                        SERVER-CLIENT INTEGRATION
% --------------------------------------------------------------------
function connectServer()
hMainGui = getappdata(0, 'hMainGui');
% Retrieve GUI handle from calling environment
hUIControls = getappdata(hMainGui,'hUIControls');
%% Initialisation of server
%  The following code initialise the server daemon which will store client
%  requests and forward command to queue and ask the workers to run them.
%  It will retrieve outcomes and it will redirect to dedicated pool.
server_instance = serverd();
% Announce to framework
server_instance.announceToFramework(hMainGui);
server_instance.buildGUInterface(hUIControls.uipanel_serverqueue);
% --------------------------------------------------------------------
function installClients()
hMainGui = getappdata(0, 'hMainGui');
%% Client availability checking
%  The following code will list all the client available in the
%  src_analysis folder and it will allow the framework to know their status
client_modules = clients_load();
% Announce to framework
client_modules.announceToFramework(hMainGui);
% --------------------------------------------------------------------
function disconnectServer()
% --------------------------------------------------------------------
function connectPool(poolname)
hMainGui = getappdata(0, 'hMainGui');
hUIControls = getappdata(hMainGui,'hUIControls');
%% Initialisation of pool
%  The following code will initialize the pool containing exported tags 
%  from commands executed by server workers.
pool = poold(poolname);
pool.loadPool();
% Announce to framework
pool.announceToFramework(hMainGui);
pool_instances = getappdata(hMainGui, 'pool_instances');
pool.buildGUInterface(hUIControls.uipanel_serverpool, pool_instances);
% --------------------------------------------------------------------
function disconnectPool()
hMainGui = getappdata(0, 'hMainGui');
setappdata(hMainGui, 'pool_instances',struct());
%setappdata(hMainGui, 'server_instances',struct());
%setappdata(hMainGui, 'client_modules',struct());
% --------------------------------------------------------------------
