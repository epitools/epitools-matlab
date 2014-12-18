function connectServer()
hMainGui = getappdata(0, 'hMainGui');
% Retrieve GUI handle from calling environment
hUIControls = getappdata(hMainGui,'hUIControls');
settingsobj = getappdata(hMainGui,'settings_execution');
%% Initialisation of server
%  The following code initialise the server daemon which will store client
%  requests and forward command to queue and ask the workers to run them.
%  It will retrieve outcomes and it will redirect to dedicated pool.
server_instance = serverd();
server_instance.setFlushQueueBound(settingsobj.framework.serverupboundprocesses.ctl_serverupboundprocesses.values);
% Announce to framework
server_instance.announceToFramework(hMainGui);
server_instance.buildGUInterface(hUIControls.uipanel_serverqueue);
end