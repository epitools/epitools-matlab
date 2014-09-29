function execution_status = generate_empty_settingsfile(outpath)
%generate_empty_settingsfile instantiates a new user setting file for the
%program.

%% In case of no arg are passed to the function
if nargin < 1
    outpath = './.usersettings.xml';
end

%% Initialisation of structures
settings = struct();
settings.main = struct();

%% Log section

settings.main.logs.levels.ctl_levelsvalue.name = 'Select logging levels';
settings.main.logs.levels.ctl_levelsvalue.visible = 1;
settings.main.logs.levels.ctl_levelsvalue.desc = 'multiple';
settings.main.logs.levels.ctl_levelsvalue.values = {'INFO', 'DEBUG', 'PROC', 'GUI', 'WARN', 'ERR', 'VERBOSE'};
settings.main.logs.levels.ctl_levelsvalue.actived = [1 1 1 1 1 1 1];

settings.main.logs.execution.ctl_execution.name = 'Execute log';
settings.main.logs.execution.ctl_execution.visible = 1;
settings.main.logs.execution.ctl_execution.desc = 'single';
settings.main.logs.execution.ctl_execution.values = {'on', 'off'};
settings.main.logs.execution.ctl_execution.actived = [1 0];


settings.main.logs.devices.ctl_outdevices.name = 'Logging device';
settings.main.logs.devices.ctl_outdevices.visible = 1;
settings.main.logs.devices.ctl_outdevices.desc = 'multiple';
settings.main.logs.devices.ctl_outdevices.values = {'file', 'generic-gui', 'console', 'log window' };
settings.main.logs.devices.ctl_outdevices.actived = [0 0 1 1];

%% Input format section
settings.main.input.formats.ctl_inputformat.name = 'Select input image file format';
settings.main.input.formats.ctl_inputformat.visible = 1;
settings.main.input.formats.ctl_inputformat.desc = 'multiple';
settings.main.input.formats.ctl_inputformat.values = {'.czi', '.zvi', '.cxd', '.ome', '.ome.tiff', '.mrc', '.tif', '.tiff', '.lif', '.lei', '.ipl', '.raw', '.ics', '.ids', '.bmp', '.png', '.pic'};
settings.main.input.formats.ctl_inputformat.actived = [0 0 0 0 0 0 1 1 0 0 ];

%% Output format section

settings.main.output.formats.ctl_outputsformat.name = 'Select output file format';
settings.main.output.formats.ctl_outputsformat.visible = 0;
settings.main.output.formats.ctl_outputsformat.desc = 'multiple';
settings.main.output.formats.ctl_outputsformat.values = {'INFO', 'DEBUG', 'PROC', 'GUI', 'WARN', 'ERR', 'VERBOSE'};
settings.main.output.formats.ctl_outputsformat.actived = [1 1 1 1 1 1 1];

%% Framework option section

settings.main.framework.memory.ctl_memoryvalue.name = 'Memory value';
settings.main.framework.memory.ctl_memoryvalue.visible = 1;
settings.main.framework.memory.ctl_memoryvalue.desc = 'text';
settings.main.framework.memory.ctl_memoryvalue.values = 512;

settings.main.framework.processors.ctl_processorsdefault.name = 'Default processors';
settings.main.framework.processors.ctl_processorsdefault.visible = 1;
settings.main.framework.processors.ctl_processorsdefault.desc = 'text';
settings.main.framework.processors.ctl_processorsdefault.values = '';

settings.main.framework.debug.ctl_debug.name = 'Debug mode';
settings.main.framework.debug.ctl_debug.visible = 1;
settings.main.framework.debug.ctl_debug.desc = 'single';
settings.main.framework.debug.ctl_debug.values = {'on', 'off'};
settings.main.framework.debug.ctl_debug.actived = [1 0];

settings.main.framework.sendinformations.ctl_usageinformation.name = 'Sending usage informations';
settings.main.framework.sendinformations.ctl_usageinformation.visible = 1;
settings.main.framework.sendinformations.ctl_usageinformation.desc = 'single';
settings.main.framework.sendinformations.ctl_usageinformation.values = {'on', 'off'};
settings.main.framework.sendinformations.ctl_usageinformation.actived = [1 0];

settings.main.framework.serverconnectionstring.ctl_serverstring.name = 'Connection string';
settings.main.framework.serverconnectionstring.ctl_serverstring.visible = 1;
settings.main.framework.serverconnectionstring.ctl_serverstring.desc = 'text';
settings.main.framework.serverconnectionstring.ctl_serverstring.values = '';

%% Window option section

settings.main.windows.autocentering.ctl_activate.name = 'Resize activation';
settings.main.windows.autocentering.ctl_activate.visible = 1;
settings.main.windows.autocentering.ctl_activate.desc = 'single';
settings.main.windows.autocentering.ctl_activate.values = {'on', 'off'};
settings.main.windows.autocentering.ctl_activate.actived = [1 0];


%% Save settings
xml_write( outpath, settings);

end

