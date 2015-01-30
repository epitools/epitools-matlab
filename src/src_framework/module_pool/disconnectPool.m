function disconnectPool() % to be moved
hMainGui = getappdata(0, 'hMainGui');
pool_instances = getappdata(hMainGui, 'pool_instances');
settings_obj = getappdata(hMainGui,'settings_objectname');
for i=2:numel(pool_instances)
    try
        % Scan temporary directory and get only the default pool xml file
        if ~isempty(regexp(pool_instances(i).ref.name,'_default'))
           % Check if a folder named 'pools' exists in the fullpath location,
           % otherwise create it
           if ~exist([settings_obj.data_fullpath,'/pools'],'dir'); mkdir([settings_obj.data_fullpath,'/pools']); end
            % Copy all the pool files to analysis folder
            copyfile(['tmp/',pool_instances(i).ref.file], [settings_obj.data_fullpath,'/pools/',pool_instances(i).ref.file]);
        end
        % Delete from current location
        delete(['tmp/',pool_instances(i).ref.file]);
        % copyfile(['tmp/',pool_instances(i).ref.file], [settings_obj.data_fullpath,'/pools/',pool_instances(i).ref.file]);
    catch err
        log2dev(sprintf('EPITOOLS:DisconnectPool:DeletePoolFiles | %s',err.message),'WARN');
    end
end
setappdata(hMainGui, 'pool_instances',struct());
end