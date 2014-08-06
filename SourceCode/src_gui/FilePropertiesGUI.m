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

% Last Modified by GUIDE v2.5 23-Jul-2014 09:12:25

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
%set(handles.figure1,'Visible','on');
initialize_gui(hObject, handles);

% UIWAIT makes FilePropertiesGUI wait for user response (see UIRESUME)
%uiwait(handles.figure1);
%waitfor(handles.figure1,'Visible','off');


% --- Outputs from this function are returned to the command line.
function varargout = FilePropertiesGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%close(handles.figure1)


% --------------------------------------------------------------------
function initialize_gui(hObject,handles)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
hMainGui = getappdata(0, 'hFPGui');
stgObj = getappdata(hMainGui,'settings_objectname');

set(handles.fp_analysis_code, 'String', stgObj.analysis_code);
set(handles.fp_analysis_name, 'String', stgObj.analysis_name);
set(handles.fp_analysis_version, 'String', stgObj.analysis_version);
set(handles.fp_user_name, 'String', stgObj.user_name);
set(handles.fp_user_department, 'String', stgObj.user_department);
set(handles.fp_platform_id, 'String', stgObj.platform_id);
set(handles.fp_platform_desc, 'String', stgObj.platform_desc);
set(handles.fp_data_benchmarkdir, 'String', stgObj.data_benchmarkdir);
set(handles.fp_data_extensionmask, 'String', stgObj.data_extensionmask);
set(handles.fp_data_fullpath, 'String', stgObj.data_fullpath);
set(handles.fp_data_imagepath, 'String', stgObj.data_imagepath);


set(handles.fp_data_analysisdir, 'String', stgObj.data_analysisdir);


% Valorise file table

if (stgObj.data_imagepath)
    
    if (isfield(stgObj.analysis_modules.Main, 'data') == 1)
            
            
        set(handles.uitable1, 'Data', stgObj.analysis_modules.Main.data);  
    
    elseif exist(strcat(stgObj.data_imagepath,'/','epitool_metadata.xml'), 'file') == 2
      
        MetadataFIGXML = xml_read(strcat(stgObj.data_imagepath,'/','epitool_metadata.xml'));
        vecFields = fields(MetadataFIGXML.files);

        for i=1:length(vecFields)
            
            MetadataFIGXML.files.(char(vecFields(i))).exec = logical(MetadataFIGXML.files.(char(vecFields(i))).exec);
            MetadataFIGXML.files.(char(vecFields(i))).exec_dim_z = num2str(MetadataFIGXML.files.(char(vecFields(i))).exec_dim_z);
            MetadataFIGXML.files.(char(vecFields(i))).exec_channels = num2str(MetadataFIGXML.files.(char(vecFields(i))).exec_channels);
            MetadataFIGXML.files.(char(vecFields(i))).exec_num_timepoints = num2str(MetadataFIGXML.files.(char(vecFields(i))).exec_num_timepoints);
            
            arrFiles(i,:) = struct2cell(MetadataFIGXML.files.(char(vecFields(i))));

            
            
        end
        %First time load, skip location path (1)
        set(handles.uitable1, 'Data', arrFiles(:,2:end));


            
    end
    
end


% Valorise CPU field

intCPUs = 1:feature('numcores');
strCString = '';

for i=intCPUs
    if i == 1
    strCString{i} = sprintf('%i Processor',i);
    else
    strCString{i} = sprintf('%i Processors',i);
    end
end

set(handles.fp_platform_units,'String',strCString);

%Not needed since default behavious is non-parallel 
% (i.e. in settings.m platform_units = 1)
% if(max(intCPUs) < stgObj.platform_units)
%     
%     set(handles.fp_platform_units, 'Value', min(intCPUs));
% else
%     
%     set(handles.fp_platform_units, 'Value', stgObj.platform_units);  
% end


% Update handles structure
guidata(handles.figure1, handles);



function fp_analysis_name_Callback(hObject, eventdata, handles)
% hObject    handle to fp_analysis_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_analysis_name as text
%        str2double(get(hObject,'String')) returns contents of fp_analysis_name as a double




% --- Executes during object creation, after setting all properties.
function fp_analysis_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_analysis_name (see GCBO)
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


% --- Executes on selection change in fp_platform_units.
function fp_platform_units_Callback(hObject, eventdata, handles)
% hObject    handle to fp_platform_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fp_platform_units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fp_platform_units


% --- Executes during object creation, after setting all properties.
function fp_platform_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_platform_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_platform_desc_Callback(hObject, eventdata, handles)
% hObject    handle to fp_platform_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_platform_desc as text
%        str2double(get(hObject,'String')) returns contents of fp_platform_desc as a double


% --- Executes during object creation, after setting all properties.
function fp_platform_desc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_platform_desc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_analysis_version_Callback(hObject, eventdata, handles)
% hObject    handle to fp_analysis_version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_analysis_version as text
%        str2double(get(hObject,'String')) returns contents of fp_analysis_version as a double


