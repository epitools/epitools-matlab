function clients_load
%CLIENTS_LOAD This function recursively checks all the modules available 
%in the src_analysis folder and exports their APIs to pool
% This function checks recursively src_analysis folder in order to identify
% and export all the APIs available. This process will terminate exporting
% to [pool] all the implemented resources to the main environment. 

% Initialisation local variables
modules_found = 0;
avail_list = struct();

% Explode src_analysis folder
contents = dir('src_analysis');

for i=1:numel(contents)
    
    % Avoid considering file in the current directory
    if (contents(i).isdir ~= 1);continue;end
    if (strfind(contents(i).name,'module_'))
        
        % Check if exist a file named> header.xml in each module_ prefixed
        % folders contained in src_analysis.
        if(exist(['src_analysis/',contents(i).name,'/header.xml'],'file'))
          
          a = xml_read(['src_analysis/',contents(i).name,'/header.xml']);
          modules_found = modules_found +1;
          
          % Export PATH,UID,DESC_NAME for each modules found in src_analysis       
          avail_list(modules_found).path = ['src_analysis/',contents(i).name];
          avail_list(modules_found).uid = a.uid;

        end   
    end
    
end
xml_write('modules_available.xml',avail_list);
end



