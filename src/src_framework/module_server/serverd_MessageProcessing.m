function [ SERVERINST ] = serverd_MessageProcessing( CLIPROINST, SERVERINST, SESSIONPOOLS, DEFAULTPOOL, OPTIONS)
%SERVERMESSAGEPROCESSING Summary of this function goes here
%% Remapping structure to avoid explosion nested structure naming
%local.dependences = CLIPROINST.dependences.dependence;
%pools = SESSIONPOOLS;
%defpool = DEFAULTPOOL;
%dependence = {};
%status = [];
%% Check for withdrawals
if serverd_checkwithdrawals( CLIPROINST, SESSIONPOOLS, OPTIONS ); return; end
%% Check dependences list
[ dependence, status, interrupt ] = serverd_checkdependenceslist( CLIPROINST, SESSIONPOOLS, DEFAULTPOOL);
if interrupt; return; end
%% Append resolved dependences to message queue
if ~isempty(dependence(status==1)); messagestruct.dependences = dependence(status==1);else  messagestruct.dependences = {}; end
%% Split commands in CLIPROINST in order to be sent singoularly
for idxCom = 1:length(CLIPROINST.commands.command)
    argvs = '{';
    input = '';
    % Get next available position on server queue
    newUID = SERVERINST.getNextQueuePosition();
    % CODE
    messagestruct.code = CLIPROINST.commands.command(idxCom).uid;
    % COMMAND
    % If a MATLAB file is invoked, then composed the command has follows:
    if (~isempty(regexp(CLIPROINST.commands.command(idxCom).exec,'\.m','match')))
        % Input splitting and reassembly
        if(isempty(CLIPROINST.commands.command(idxCom).input));
            input = '';
        else
            input = '';
            %input = '(';
            if(~isa(CLIPROINST.commands.command(idxCom).input,'char'))
                for idxInput = 1:numel(CLIPROINST.commands.command(idxCom).input)
                    if(idxInput == numel(CLIPROINST.commands.command(idxCom).input))
                        input = [input,CLIPROINST.commands.command(idxCom).input{idxInput}];
                    else
                        input = [input,CLIPROINST.commands.command(idxCom).input{idxInput},','];
                    end
                end
            else
                input = [input,CLIPROINST.commands.command(idxCom).input];
            end
            %input = [input, ')'];
        end
        % Output splitting and reassembly
        if(isempty(CLIPROINST.commands.command(idxCom).output));
            output = '';
        else
            output = '[';
            if(~isa(CLIPROINST.commands.command(idxCom).output,'char'))
                for idxOutput = 1:numel(CLIPROINST.commands.command(idxCom).output)
                    if(idxOutput == numel(CLIPROINST.commands.command(idxCom).output))
                        output = [output,CLIPROINST.commands.command(idxCom).output{idxOutput}];
                    else
                        output = [output,CLIPROINST.commands.command(idxCom).output{idxOutput},','];
                    end
                end
            else
                output = [output,CLIPROINST.commands.command(idxCom).output];
            end
            output = [output, ']'];
        end
        % Extra variables splitting and reassembly
        if(~isempty(CLIPROINST.commands.command(idxCom).argvs));
            for idxArg=1:size(CLIPROINST.commands.command(idxCom).argvs.arg,1)
                if isa(CLIPROINST.commands.command(idxCom).argvs.arg{idxArg,2}, 'char')
                    str = ['''',CLIPROINST.commands.command(idxCom).argvs.arg{idxArg,1},''',''',CLIPROINST.commands.command(idxCom).argvs.arg{idxArg,2},''';'];
                else
                    str = ['''',CLIPROINST.commands.command(idxCom).argvs.arg{idxArg,1},''',',CLIPROINST.commands.command(idxCom).argvs.arg{idxArg,2},';'];
                end
                argvs = [argvs, str];
                %                     sprintf('%s ',...
                %                     CLIPROINST.commands.command(idxCom).argvs(idxArg).arg{1:end-1},...
                %                     CLIPROINST.commands.command(idxCom).argvs(idxArg).arg{end})];
            end
        end
        argvs = [argvs, '}'];
        if ~isempty(argvs);
            if isempty(input);funarg = argvs;else funarg = [input,',',argvs]; end
        else funarg = input; end
        % Completing reassembly of command line
        if isempty(output)
            messagestruct.command  = [regexprep(CLIPROINST.commands.command(idxCom).exec,'\.m',''),'(',funarg,')',';'];
        else
            messagestruct.command  = [output,' = ',regexprep(CLIPROINST.commands.command(idxCom).exec,'\.m',''),'(',funarg,')',';'];
        end
    else
        % If a SYSTEM command is invoked, then composed the command has follows:
        % Input splitting and reassembly
        if(isempty(CLIPROINST.commands.command(idxCom).input));
            input = '';
        else
            input = '--input ';
            if(~isa(CLIPROINST.commands.command(idxCom).input,'char'))
                for idxInput = 1:numel(CLIPROINST.commands.command(idxCom).input)
                    input = [input, ' ',CLIPROINST.commands.command(idxCom).input(idxInput)];
                end
            else
                input = [input,CLIPROINST.commands.command(idxCom).input];
            end
            input = [input,' '];
        end
        % Output splitting and reassembly
        if(isempty(CLIPROINST.commands.command(idxCom).output));
            output = '';
        else
            output = '--output ';
            if(~isa(CLIPROINST.commands.command(idxCom).output,'char'))
                for idxOutput = 1:numel(CLIPROINST.commands.command(idxCom).output)
                    output = [output, ' ' ,CLIPROINST.commands.command(idxCom).output(idxOutput)];
                end
            else
                output = [output, ' ' ,CLIPROINST.commands.command(idxCom).output];
            end
            output = [output,' '];
        end
        % Extra variables splitting and reassembly
        if(~isempty(CLIPROINST.commands.command(idxCom).argvs));
            for idxArg=1:numel(CLIPROINST.commands.command(idxCom).argvs)
                argvs = [argvs, ...
                    sprintf('%s ',...
                    CLIPROINST.commands.command(idxCom).argvs(idxArg).arg{1:end-1},...
                    CLIPROINST.commands.command(idxCom).argvs(idxArg).arg{end})];
            end
        end
        % Completing reassembly of command line
        messagestruct.command = [CLIPROINST.commands.command(idxCom).exec,' ',input,output,argvs];
    end
    messagestruct.priority          = CLIPROINST.exec_priority;
    messagestruct.date_submit       = now();
    messagestruct.export_tag        = CLIPROINST.commands.command(idxCom).tags;
    messagestruct.etc               = 10000;
    messagestruct.refpool           = SESSIONPOOLS.name;
    messagestruct.refclientprocess  = CLIPROINST.path;
    
    % Submit message to server process (retain uid)
    SERVERINST.AppendMessage(messagestruct);
end
%% Submit to server queue (is it necessary?)
checklist = struct();
checklist.dependence = dependence;
checklist.status = status;
