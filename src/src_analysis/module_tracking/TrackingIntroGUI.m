function varargout = TrackingIntroGUI(varargin)
% TRACKINGINTROGUI MATLAB code for TrackingIntroGUI.fig
%      TRACKINGINTROGUI, by itself, creates a new TRACKINGINTROGUI or raises the existing
%      singleton*.
%
%      H = TRACKINGINTROGUI returns the handle to a new TRACKINGINTROGUI or the handle to
%      the existing singleton*.
%
%      TRACKINGINTROGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKINGINTROGUI.M with the given input arguments.
%
%      TRACKINGINTROGUI('Property','Value',...) creates a new TRACKINGINTROGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TrackingIntroGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TrackingIntroGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrackingIntroGUI

% Last Modified by GUIDE v2.5 01-Oct-2014 09:55:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TrackingIntroGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @TrackingIntroGUI_OutputFcn, ...
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


% --- Executes just before TrackingIntroGUI is made visible.
function TrackingIntroGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrackingIntroGUI (see VARARGIN)

% Choose default command line output for TrackingIntroGUI
handles.output = hObject;

setappdata(0  , 'hTrackGui', gcf);
setappdata(gcf, 'settings_objectname', varargin{1});
setappdata(gcf, 'settings_modulename', 'Tracking');



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TrackingIntroGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

updateAndGather(handles);

function updateAndGather(handles)
hTrackGui = getappdata(0  , 'hTrackGui');
hMainGui = getappdata(0  , 'hMainGui');
stgObj  = getappdata(hTrackGui, 'settings_objectname');
module_name = getappdata(hTrackGui, 'settings_modulename');

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



function gathered_data = gatherData(handles)

    gathered_data.TrackingRadius = get(handles.TrackingRadius,'value');
    
function updateLegends(handles)
hTrackGui = getappdata(0  , 'hTrackGui');
stgObj  = getappdata(hTrackGui, 'settings_objectname');
module_name = getappdata(hTrackGui, 'settings_modulename');

caption = sprintf('Radius limit = %.2f', stgObj.analysis_modules.(char(module_name)).settings.TrackingRadius);
set(handles.radius_label, 'String', caption);


% --- Outputs from this function are returned to the command line.
function varargout = TrackingIntroGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run_trackingGUI.
function run_trackingGUI_Callback(hObject, eventdata, handles)
% hObject    handle to run_trackingGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateAndGather(handles);

hMainGui = getappdata(0, 'hMainGui');
stgObj  = getappdata(hMainGui, 'settings_objectname');


TrackingLauncher(stgObj);


% --- Executes on slider movement.
function TrackingRadius_Callback(hObject, eventdata, handles)
% hObject    handle to TrackingRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);

% --- Executes during object creation, after setting all properties.
function TrackingRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrackingRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

default_tracking_radius = 15;
set(hObject,'value',default_tracking_radius);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://imls-bg-arthemis.uzh.ch/epitools/?url=Analysis_Modules/05_tracking/');
