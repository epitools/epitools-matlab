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

% Last Modified by GUIDE v2.5 19-May-2014 18:15:41

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

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TrackingIntroGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

updateAndGather(handles);

function updateAndGather(handles)
    gathered_data = gatherData(handles);
    updateLegends(handles,gathered_data);

function gathered_data = gatherData(handles)
    gathered_data.tracking_radius = get(handles.radius_slider,'value');
    
function updateLegends(handles,gd)
    caption = sprintf('Radius limit = %.2f', gd.tracking_radius);
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
gatheredData = gatherData(handles);
tracking_radius = gatheredData.tracking_radius;

hMainGui = getappdata(0, 'hMainGui');
data_specifics = getappdata(hMainGui,'data_specifics');

TrackingLauncher(data_specifics, tracking_radius);

%write back to the hMainGui, e.g. hMainGUI.tracking.tracking_radius


% --- Executes on slider movement.
function radius_slider_Callback(hObject, eventdata, handles)
% hObject    handle to radius_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);

% --- Executes during object creation, after setting all properties.
function radius_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

default_tracking_radius = 15;
set(hObject,'value',default_tracking_radius);
