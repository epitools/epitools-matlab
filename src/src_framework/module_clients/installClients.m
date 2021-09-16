function installClients()
hMainGui = getappdata(0, 'hMainGui');
%% Client availability checking
%  The following code will list all the client available in the
%  src_analysis folder and it will allow the framework to know their status
client_modules = clients_load('src_analysis/');
% Announce to framework
client_modules.announceToFramework(hMainGui);
end