% --- Executes during object creation, after setting all properties.
function fp_analysis_version_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_analysis_version (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_data_analysisdir_Callback(hObject, eventdata, handles)
% hObject    handle to fp_data_analysisdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_data_analysisdir as text
%        str2double(get(hObject,'String')) returns contents of fp_data_analysisdir as a double


% --- Executes during object creation, after setting all properties.
function fp_data_analysisdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_data_analysisdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_data_benchmarkdir_Callback(hObject, eventdata, handles)
% hObject    handle to fp_data_benchmarkdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_data_benchmarkdir as text
%        str2double(get(hObject,'String')) returns contents of fp_data_benchmarkdir as a double


% --- Executes during object creation, after setting all properties.
function fp_data_benchmarkdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_data_benchmarkdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_data_extensionmask_Callback(hObject, eventdata, handles)
% hObject    handle to fp_data_extensionmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_data_extensionmask as text
%        str2double(get(hObject,'String')) returns contents of fp_data_extensionmask as a double


% --- Executes during object creation, after setting all properties.
function fp_data_extensionmask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_data_extensionmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_data_fullpath_Callback(hObject, eventdata, handles)
% hObject    handle to fp_data_fullpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_data_fullpath as text
%        str2double(get(hObject,'String')) returns contents of fp_data_fullpath as a double


% --- Executes during object creation, after setting all properties.
function fp_data_fullpath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_data_fullpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fp_analysis_code_Callback(hObject, eventdata, handles)
% hObject    handle to fp_analysis_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_analysis_code as text
%        str2double(get(hObject,'String')) returns contents of fp_analysis_code as a double


% --- Executes during object creation, after setting all properties.
function fp_analysis_code_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_analysis_code (see GCBO)
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
hMainGui = getappdata(0, 'hMainGui');
hFPGui = getappdata(0, 'hFPGui');

stgObj = getappdata(hFPGui,'settings_objectname');

stgFields = fields(stgObj);
hndFields = fields(handles);

for i=1:length(stgFields)
    
    if (strcmp(stgFields(i), 'platform_units'))
        
        strQuery = 'Value';
        
    else
        
        strQuery = 'String';
        
    end
    
    if(sum(strcmp(strcat('fp_',stgFields(i)), hndFields)) > 0)

        if(strcmp(stgObj.(char(stgFields(i))),get(handles.(char(strcat('fp_',stgFields(i)))), char(strQuery))) == 0)
            
            stgObj.(char(stgFields(i))) = get(handles.(char(strcat('fp_',stgFields(i)))), char(strQuery));
            
        end
           
    end
end

stgObj.AddSetting('Main','data',get(handles.uitable1,'Data'));


if(isempty(stgObj.data_analysisdir) == 1 && isempty(stgObj.data_fullpath) == 0)
    
    stgObj.data_analysisdir = strcat(stgObj.data_fullpath,'/Analysis');
    setappdata(hMainGui, 'settings_objectname', stgObj);
end


% If analysis folder does not exist even if it was set by the user
if (isempty(stgObj.data_analysisdir) == 0)
    if(exist(stgObj.data_analysisdir, 'dir') ~= 7)
    
        mkdir(stgObj.data_analysisdir);
    
    end
end
    
    

setappdata(hMainGui, 'settings_objectname', stgObj);
initialize_gui(hObject,handles)
close(handles.figure1);


% --- Executes on button press in B_SelectDirectory.
function B_SelectDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to B_SelectDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
hFPGui = getappdata(0, 'hFPGui');

stgObj = getappdata(hFPGui,'settings_objectname');

data_folder = uigetdir('~/','Select the directory to save the analysis file');

if (data_folder)
    stgObj.data_fullpath = data_folder;
end 
    
setappdata(hMainGui, 'settings_objectname', stgObj);
initialize_gui(hObject,handles)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hFPGui = getappdata(0, 'hFPGui');
stgObj = getappdata(hFPGui,'settings_objectname');

% Reset data table loaded 
stgObj.RemoveSetting('Main', 'data');
% Recreate or reload xml metadata file
stsFunOut = CreateMetadata(stgObj);
waitfor(stsFunOut);

% Revalorise controls
initialize_gui(hObject,handles)



function fp_data_imagepath_Callback(hObject, eventdata, handles)
% hObject    handle to fp_data_imagepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fp_data_imagepath as text
%        str2double(get(hObject,'String')) returns contents of fp_data_imagepath as a double


% --- Executes during object creation, after setting all properties.
function fp_data_imagepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fp_data_imagepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in B_SelectIMGDirectory.
function B_SelectIMGDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to B_SelectIMGDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
hFPGui = getappdata(0, 'hFPGui');

stgObj = getappdata(hFPGui,'settings_objectname');

data_folder = uigetdir('~/','Select the directory where you stored your image files');

if (data_folder)
    stgObj.data_imagepath = data_folder;
    stsFunOut = CreateMetadata(stgObj);
    
end 
    
setappdata(hMainGui, 'settings_objectname', stgObj);
setappdata(hMainGui, 'status_application',stsFunOut);

initialize_gui(hObject,handles)


% --- Executes on button press in B_SelectAnalysisDirectory.
function B_SelectAnalysisDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to B_SelectAnalysisDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
hFPGui = getappdata(0, 'hFPGui');

stgObj = getappdata(hFPGui,'settings_objectname');
data_folder = uigetdir('~/','Select the directory where you want to store all the results from the current analysis');

if (data_folder)
    stgObj.data_analysisdir = data_folder;

    
end 
    
setappdata(hMainGui, 'settings_objectname', stgObj);
initialize_gui(hObject,handles)


% --- Executes on button press in B_SelectBenchDirectory.
function B_SelectBenchDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to B_SelectBenchDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0, 'hMainGui');
hFPGui = getappdata(0, 'hFPGui');

stgObj = getappdata(hFPGui,'settings_objectname');
data_folder = uigetdir('~/','Select the directory where you stored benchmark files for the current analysis');

if (data_folder)
    stgObj.data_benchmarkdir = data_folder;

end 
    
setappdata(hMainGui, 'settings_objectname', stgObj);
initialize_gui(hObject,handles)
