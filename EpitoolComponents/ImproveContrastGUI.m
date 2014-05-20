function varargout = ImproveContrastGUI(varargin)
% IMPROVECONTRASTGUI MATLAB code for ImproveContrastGUI.fig
%      IMPROVECONTRASTGUI, by itself, creates a new IMPROVECONTRASTGUI or raises the existing
%      singleton*.
%
%      H = IMPROVECONTRASTGUI returns the handle to a new IMPROVECONTRASTGUI or the handle to
%      the existing singleton*.
%
%      IMPROVECONTRASTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPROVECONTRASTGUI.M with the given input arguments.
%
%      IMPROVECONTRASTGUI('Property','Value',...) creates a new IMPROVECONTRASTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImproveContrastGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImproveContrastGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImproveContrastGUI

% Last Modified by GUIDE v2.5 19-May-2014 10:02:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImproveContrastGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ImproveContrastGUI_OutputFcn, ...
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


% --- Executes just before ImproveContrastGUI is made visible.
function ImproveContrastGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImproveContrastGUI (see VARARGIN)

% Choose default command line output for ImproveContrastGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImproveContrastGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

updateAndGather(handles);

function updateAndGather(handles)
    gathered_data = gatherData(handles);
    updateLegends(handles,gathered_data);

function gathered_data = gatherData(handles)
    gathered_data.enhancement_limit = get(handles.enhancement_slider,'value');
    
function updateLegends(handles,gd)
    caption = sprintf('Enhancement limit = %.2f', gd.enhancement_limit);
    set(handles.enhancement_label, 'String', caption);


% --- Outputs from this function are returned to the command line.
function varargout = ImproveContrastGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in run_clahe.
function run_clahe_Callback(hObject, eventdata, handles)
% hObject    handle to run_clahe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gatheredData = gatherData(handles);
enhancement_limit = gatheredData.enhancement_limit;

%TODO HARDCODE > load from mainGUI
uint_type = 16;
hMainGui = getappdata(0, 'hMainGui');
data_specifics = getappdata(hMainGui,'data_specifics');
ImproveContrast(data_specifics, uint_type, enhancement_limit);


% --- Executes on slider movement.
function enhancement_slider_Callback(hObject, eventdata, handles)
% hObject    handle to enhancement_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

updateAndGather(handles);


% --- Executes during object creation, after setting all properties.
function enhancement_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enhancement_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

default_enhancement_limit = 0.02;
set(hObject, 'value', default_enhancement_limit);
