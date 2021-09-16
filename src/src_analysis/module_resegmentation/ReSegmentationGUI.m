function varargout = ReSegmentationGUI(varargin)
% RESEGMENTATIONGUI MATLAB code for ReSegmentationGUI.fig
%      RESEGMENTATIONGUI, by itself, creates a new RESEGMENTATIONGUI or raises the existing
%      singleton*.
%
%      H = RESEGMENTATIONGUI returns the handle to a new RESEGMENTATIONGUI or the handle to
%      the existing singleton*.
%
%      RESEGMENTATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESEGMENTATIONGUI.M with the given input arguments.
%
%      RESEGMENTATIONGUI('Property','Value',...) creates a new RESEGMENTATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ReSegmentationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReSegmentationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReSegmentationGUI

% Last Modified by GUIDE v2.5 11-Sep-2014 17:35:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ReSegmentationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ReSegmentationGUI_OutputFcn, ...
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


% --- Executes just before ReSegmentationGUI is made visible.
function ReSegmentationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReSegmentationGUI (see VARARGIN)

% Choose default command line output for ReSegmentationGUI
handles.output = hObject;

setappdata(0  , 'hReSegGui', gcf);
setappdata(gcf, 'settings_objectname', varargin{1});
setappdata(gcf, 'settings_modulename', 'ReSegmentation');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ReSegmentationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ReSegmentationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://imls-bg-arthemis.uzh.ch/epitools/?url=Analysis%20Modules/03_segmentation/');

% --- Executes on button press in run_resegmentation.
function run_resegmentation_Callback(hObject, eventdata, handles)
% hObject    handle to run_resegmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hReSegGui = getappdata(0, 'hReSegGui');
stgObj  = getappdata(hReSegGui, 'settings_objectname');

resegmentation_caller(stgObj);

delete(hReSegGui);
