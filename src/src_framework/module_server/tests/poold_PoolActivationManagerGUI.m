function pool_PoolActivationManagerGUI()

fig = figure('Visible','off',...
    'Name',sprintf('Select active pools'),...
    'Toolbar', 'none',...
    'Resize', 'off',...
    'NumberTitle', 'off',...
    'Position',[0,0,350,450]);
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(fig,'Color',defaultBackground)

hMainGui = getappdata(0, 'hMainGui');
pool_instances = getappdata(hMainGui, 'pool_instances');

data = {};
for i = 1:numel(pool_instances(2:end))
    
    data(i,:) = {pool_instances(i+1).ref.file,numel(pool_instances(i+1).ref.tags),pool_instances(i+1).ref.active}; 
    
end

columnname =   {'Pool File', 'Tags', 'Actived'};
columnformat = {'char', 'numeric', 'logical'};
columneditable =  [false false true];
t = uitable(fig,'Units','normalized','Position',...
            [0.05 0.05 0.90 0.90], 'Data', data,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnEditable', columneditable,...
            'RowName',[]);
        
set(t,'CellEditCallback', @uitable1_CellEditCallback);

% Move the GUI to the center of the screen.
movegui(fig,'center')
% No menu bar
set(fig,'MenuBar', 'None')
% Make the GUI visible.
set(fig,'Visible','on')

end

function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property.
% Empty if Data was not changed
% Error: error string when failed to convert EditData
hMainGui = getappdata(0, 'hMainGui');
pool_instances = getappdata(hMainGui, 'pool_instances');

if(eventdata.NewData)
    pool_instances(eventdata.Indices(1)+1).ref.activatePool;
elseif(~eventdata.NewData)
    pool_instances(eventdata.Indices(1)+1).ref.deactivatePool;
end

setappdata(hMainGui, 'pool_instances',pool_instances);
pool_instances(eventdata.Indices(1)+1).ref.buildGUInterface(pool_instances(eventdata.Indices(1)+1).ref.handleGraphics,...
                                                            pool_instances);
end


