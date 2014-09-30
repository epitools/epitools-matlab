%% Example of Setting use


%% Create setting file

user_department = 'IMLS';
analysis_name = 'Test01';
platform_units = 1;
analysis_version = 0;
data_fullpath = '';        
data_imagepath = '';

stgObj = settings(user_department, analysis_name, platform_units, analysis_version, data_fullpath, data_imagepath);

% Add modules 'main','clahe', 'segmentation', 'tracking', 'test'
stgObj.CreateModule('main');
stgObj.CreateModule('clahe');
stgObj.CreateModule('segmentation');
stgObj.CreateModule('tracking');
stgObj.CreateModule('test');

% Add property 'planes' to module 'main'
stgObj.AddSetting('main','planes',1);

% Add property 'x_dim', 'y_dim' to module 'main'
stgObj.AddSetting('main','x_dim',800);
stgObj.AddSetting('main','y_dim',600);
stgObj.AddSetting('test','null',0);

% Change value stored for property 'planes' in module 'main'
stgObj.ModifySetting('main','planes',2);

% Remove property 'test' from module 'null'
stgObj.RemoveSetting('test', 'null');
% Destroy module 'test'
stgObj.DestroyModule('test');


%% Load setting file

LoadSettings('testsettings.mat');

%% Partial setting file load

stgObj.LoadModule('module', 'pathsourcefile');


%% Save setting file

stgObj.SaveToFile('bin');