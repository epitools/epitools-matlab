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

% Last Modified by GUIDE v2.5 10-Sep-2014 18:05:16

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
setappdata(0  , 'hSegGui', gcf);
setappdata(gcf, 'settings_objectname', varargin{1});
setappdata(gcf, 'settings_modulename', 'Segmentation');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SegmentationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

updateAndGather(handles);

function updateAndGather(handles)
hSegGui = getappdata(0  , 'hSegGui');
hMainGui = getappdata(0  , 'hMainGui');
stgObj  = getappdata(hSegGui, 'settings_objectname');
module_name = getappdata(hSegGui, 'settings_modulename');

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
    
    gathered_data.mincellsize  =    get(handles.min_cell_slider,'value');
    gathered_data.sigma1       =    get(handles.sigma1_slider,'value');        
    gathered_data.threshold    =    get(handles.threshold_slider,'value');

    % Grow cells
    gathered_data.sigma3    =    get(handles.sigma3_slider, 'value');
    gathered_data.LargeCellSizeThres = get(handles.max_cell_slider,'value');
    gathered_data.MergeCriteria      = get(handles.merge_slider,'value');

    % Final joining
    gathered_data.IBoundMax = get(handles.ibound_slider,'value');         

    % Performance Options (show=show_steps)
    gathered_data.show      = false;
    gathered_data.Parallel  = true;

    
    
function updateLegends(handles)
hSegGui = getappdata(0  , 'hSegGui');
stgObj  = getappdata(hSegGui, 'settings_objectname');
module_name = getappdata(hSegGui, 'settings_modulename');

    
    caption = sprintf('Minimal cell area = %.2f',stgObj.analysis_modules.(char(module_name)).settings.mincellsize);
    set(handles.min_cell_label, 'String', caption);
    
    caption = sprintf('Gaussian smoothing = %.2f',stgObj.analysis_modules.(char(module_name)).settings.sigma1);
    set(handles.sigma1_label, 'String', caption);
    
    caption = sprintf('Minimal membrane intensity = %.2f',stgObj.analysis_modules.(char(module_name)).settings.threshold);
    set(handles.threshold_label, 'String', caption);

    caption = sprintf('Gaussian smoothing = %.2f',stgObj.analysis_modules.(char(module_name)).settings.sigma3);
    set(handles.sigma3_label, 'String', caption);
   
    caption = sprintf('Maximal cell area = %.2f',stgObj.analysis_modules.(char(module_name)).settings.LargeCellSizeThres);
    set(handles.max_cell_label, 'String', caption);
    
    caption = sprintf('Minimal intensity ratio = %.2f',stgObj.analysis_modules.(char(module_name)).settings.MergeCriteria);
    set(handles.merge_label, 'String', caption);
    
    caption = sprintf('Minimal mean intensity = %.2f',stgObj.analysis_modules.(char(module_name)).settings.IBoundMax);
    set(handles.ibound_label, 'String', caption);


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

updateAndGather(handles);

hSegGui = getappdata(0  , 'hSegGui');
stgObj  = getappdata(hSegGui, 'settings_objectname');
module_name = getappdata(hSegGui, 'settings_modulename');

%gathered_data.SingleFrame = false;
stgObj.AddSetting(module_name,'SingleFrame',false);
stgObj.AddSetting(module_name,'debug',false);

Segmentation(stgObj);

%close segmentation gui after execution
delete(hSegGui);


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

updateAndGather(handles);

hSegGui = getappdata(0,'hSegGui');
stgObj  = getappdata(hSegGui, 'settings_objectname');
module_name = getappdata(hSegGui, 'settings_modulename');

%Check if the user wants to visualize results
show_debug = get(handles.debug_checkbox,'value');

%gathered_data.SingleFrame = false;
stgObj.AddSetting(module_name,'SingleFrame',true);
stgObj.AddSetting(module_name,'debug',show_debug);

Segmentation(stgObj);

%close segmentation gui after execution
delete(hSegGui);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in debug_checkbox.
function debug_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to debug_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of debug_checkbox


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://imls-bg-arthemis.uzh.ch/epitools-wiki/site/Analysis%20Modules/segmentation/');
