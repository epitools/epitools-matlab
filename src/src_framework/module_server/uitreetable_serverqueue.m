function jtable = uitreetable_serverqueue(obj,objServer)
%Uitreetable_serverqueue Summary of this function goes here

headers = {'Position','Code','Command','Priority','Status'};

[outQueue, outHistory] = objServer.PrintQueue;

switch(size(outQueue,2))
    case 0
        data = cell(1,4);
    case 1 
        data = struct2cell(outQueue)';
        data = [data(:,[1:4]),data(:,end)];
    otherwise 
        %data = struct2table(outQueue);
        data = table2cell(outQueue);
        data = [data(:,[1:4]),data(:,end)];
end

% selector = {'One','Two','Many'};
colTypes = {'label','label','label','label','label'};
colEditable = {false, false, false, false, false};
icons = {fullfile('./images/icons/application_view_xp_terminal.png'), ...
         fullfile('./images/icons/server.png'), ...
         fullfile('./images/icons/server_compressed.png'), ...
};
 
% Create the table in the current figure
jtable = treeTable('Container',obj, 'Headers',headers, 'Data',data, ...
                   'ColumnTypes',colTypes, 'ColumnEditable',colEditable, ...
                   'IconFilenames',icons, 'Groupable',true, 'InteractiveGrouping',false);

end

