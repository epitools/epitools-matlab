% Load Libraries
clear;
LoadEpiTools;
clc;
%% Set log preferences
log_settings.log_level = {'INFO', 'DEBUG', 'PROC', 'GUI', 'WARN', 'ERR'};
log_settings.log_device = 3;
assignin('base', 'log_settings', log_settings);
%% Initialisation of server
%  The following code initialise the server daemon which will store client
%  requests and forward command to queue and ask the workers to run them.
%  It will retrieve outcomes and it will redirect to dedicated pool.
Server_00 = serverd();
% Announce to framework
%Server_00.announceToFramework();
%% Initialisation of pool
%  The following code will initialize the pool containing exported tags 
%  from commands executed by server workers.
Pool_00 = poold('clipro');
Pool_00.loadPool();
% Announce to framework
%Pool_00.announceToFramework();
%% Client availability checking
%  The following code will list all the client available in the
%  src_analysis folder and it will allow the framework to know their status
Clients_00 = clients_load();
% Announce to framework
%Clients_00.announceToFramework();
%% Sending process to server according SH01-CLIENT-SENDMESSAGE
%  The following code will send a message to a server instance announced to
%  the framework.
Server_00.buildGUInterface(figure());
% This will crash since the pool is empty
Server_00.receiveMessage(Clients_00(1),Pool_00);
% Load the pool if a support file exist 
Pool_00.loadPool();
% Message will be processed according rules
Server_00.receiveMessage(Clients_00(1),Pool_00);
Server_00.receiveMessage(Clients_00(2),Pool_00);
Server_00.receiveMessage(Clients_00(3),Pool_00);
Server_00.receiveMessage(Clients_00(4),Pool_00);
% Check the Queue status
Server_00.PrintQueue