function execution_status = generate_empty_settingsfile(outpath)
%generate_empty_settingsfile instantiates a new user setting file for the
%program.

%% In case of no arg are passed to the function
if nargin < 1
    outpath = 'usersettings.xml';
end

%% Initialisation of structures
settingsobj = struct();

%% Log section

settingsobj.logs.levels.ctl_levelsvalue.name = 'Select logging levels';
settingsobj.logs.levels.ctl_levelsvalue.visible = 1;
settingsobj.logs.levels.ctl_levelsvalue.desc = 'multiple';
settingsobj.logs.levels.ctl_levelsvalue.values = {'INFO', 'DEBUG', 'PROC', 'GUI', 'WARN', 'ERR', 'VERBOSE'};
settingsobj.logs.levels.ctl_levelsvalue.actived = [1 0 0 1 0 0 0];

settingsobj.logs.execution.ctl_execution.name = 'Execute log';
settingsobj.logs.execution.ctl_execution.visible = 1;
settingsobj.logs.execution.ctl_execution.desc = 'single';
settingsobj.logs.execution.ctl_execution.values = {'on', 'off'};
settingsobj.logs.execution.ctl_execution.actived = [1 0];


settingsobj.logs.devices.ctl_outdevices.name = 'Logging device';
settingsobj.logs.devices.ctl_outdevices.visible = 1;
settingsobj.logs.devices.ctl_outdevices.desc = 'multiple';
settingsobj.logs.devices.ctl_outdevices.values = {'file', 'generic-gui', 'console', 'log window' };
settingsobj.logs.devices.ctl_outdevices.actived = [0 0 1 1];

%% Input format section
settingsobj.input.formats.ctl_inputformat.name = 'Select input image file format';
settingsobj.input.formats.ctl_inputformat.visible = 1;
settingsobj.input.formats.ctl_inputformat.desc = 'multiple';
settingsobj.input.formats.ctl_inputformat.values = {'.czi', '.zvi', '.cxd', '.ome', '.ome.tiff', '.mrc', '.tif', '.tiff', '.lif', '.lei', '.ipl', '.raw', '.ics', '.ids', '.bmp', '.png', '.pic', '.mvd2'};
settingsobj.input.formats.ctl_inputformat.actived = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];

%% Output format section

settingsobj.output.formats.ctl_outputsformat.name = 'Select output file format';
settingsobj.output.formats.ctl_outputsformat.visible = 0;
settingsobj.output.formats.ctl_outputsformat.desc = 'multiple';
settingsobj.output.formats.ctl_outputsformat.values = {'INFO', 'DEBUG', 'PROC', 'GUI', 'WARN', 'ERR', 'VERBOSE'};
settingsobj.output.formats.ctl_outputsformat.actived = [1 1 1 1 1 1 1];


settingsobj.output.icy.ctl_enableicyconnection.name = 'Enable connection to ICY';
settingsobj.output.icy.ctl_enableicyconnection.visible = 1;
settingsobj.output.icy.ctl_enableicyconnection.desc = 'single';
settingsobj.output.icy.ctl_enableicyconnection.values = {'on', 'off'};
settingsobj.output.icy.ctl_enableicyconnection.actived = [0 1];

settingsobj.output.icy.ctl_connectionstring.name = 'ICY connection string';
settingsobj.output.icy.ctl_connectionstring.visible = 1;
settingsobj.output.icy.ctl_connectionstring.desc = 'text';
settingsobj.output.icy.ctl_connectionstring.values = 'none';


%% Framework option section

settingsobj.framework.memory.ctl_memoryvalue.name = 'Memory value';
settingsobj.framework.memory.ctl_memoryvalue.visible = 1;
settingsobj.framework.memory.ctl_memoryvalue.desc = 'text';
settingsobj.framework.memory.ctl_memoryvalue.values = 512;

settingsobj.framework.processors.ctl_processorsdefault.name = 'Default processors';
settingsobj.framework.processors.ctl_processorsdefault.visible = 1;
settingsobj.framework.processors.ctl_processorsdefault.desc = 'text';
settingsobj.framework.processors.ctl_processorsdefault.values = '';

settingsobj.framework.debug.ctl_debug.name = 'Debug mode';
settingsobj.framework.debug.ctl_debug.visible = 1;
settingsobj.framework.debug.ctl_debug.desc = 'single';
settingsobj.framework.debug.ctl_debug.values = {'on', 'off'};
settingsobj.framework.debug.ctl_debug.actived = [1 0];

settingsobj.framework.sendinformations.ctl_usageinformation.name = 'Sending usage informations';
settingsobj.framework.sendinformations.ctl_usageinformation.visible = 1;
settingsobj.framework.sendinformations.ctl_usageinformation.desc = 'single';
settingsobj.framework.sendinformations.ctl_usageinformation.values = {'on', 'off'};
settingsobj.framework.sendinformations.ctl_usageinformation.actived = [1 0];

settingsobj.framework.serverconnectionstring.ctl_serverstring.name = 'Connection string';
settingsobj.framework.serverconnectionstring.ctl_serverstring.visible = 1;
settingsobj.framework.serverconnectionstring.ctl_serverstring.desc = 'text';
settingsobj.framework.serverconnectionstring.ctl_serverstring.values = '';

settingsobj.framework.serverupboundprocesses.ctl_serverupboundprocesses.name = 'Automatic server queue execution after no. processes';
settingsobj.framework.serverupboundprocesses.ctl_serverupboundprocesses.visible = 1;
settingsobj.framework.serverupboundprocesses.ctl_serverupboundprocesses.desc = 'text';
settingsobj.framework.serverupboundprocesses.ctl_serverupboundprocesses.values = 1;

%% Window option section

settingsobj.windows.autocentering.ctl_activate.name = 'Resize activation';
settingsobj.windows.autocentering.ctl_activate.visible = 1;
settingsobj.windows.autocentering.ctl_activate.desc = 'single';
settingsobj.windows.autocentering.ctl_activate.values = {'on', 'off'};
settingsobj.windows.autocentering.ctl_activate.actived = [1 0];



%% Licence

settingsobj.licence.NDA.ctl_activate.name = 'Non Disclosing Agreement (NDA)';
settingsobj.licence.NDA.ctl_activate.visible = 1;
settingsobj.licence.NDA.ctl_activate.desc = 'single';
settingsobj.licence.NDA.ctl_activate.values = {'on', 'off'};
settingsobj.licence.NDA.ctl_activate.actived = [1 0];

%% Save settings
xml_write( outpath, settingsobj);

end

