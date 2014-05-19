function varargout = ProjectionGUI(varargin)
% PROJECTIONGUI MATLAB code for ProjectionGUI.fig
%      PROJECTIONGUI, by itself, creates a new PROJECTIONGUI or raises the existing
%      singleton*.
%
%      H = PROJECTIONGUI returns the handle to a new PROJECTIONGUI or the handle to
%      the existing singleton*.
%
%      PROJECTIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTIONGUI.M with the given input arguments.
%
%      PROJECTIONGUI('Property','Value',...) creates a new PROJECTIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProjectionGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProjectionGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProjectionGUI

% Last Modified by GUIDE v2.5 16-May-2014 15:32:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProjectionGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ProjectionGUI_OutputFcn, ...
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


% --- Executes just before ProjectionGUI is made visible.
function ProjectionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProjectionGUI (see VARARGIN)

% Choose default command line output for ProjectionGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProjectionGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

updateAndGather(handles);

function updateAndGather(handles)
    gathered_data = gatherData(handles);
    updateLegends(handles,gathered_data);

function gathered_data = gatherData(handles)
    
    params.mincellsize=25;  
    params.mincellsize = get(handles.surface1_slider,'value');
    params.sigma1=1;        
    params.threshold = 25;

    % Grow cells
    params.sigma3=2;
    params.LargeCellSizeThres = 3000;
    params.MergeCriteria = 0.35;

    % Final joining
    params.IBoundMax = 30;         

    % Performance Options (show=show_steps)
    params.show = false;
    params.Parallel  = true;

    gathered_data = params;
    
function updateLegends(handles,gd)
    caption = sprintf('Smoothing Radius = %.2f', gd.smoothing_radius);
    set(handles.smoothing_label, 'String', caption);

    caption = sprintf('Surface Smoothness 1 = %.0f', gd.surface_smoothness_1);
    set(handles.surface1_label, 'String', caption);
    
    caption = sprintf('Surface Smoothness 2 = %.0f', gd.surface_smoothness_2);
    set(handles.surface2_label, 'String', caption);
    
    caption = sprintf('Projection Depth Threshold = %.2f', gd.projection_depth_threshold);
    set(handles.depth_label, 'String', caption);

% --- Outputs from this function are returned to the command line.
function varargout = ProjectionGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function smoothing_slider_Callback(hObject, eventdata, handles)
% hObject    handle to smoothing_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

updateAndGather(handles);


% --- Executes during object creation, after setting all properties.
function smoothing_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothing_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%set defaults
default_smoothing_radius = 1;
set(hObject, 'value', default_smoothing_radius);


% --- Executes on slider movement.
function surface1_slider_Callback(hObject, eventdata, handles)
% hObject    handle to surface1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

updateAndGather(handles);


% --- Executes during object creation, after setting all properties.
function surface1_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to surface1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

default_surface_smoothness_1 = 30;
set(hObject, 'value', default_surface_smoothness_1);

% --- Executes on slider movement.
function surface2_slider_Callback(hObject, eventdata, handles)
% hObject    handle to surface2_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);

% --- Executes during object creation, after setting all properties.
function surface2_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to surface2_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

default_surface_smoothness_2 = 20;
set(hObject, 'value', default_surface_smoothness_2);


% --- Executes on slider movement.
function depth_slider_Callback(hObject, eventdata, handles)
% hObject    handle to depth_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);

% --- Executes during object creation, after setting all properties.
function depth_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
default_projection_depth_threshold = 1.2;
set(hObject, 'value', default_projection_depth_threshold);

% --- Executes on button press in start_projection.
function start_projection_Callback(hObject, eventdata, handles)
% hObject    handle to start_projection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gathered_data = gatherData(handles)
data_specs = '/Users/davide/data/neo/0/gui_trial/Analysis/DataSpecifics';
Projection(data_specs,...
    gathered_data.smoothing_radius,...
    gathered_data.surface_smoothness_1,...
    gathered_data.surface_smoothness_2,...
    gathered_data.projection_depth_threshold);
