function disconnectPool() % to be moved
hMainGui = getappdata(0, 'hMainGui');
pool_instances = getappdata(hMainGui, 'pool_instances');

for i=2:numel(pool_instances)
    try
        delete(['tmp/',pool_instances(i).ref.file]);
    catch
        log2dev(sprintf('EPITOOLS:DisconnectPool:DeletePoolFiles | %s',err.message),'WARN');
    end
end
setappdata(hMainGui, 'pool_instances',struct());
end