function varargout = SegmentationGUI(varargin)
% SEGMENTATIONGUI MATLAB code for SegmentationGUI.fig
%      SEGMENTATIONGUI, by itself, creates a new SEGMENTATIONGUI or raises the existing
%      singleton*.
%
%      H = SEGMENTATIONGUI returns the handle to a new SEGMENTATIONGUI or the handle to
%      the existing singleton*.
%
%      SEGMENTATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTATIONGUI.M with the given input arguments.
%
%      SEGMENTATIONGUI('Property','Value',...) creates a new SEGMENTATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SegmentationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SegmentationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SegmentationGUI

% Last Modified by GUIDE v2.5 19-May-2014 16:26:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SegmentationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SegmentationGUI_OutputFcn, ...
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


% --- Executes just before SegmentationGUI is made visible.
function SegmentationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SegmentationGUI (see VARARGIN)

% Choose default command line output for SegmentationGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SegmentationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

updateAndGather(handles);

function updateAndGather(handles)
    gathered_data = gatherData(handles);
    updateLegends(handles,gathered_data);

function gathered_data = gatherData(handles)
    
    params.mincellsize =    get(handles.min_cell_slider,'value');
    params.sigma1=          get(handles.sigma1_slider,'value');        
    params.threshold =      get(handles.threshold_slider,'value');

    % Grow cells
    params.sigma3=          get(handles.sigma3_slider, 'value');
    params.LargeCellSizeThres = get(handles.max_cell_slider,'value');
    params.MergeCriteria = get(handles.merge_slider,'value');

    % Final joining
    params.IBoundMax = get(handles.ibound_slider,'value');         

    % Performance Options (show=show_steps)
    params.show = false;
    params.Parallel  = true;

    gathered_data = params;
    
function updateLegends(handles,gd)
    setLegend(handles.min_cell_label,...
        sprintf('Minimal cell size = %.2f',gd.mincellsize));
    setLegend(handles.sigma1_label,...
        sprintf('Sigma 1 = %.2f',gd.sigma1));
    setLegend(handles.threshold_label,...
        sprintf('Threshold = %.2f',gd.threshold));
    setLegend(handles.sigma3_label,...
        sprintf('Sigma 3 = %.2f',gd.sigma3));
    setLegend(handles.max_cell_label,...
        sprintf('Maximal cell size = %.2f',gd.LargeCellSizeThres));
    setLegend(handles.merge_label,...
        sprintf('Merge criteria = %.2f',gd.MergeCriteria));
    setLegend(handles.ibound_label,...
        sprintf('Maximal IBound = %.2f',gd.IBoundMax));
    
    
function setLegend(label_handle,caption)
    set(label_handle, 'String', caption);


% --- Outputs from this function are returned to the command line.
function varargout = SegmentationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run_segmentation.
function run_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to run_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gathered_data = gatherData(handles);
gathered_data.SingleFrame = false;

hMainGui = getappdata(0, 'hMainGui');
data_specifics = getappdata(hMainGui,'data_specifics');
Segmentation(data_specifics,gathered_data);


% --- Executes on slider movement.
function min_cell_slider_Callback(hObject, eventdata, handles)
% hObject    handle to min_cell_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);

% --- Executes during object creation, after setting all properties.
function min_cell_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_cell_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

default_mincellsize=25; 
set(hObject,'value', default_mincellsize);


% --- Executes on slider movement.
function sigma1_slider_Callback(hObject, eventdata, handles)
% hObject    handle to sigma1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);

% --- Executes during object creation, after setting all properties.
function sigma1_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
default_sigma1 = 1;
set(hObject,'value',default_sigma1);


% --- Executes on slider movement.
function threshold_slider_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);

% --- Executes during object creation, after setting all properties.
function threshold_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

default_threshold = 25;
set(hObject,'value',default_threshold);


% --- Executes on slider movement.
function sigma3_slider_Callback(hObject, eventdata, handles)
% hObject    handle to sigma3_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);


% --- Executes during object creation, after setting all properties.
function sigma3_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma3_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

default_sigma3 = 2;
set(hObject,'value',default_sigma3);


% --- Executes on slider movement.
function max_cell_slider_Callback(hObject, eventdata, handles)
% hObject    handle to max_cell_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);

% --- Executes during object creation, after setting all properties.
function max_cell_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_cell_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
default_max_cell_size = 3000;
set(hObject,'value',default_max_cell_size);

% --- Executes on slider movement.
function merge_slider_Callback(hObject, eventdata, handles)
% hObject    handle to merge_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);

% --- Executes during object creation, after setting all properties.
function merge_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to merge_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
default_merge_criteria = 0.35;
set(hObject,'value',default_merge_criteria);


% --- Executes on slider movement.
function ibound_slider_Callback(hObject, eventdata, handles)
% hObject    handle to ibound_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateAndGather(handles);

% --- Executes during object creation, after setting all properties.
function ibound_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ibound_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
default_max_i_bound = 30;
set(hObject,'value',default_max_i_bound);


% --- Executes on button press in test_segmentation.
function test_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to test_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gathered_data = gatherData(handles);
gathered_data.SingleFrame = true;

hMainGui = getappdata(0, 'hMainGui');
data_specifics = getappdata(hMainGui,'data_specifics');
Segmentation(data_specifics,gathered_data);
