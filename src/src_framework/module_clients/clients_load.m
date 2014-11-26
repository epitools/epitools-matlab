function inst_client  = clients_load
%CLIENTS_LOAD This function recursively checks all the modules available
%in the src_analysis folder and exports their APIs to pool
% This function checks recursively src_analysis folder in order to identify
% and export all the APIs available. This process will terminate exporting
% to [pool] all the implemented resources to the main environment.

% Initialisation local variables
inst_client = clientd();
% Explode src_analysis folder
contents = dir('src_analysis');
for i=1:numel(contents)
    % Avoid considering file in the current directory
    if (contents(i).isdir ~= 1);continue;end
    if (strfind(contents(i).name,'module_'))
        % Check if exist a file named> header.xml in each module_ prefixed
        % folders contained in src_analysis.
        if(exist(['src_analysis/',contents(i).name,'/header.xml'],'file'))
            filename = ['src_analysis/',contents(i).name,'/header.xml'];
            %inst_client = inst_client.addClient(filename, 'active');
            inst_client = inst_client.addClient(filename, 'active');
        end
    end
end
end

