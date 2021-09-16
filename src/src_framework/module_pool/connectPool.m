function connectPool(poolname)
hMainGui = getappdata(0, 'hMainGui');
hUIControls = getappdata(hMainGui,'hUIControls');
%% Initialisation of pool
%  The following code will initialize the pool containing exported tags 
%  from commands executed by server workers.
pool = poold(poolname);
pool.loadPool();
% Announce to framework
pool.announceToFramework(hMainGui);
pool_instances = getappdata(hMainGui, 'pool_instances');
pool.buildGUInterface(hUIControls.uipanel_serverpool, pool_instances);
pool.activatePool();
end