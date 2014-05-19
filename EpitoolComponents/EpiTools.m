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

% Last Modified by GUIDE v2.5 19-May-2014 14:10:18

% Begin initialization code - DO NOT EDIT
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

% Choose default command line output for EpiTools
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

LoadEpiTools();

% UIWAIT makes EpiTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);

setappdata(0  , 'hMainGui'    , gcf);
setappdata(gcf, 'data_specifics', 'none');


% --- Outputs from this function are returned to the command line.
function varargout = EpiTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in set_data_button.
function set_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to set_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMainGui = getappdata(0, 'hMainGui');
data_folder = uigetdir('~/','Select the directory of the images to analyze');

if(data_folder ~= 0)
    if(exist(data_folder,'dir'))
        data_specifics = InspectData(data_folder);
        setappdata(hMainGui, 'data_specifics', data_specifics);
    end  
end


% --- Executes on button press in do_projection.
function do_projection_Callback(hObject, eventdata, handles)
% hObject    handle to do_projection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMainGui = getappdata(0, 'hMainGui');
data_specifics = getappdata(hMainGui,'data_specifics')

if(~strcmp(data_specifics,'none'))
    
    %TODO check whether Proj is already present otherwise start Projection
    %with relative GUI
    load(data_specifics);
    projection_file = [AnaDirec,'/ProjIm'];
    if(exist([projection_file,'.mat'],'file'))
        do_overwrite = questdlg('Found previous result','GUI decision',...
    'Open GUI anyway','Show Result','Show Result');
        if(strcmp(do_overwrite,'Open GUI anyway'))
            ProjectionGUI;
        else
            load(projection_file);
            StackView(ProjIm);
        end
    else
        ProjectionGUI;
    end
else
    fprintf('No Data Set configured\n');
end

% --- Executes on button press in do_registration.
function do_registration_Callback(hObject, eventdata, handles)
% hObject    handle to do_registration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMainGui = getappdata(0, 'hMainGui');
data_specifics = getappdata(hMainGui,'data_specifics')

if(~strcmp(data_specifics,'none'))
    
    load(data_specifics);
    registration_file = [AnaDirec,'/RegIm'];
    if(exist([registration_file,'.mat'],'file'))
        do_overwrite = questdlg('Found previous result','GUI decision',...
    'Open GUI anyway','Show Result','Show Result');
        if(strcmp(do_overwrite,'Open GUI anyway'))
            RegistrationGUI;
        else
            load(registration_file);
            StackView(RegIm);
        end
    else
        RegistrationGUI;
    end
else
    fprintf('No Data Set configured\n');
end



% --- Executes on button press in do_segmentation.
function do_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to do_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMainGui = getappdata(0, 'hMainGui');
data_specifics = getappdata(hMainGui,'data_specifics')

if(~strcmp(data_specifics,'none'))
    
    load(data_specifics);
    segmentation_file = [AnaDirec,'/SegResults'];
    if(exist([segmentation_file,'.mat'],'file'))
        do_overwrite = questdlg('Found previous result','GUI decision',...
    'Open GUI anyway','Show Result','Show Result');
        if(strcmp(do_overwrite,'Open GUI anyway'))
            SegmentationGUI;
        else
            %load Clabels here
            load(segmentation_file);
            %load(segmentation_file);
            %StackView(RegIm);
        end
    else
        SegmentationGUI;
    end
else
    fprintf('No Data Set configured\n');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in enhance_contrast.
function enhance_contrast_Callback(hObject, eventdata, handles)
% hObject    handle to enhance_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMainGui = getappdata(0, 'hMainGui');
data_specifics = getappdata(hMainGui,'data_specifics')

if(~strcmp(data_specifics,'none'))
    
    load(data_specifics);
    clahe_file = [AnaDirec,'/RegIm_woCLAHE'];
    if(exist([clahe_file,'.mat'],'file'))
        do_overwrite = questdlg('Found previous result','GUI decision',...
    'Open GUI anyway','Show Result','Show Result');
        if(strcmp(do_overwrite,'Open GUI anyway'))
            ImproveContrastGUI;
        else
            registration_file = [AnaDirec,'/RegIm'];
            load(registration_file);
            StackView(RegIm);
        end
    else
        ImproveContrastGUI;
    end
else
    fprintf('No Data Set configured\n');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
