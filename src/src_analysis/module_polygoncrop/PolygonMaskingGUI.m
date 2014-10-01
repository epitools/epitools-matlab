function varargout = PolygonMaskingGUI(varargin)
% POLYGONMASKINGGUI MATLAB code for PolygonMaskingGUI.fig
%      POLYGONMASKINGGUI, by itself, creates a new POLYGONMASKINGGUI or raises the existing
%      singleton*.
%
%      H = POLYGONMASKINGGUI returns the handle to a new POLYGONMASKINGGUI or the handle to
%      the existing singleton*.
%
%      POLYGONMASKINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POLYGONMASKINGGUI.M with the given input arguments.
%
%      POLYGONMASKINGGUI('Property','Value',...) creates a new POLYGONMASKINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PolygonMaskingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PolygonMaskingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PolygonMaskingGUI

% Last Modified by GUIDE v2.5 10-Sep-2014 18:08:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PolygonMaskingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PolygonMaskingGUI_OutputFcn, ...
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


% --- Executes just before PolygonMaskingGUI is made visible.
function PolygonMaskingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PolygonMaskingGUI (see VARARGIN)

% Choose default command line output for PolygonMaskingGUI
handles.output = hObject;

setappdata(0  , 'hMaskGui', gcf);
setappdata(gcf, 'settings_objectname', varargin{1});
setappdata(gcf, 'settings_modulename', 'Polygon_Masking');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PolygonMaskingGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PolygonMaskingGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in create_polygon_mask.
function create_polygon_mask_Callback(hObject, eventdata, handles)
% hObject    handle to create_polygon_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMaskGui = getappdata(0  , 'hMaskGui');
stgObj  = getappdata(hMaskGui, 'settings_objectname');
strModuleName = getappdata(hMaskGui, 'settings_modulename');

% Load data structures need for mask generation
tmpSegObj = load([stgObj.data_analysisindir,'/SegResults']);
tmpRegObj = load([stgObj.data_analysisindir,'/RegIm']);

%Generate the mask and the cropped label image
[polygonal_mask, cropped_CellLabelIm] = PolygonCrop(tmpRegObj.RegIm, tmpSegObj.CLabels);

%Save results
save([stgObj.data_analysisoutdir,'/PoligonalMask'],'polygonal_mask');
save([stgObj.data_analysisoutdir,'/CroppedCellLabels'],'cropped_CellLabelIm');

%update settings module
stgObj.AddResult(strModuleName,'polygonal_mask_path','PoligonalMask.mat');
stgObj.AddResult(strModuleName,'cropped_cell_labels','CroppedCellLabels.mat');

%Visualize in main gui
StackView(cropped_CellLabelIm,'hMainGui','figureA');

waitfor(polygonal_mask);

%close polygon crop gui after execution
delete(hMaskGui);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://imls-bg-arthemis.uzh.ch/epitools/?url=Analysis_Modules/04_polygonMask/');
