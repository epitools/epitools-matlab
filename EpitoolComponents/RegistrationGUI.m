function varargout = RegistrationGUI(varargin)
% REGISTRATIONGUI MATLAB code for RegistrationGUI.fig
%      REGISTRATIONGUI, by itself, creates a new REGISTRATIONGUI or raises the existing
%      singleton*.
%
%      H = REGISTRATIONGUI returns the handle to a new REGISTRATIONGUI or the handle to
%      the existing singleton*.
%
%      REGISTRATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGISTRATIONGUI.M with the given input arguments.
%
%      REGISTRATIONGUI('Property','Value',...) creates a new REGISTRATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegistrationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegistrationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegistrationGUI

% Last Modified by GUIDE v2.5 04-Jul-2014 17:28:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegistrationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @RegistrationGUI_OutputFcn, ...
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


% --- Executes just before RegistrationGUI is made visible.
function RegistrationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegistrationGUI (see VARARGIN)

% Choose default command line output for RegistrationGUI
handles.output = hObject;
setappdata(0  , 'hRegGui', gcf);
setappdata(gcf, 'settings_objectname', varargin{1});
setappdata(gcf, 'settings_modulename', 'Stack_Registration');

% Update handles structure
guidata(hObject, handles);


updateAndGather(handles);

% UIWAIT makes RegistrationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function updateAndGather(handles)
hRegGui = getappdata(0  , 'hRegGui');
hMainGui = getappdata(0  , 'hMainGui');
stgObj  = getappdata(hRegGui, 'settings_objectname');
module_name = getappdata(hRegGui, 'settings_modulename');

gathered_data = gatherData(handles);
fieldgd = fields(gathered_data);

for i=1:numel(fieldgd)
    idx = fieldgd(i);
    if(isfield(stgObj.analysis_modules.(char(module_name)).settings,char(idx)) == 0)
        stgObj.AddSetting(module_name, char(idx), gathered_data.(char(idx)));
    else
        stgObj.ModifySetting(module_name, char(idx), gathered_data.(char(idx)));
    end
end

setappdata(hMainGui, 'settings_objectname', stgObj);
updateLegends(handles);

% Gather slider values set on the controls
function gathered_data = gatherData(handles)
    
    gathered_data.useStackReg = get(handles.useStackReg,'value');

    % Valorise control legends 
function updateLegends(handles)
hRehGui = getappdata(0  , 'hRegGui');
stgObj  = getappdata(hRehGui, 'settings_objectname');
module_name = getappdata(hRehGui, 'settings_modulename');


%     caption = sprintf('Smoothing Radius = %.2f', stgObj.analysis_modules.(char(module_name)).settings.SmoothingRadius);
%     set(handles.smoothing_label, 'String', caption);
% 
%     caption = sprintf('Surface Smoothness 1 = %.0f', stgObj.analysis_modules.(char(module_name)).settings.SurfSmoothness1);
%     set(handles.surface1_label, 'String', caption);
%     
%     caption = sprintf('Surface Smoothness 2 = %.0f', stgObj.analysis_modules.(char(module_name)).settings.SurfSmoothness2);
%     set(handles.surface2_label, 'String', caption);
%     
%     caption = sprintf('Projection Depth Threshold = %.2f', stgObj.analysis_modules.(char(module_name)).settings.ProjectionDepthThreshold);
%     set(handles.depth_label, 'String', caption);
    
   
% --- Outputs from this function are returned to the command line.
function varargout = RegistrationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start_registration.
function start_registration_Callback(hObject, eventdata, handles)
% hObject    handle to start_registration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateAndGather(handles);
hMainGui = getappdata(0, 'hMainGui');
hRehGui = getappdata(0  , 'hRegGui');
stgObj  = getappdata(hRehGui, 'settings_objectname');
module_name = getappdata(hRehGui, 'settings_modulename');

%params = gatherData(handles);
%params.InspectResults = true;         % show fit or not
stgObj.AddSetting(module_name,'InspectResults',true);
%params.Parallel = true;               % Use parallelisation?
stgObj.AddSetting(module_name,'Parallel',true);
%params.SkipFirstRegStep = true;
stgObj.AddSetting(module_name,'SkipFirstRegStep',true);


Registration(stgObj);


% --- Executes on button press in useStackReg.
function useStackReg_Callback(hObject, eventdata, handles)
% hObject    handle to useStackReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useStackReg
