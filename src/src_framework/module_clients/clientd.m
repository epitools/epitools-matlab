classdef clientd < handle
    %CLIENTD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        uid
        desc_name
        filepath
        dependences
        commands
        exec_priority
        status
        
    end
    
    methods
        
        function cli = clientd()
            
            cli.uid = [];
            cli.desc_name = [];
            cli.filepath = [];
            cli.dependences = [];
            cli.commands = [];
            cli.exec_priority = [];
            cli.status = [];

        end
        
        function cli = addClient(cli, clientfile, status)
            
            a = xml_read(clientfile);
            attributes = fieldnames(a);
            
            if(length(cli) == 1 && isempty(cli.uid))
            
                idx = 1;
            else
                idx = length(cli)+1;
                
            end
            
            for i=1:numel(attributes)
                cli(idx).(char(attributes(i))) = a.(char(attributes(i)));
            end

            cli(idx).filepath = clientfile;
            cli(idx).status = status; 
            
           
        end
        
        function SetPriority(cli,intPriority)
        
            cli;
        
        end
        
        function ModifyCommand(cli)  
            
            cli;
        end
        
        function announceToFramework(cli, callerID)
            client_modules = getappdata(callerID, 'client_modules');
            if isempty(client_modules)
               client_modules(1).ref = cli;
            else
               client_modules(end+1).ref = cli;
            end
            setappdata(callerID, 'client_modules', client_modules);
        end
    end
    
end

