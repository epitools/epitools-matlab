classdef clientd < handle
    %CLIENTD Daemon Class for client instances
    %   A client instance will provide methods and properties to server classes 
    %   providing informations and instructions on how to wrap client
    %   processes.
    
    properties
        uid
        desc_name
        path
        filepath
        tagpath
        dependences
        commands
        exec_priority
        status
        tags
    end
    
    methods
        
        function cli = clientd()
        % This function instanziate the clientd object which wraps the contents stored 
        % in the header.xml file in the correspondent folder.
            cli.uid = [];
            cli.desc_name = [];
            cli.path = [];
            cli.filepath = [];
            cli.tagpath = [];
            cli.dependences = [];
            cli.commands = [];
            cli.exec_priority = [];
            cli.status = [];
            cli.tags = [];
        end
        % --------------------------------------------------------------------
        function cli = addClient(cli, clientfile, status)
        % This function will load the content stored in clientfile into [clientd]
        % datastructure. 
            % Read xml file
            a = xml_read(clientfile);
            % Read the attributes of a structure object
            attributes = fieldnames(a);
            % Append in the datastructure
            if(length(cli) == 1 && isempty(cli.uid))
                idx = 1;
            else
                idx = length(cli) +1;
            end
            % Add values
            for i=1:numel(attributes)
                cli(idx).(char(attributes(i))) = a.(char(attributes(i)));
            end
            cli(idx).filepath = clientfile;
            
            cli(idx).tagpath = clientfile;
            
            cli(idx).status = status; 
            splitStr = regexp(cli(idx).filepath,'/','split');
            if(exist(char(strcat(splitStr(1),'/',splitStr(2),'/tags.xml')),'file'))
                cli(idx).tags = xml_read(char(strcat(splitStr(1),'/',splitStr(2),'/tags.xml')));
                cli(idx).tagpath = char(strcat(splitStr(1),'/',splitStr(2),'/tags.xml'));
            else
                cli(idx).tags = [];
                cli(idx).tagpath = [];
            end
            
            cli(idx).path = char(strcat(splitStr(1),'/',splitStr(2)));
            
        end
        % --------------------------------------------------------------------
        function setPriority(cli,intPriority)
        
            cli;
        
        end
        % --------------------------------------------------------------------
        function addArgument(cli,structCommand)  
            for i = 1:numel(cli.commands)
                if(strcmp(cli.commands.command(i).uid,structCommand.uid))
                    cli.commands.command(i).exec
                    cli.commands.command(i).input
                    cli.commands.command(i).output
                    cli.commands.command(i).argv
                end
            end
        end
        % --------------------------------------------------------------------
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

