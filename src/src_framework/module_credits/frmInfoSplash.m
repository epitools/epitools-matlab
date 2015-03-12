function varargout = frmInfoSplash(varargin)
% FRMINFOSPLASH MATLAB code for frmInfoSplash.fig
%      FRMINFOSPLASH, by itself, creates a new FRMINFOSPLASH or raises the existing
%      singleton*.
%
%      H = FRMINFOSPLASH returns the handle to a new FRMINFOSPLASH or the handle to
%      the existing singleton*.
%
%      FRMINFOSPLASH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRMINFOSPLASH.M with the given input arguments.
%
%      FRMINFOSPLASH('Property','Value',...) creates a new FRMINFOSPLASH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frmInfoSplash_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frmInfoSplash_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frmInfoSplash

% Last Modified by GUIDE v2.5 30-Sep-2014 11:57:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @frmInfoSplash_OpeningFcn, ...
                   'gui_OutputFcn',  @frmInfoSplash_OutputFcn, ...
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


% --- Executes just before frmInfoSplash is made visible.
function frmInfoSplash_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to frmInfoSplash (see VARARGIN)

% Choose default command line output for frmInfoSplash
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
movegui(hObject, 'center');
handles_connection(hObject,handles);

% UIWAIT makes frmInfoSplash wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = frmInfoSplash_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function handles_connection(hObject,handles)
% Get release and licence informations
hMainGui = getappdata(0, 'hMainGui');
licence = getappdata(hMainGui, 'settings_licence');
release = getappdata(hMainGui, 'settings_release');


%title
set(handles.text4, 'String', release.programm_name);
set(handles.text12, 'String', release.programm_desc);
set(handles.text13, 'String', release.programm_authors);
set(handles.text14, 'String', sprintf('%s (internal V%uR%u build %s on %s )',release.date_version,release.version,release.release*100,release.build, release.date_build));
set(handles.text15, 'String', release.date_release);


labelStr = ['<html><center><a href="">',release.url_info];
set(handles.text17, 'String', labelStr, 'callback',{@webcaller,release} );

imshow('./images/logos/cancerresearchUK.jpg', 'Parent', handles.axes3)
imshow('./images/logos/kingstonUniversityLND.jpg', 'Parent', handles.axes4)
imshow('./images/logos/universitycollegeLND.jpg', 'Parent', handles.axes5)
imshow('./images/logos/UZH.jpg', 'Parent', handles.axes6)

function webcaller(hObject,events,release)
web(release.url_info);
