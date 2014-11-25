function jtable = uitreetable_serverpool(obj, globalHandle)
%Uitreetable_serverqueue Summary of this function goes here

headers = {'Pool','Label', 'Active'};
rawdata = {};
%% Data preparation
% for each pool in the ref pool obj

for i = 1:size(globalHandle(2:end),2)
    name = globalHandle(i+1).ref.file;
    status = globalHandle(i+1).ref.active;
    if ~isempty(globalHandle(i+1).ref.tags)
        for o = 1:numel(globalHandle(i+1).ref.tags)
           rawdata(end+1,:) = {name, globalHandle(i+1).ref.tags{o}, status};
        end
    else
        rawdata(end+1,:) = {name, [], status};
    end

end
if(size(rawdata,2) == 0); rawdata = cell(1,2); end


%% Generate treetable
% selector = {'One','Two','Many'};
colTypes = {'label','label','label'};
colEditable = {false, false, true};
icons = {fullfile('./images/icons/bookmark.png'), ...
         fullfile('./images/icons/book_open.png'), ...
         fullfile('./images/icons/book.png'), ...
};
 
% Create the table in the current figure
jtable = treeTable('Container',obj, 'Headers',headers, 'Data',rawdata, ...
                   'ColumnTypes',colTypes, 'ColumnEditable',colEditable, ...
                   'IconFilenames',icons, 'Groupable',true, 'InteractiveGrouping',false);

%set(handle(jtable.getSelectionModel,'CallbackProperties'), 'ValueChangedCallback', {@selectionCallback,    jtable});


%uitreetable_contextualmenu(jtable);

end

% %function selectionCallback(hSelectionModel,hEvent,jtable)
%     % Get the selection data
%     %AnchorSelectionIndex = get(hSelectionModel,'AnchorSelectionIndex');
%     MinSelectionIndex  = get(hSelectionModel,'MinSelectionIndex');
% 
%     if (get(jtable.getRowAt(MinSelectionIndex), 'Level')==0)
%         %root = MinSelectionIndex+1;
%     else
%         root = jtable.getRowAt(MinSelectionIndex).getParent.getLevel +1;
%         hMainGui = getappdata(0, 'hMainGui');
%         pool_instances = getappdata(hMainGui, 'pool_instances');
%         if(pool_instances(root+1).ref.active)
%             pool_instances(root+1).ref.deactivatePool;
%         elseif(~pool_instances(root+1).ref.active)
%             pool_instances(root+1).ref.activatePool;
%         end
%         
%         pool_instances(root+1).ref.buildGUInterface(pool_instances(root+1).ref.handleGraphics, ...
%             pool_instances);
%         setappdata(hMainGui, 'pool_instances',pool_instances);
%     end
%     
%     % Now do something useful with this info
%     fprintf('Selected rows %d with parent %d\n', MinSelectionIndex, root);
% end