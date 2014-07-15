function varargout = FilePropertiesGUI(varargin)
% FILEPROPERTIESGUI MATLAB code for FilePropertiesGUI.fig
%      FILEPROPERTIESGUI, by itself, creates a new FILEPROPERTIESGUI or raises the existing
%      singleton*.
%
%      H = FILEPROPERTIESGUI returns the handle to a new FILEPROPERTIESGUI or the handle to
%      the existing singleton*.
%
%      FILEPROPERTIESGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILEPROPERTIESGUI.M with the given input arguments.
%
%      FILEPROPERTIESGUI('Property','Value',...) creates a new FILEPROPERTIESGUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FilePropertiesGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FilePropertiesGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FilePropertiesGUI

% Last Modified by GUIDE v2.5 15-Jul-2014 09:51:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FilePropertiesGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FilePropertiesGUI_OutputFcn, ...
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

% --- Executes just before FilePropertiesGUI is made visible.
function FilePropertiesGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FilePropertiesGUI (see VARARGIN)

% Choose default command line output for FilePropertiesGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(0  , 'hFPGui', gcf);
setappdata(gcf, 'settings_objectname', varargin{1});
set(handles.figure1,'Visible','on');
initialize_gui(hObject, handles);

% UIWAIT makes FilePropertiesGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
waitfor(handles.figure1,'Visible','off');


% --- Outputs from this function are returned to the command line.
function varargout = FilePropertiesGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
close(handles.figure1)


% --------------------------------------------------------------------
function initialize_gui(hObject,handles)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.

hMainGui = getappdata(0, 'hFPGui');
stgObj = getappdata(hMainGui,'settings_objectname');

set(handles.fp_analysiscode, 'String', stgObj.analysis_code);
set(handles.fp_analysisname, 'String', stgObj.analysis_name);
set(handles.fp_analysisversion, 'String', stgObj.analysis_version);
set(handles.fp_user_name, 'String', stgObj.user_name);
set(handles.fp_user_department, 'String', stgObj.user_department);
set(handles.fp_platform_id, 'String', stgObj.platform_id);
set(handles.fp_platformdescription, 'String', stgObj.platform_desc);
%set(handles.fp_cpus, 'String', stgObj.platform_units);
set(handles.fp_analysisdirectory, 'String', stgObj.data_analysisdir);
set(handles.fp_benchmarkdirectory, 'String', stgObj.data_benchmarkdir);
set(handles.fp_extension, 'String', stgObj.data_extensionmask);
set(handles.fp_filedirectory, 'String', stgObj.data_fullpath);

% Update handles structure
guidata(handles.figure1, handles);



function fp_analysisname_Callback(hObject, eventdata, handles)
% hObject    handle to fp_analysisname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_analysisname as text
%        str2double(get(hObject,'String')) returns contents of fp_analysisname as a double




% --- Executes during object creation, after setting all properties.
function fp_analysisname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_analysisname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_user_name_Callback(hObject, eventdata, handles)
% hObject    handle to fp_user_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_user_name as text
%        str2double(get(hObject,'String')) returns contents of fp_user_name as a double


% --- Executes during object creation, after setting all properties.
function fp_user_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_user_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_user_department_Callback(hObject, eventdata, handles)
% hObject    handle to fp_user_department (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_user_department as text
%        str2double(get(hObject,'String')) returns contents of fp_user_department as a double


% --- Executes during object creation, after setting all properties.
function fp_user_department_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_user_department (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_platform_id_Callback(hObject, eventdata, handles)
% hObject    handle to fp_platform_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_platform_id as text
%        str2double(get(hObject,'String')) returns contents of fp_platform_id as a double


% --- Executes during object creation, after setting all properties.
function fp_platform_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_platform_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fp_cpus.
function fp_cpus_Callback(hObject, eventdata, handles)
% hObject    handle to fp_cpus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fp_cpus contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fp_cpus


% --- Executes during object creation, after setting all properties.
function fp_cpus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_cpus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_platformdescription_Callback(hObject, eventdata, handles)
% hObject    handle to fp_platformdescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_platformdescription as text
%        str2double(get(hObject,'String')) returns contents of fp_platformdescription as a double


% --- Executes during object creation, after setting all properties.
function fp_platformdescription_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_platformdescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_analysisversion_Callback(hObject, eventdata, handles)
% hObject    handle to fp_analysisversion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_analysisversion as text
%        str2double(get(hObject,'String')) returns contents of fp_analysisversion as a double


% --- Executes during object creation, after setting all properties.
function fp_analysisversion_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_analysisversion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_analysisdirectory_Callback(hObject, eventdata, handles)
% hObject    handle to fp_analysisdirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_analysisdirectory as text
%        str2double(get(hObject,'String')) returns contents of fp_analysisdirectory as a double


% --- Executes during object creation, after setting all properties.
function fp_analysisdirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_analysisdirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_benchmarkdirectory_Callback(hObject, eventdata, handles)
% hObject    handle to fp_benchmarkdirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_benchmarkdirectory as text
%        str2double(get(hObject,'String')) returns contents of fp_benchmarkdirectory as a double


% --- Executes during object creation, after setting all properties.
function fp_benchmarkdirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_benchmarkdirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_extension_Callback(hObject, eventdata, handles)
% hObject    handle to fp_extension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_extension as text
%        str2double(get(hObject,'String')) returns contents of fp_extension as a double


% --- Executes during object creation, after setting all properties.
function fp_extension_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_extension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_filedirectory_Callback(hObject, eventdata, handles)
% hObject    handle to fp_filedirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_filedirectory as text
%        str2double(get(hObject,'String')) returns contents of fp_filedirectory as a double


% --- Executes during object creation, after setting all properties.
function fp_filedirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_filedirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_analysiscode_Callback(hObject, eventdata, handles)
% hObject    handle to fp_analysiscode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_analysiscode as text
%        str2double(get(hObject,'String')) returns contents of fp_analysiscode as a double


% --- Executes during object creation, after setting all properties.
function fp_analysiscode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_analysiscode (see GCBO)
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

hMainGui = getappdata(0, 'hFPGui');
stgObj = getappdata(hMainGui,'settings_objectname');

if(strcmp(stgObj.analysis_name,get(handles.fp_analysisname, 'String')) == 0)
    
    msgbox('Analysis Name field has been changed')
    stgObj.analysis_name = get(handles.fp_analysisname, 'String');
    
    
end
h = stgObj;
handles.output = findobj(h,'Value',1);
set(handles.figure1,'Visible','off')



% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
