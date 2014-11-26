function [ SERVERINST ] = serverd_MessageProcessing( CLIPROINST, SERVERINST, SESSIONPOOLS)
%SERVERMESSAGEPROCESSING Summary of this function goes here
%   Detailed explanation goes here
%% Remapping structure to avoid explosion nested structure naming
local.dependences = CLIPROINST.dependences.dependence;
pools = SESSIONPOOLS;
dependence = {};
status = [];
%% Check dependences list
% Instance - Admission to queue list subjected to dependence check
% Subdivide CLIPROINST into segments
% ===========================================================================
% CLIPROINST.uid                =>  this code identifies the clipro instance
% CLIPROINST.dependences_list   =>  this structure contains the dependences
%                                   of the client process
% CLIPROINST.exec.commands      =>  this structure contains the commands to
%                                   execute
% CLIPROINST.exec.resources     =>  this structure contains the resources
%                                   neeeded to complete the process execution
% ===========================================================================
% For each dependence in the dependences structure
for i = 1:numel(local.dependences)
    
    % ===================================================================
    % TAGS
    % For each tag in tag list check if present in all the possible pools
    %
    for ntag=1:numel(local.dependences(i).tags)
        
        % Check if the current tag is among those in the pool system
        if(pools.existsTag(local.dependences(i).tags(ntag).tag));
            
            dependence{end+1} = local.dependences(i).tags(ntag).tag;
            status(end+1) = true;
            
            % If the current is not in the pool system, check if there is an exception
            % associated to it.
            
        else
            
            % ===================================================================
            % EXCEPTIONS
            % Generate lookup table for the current tag
            %
            lookup_rep = generateLookupTable();
            
            % iterate on lookup_rep until all the exception tag are checked
            found = false;
            for idx_lkrep = 1:length(lookup_rep)
                
                if(pools.existsTag(lookup_rep(idx_lkrep)));
                    found=true;
                    dependence(end+1) = lookup_rep(idx_lkrep);
                    status(end+1) = true;
                else
                    dependence(end+1) = lookup_rep(idx_lkrep);
                    status(end+1) = false;
                end
                
            end
            
            if ~found
                clientproperties = fieldnames(CLIPROINST);
                
                message = sprintf('-----------------------------------------------------------------------');
                log2dev(message,'INFO');
                message = sprintf('%i dependences not satisfied after exception checking.',...
                    (length(status)-sum(status)));
                log2dev(message,'INFO');
                message = sprintf('client process with properties:');
                log2dev(message,'INFO');
                log2dev('','INFO');
                for idx_clpr=1:numel(clientproperties)
                    if isa(CLIPROINST.(char(clientproperties(idx_clpr))), 'struct')
                        message = sprintf('%s%s',...
                            clientproperties{idx_clpr},...
                            structstruct(CLIPROINST.(char(clientproperties(idx_clpr)))));
                        log2dev(message,'DEBUG');
                    elseif isa(CLIPROINST.(char(clientproperties(idx_clpr))), 'double')
                        message = sprintf('%s:\t%s',...
                            clientproperties{idx_clpr},...
                            num2str(CLIPROINST.(char(clientproperties(idx_clpr)))));
                        log2dev(message,'INFO');
                    else
                        message = sprintf('%s:\t%s',...
                            clientproperties{idx_clpr},...
                            CLIPROINST.(char(clientproperties(idx_clpr))));
                        log2dev(message,'INFO');
                    end
                end
                log2dev('','INFO');
                message = sprintf('The process cannot be sent to server!');
                log2dev(message,'INFO');
                message = sprintf('-----------------------------------------------------------------------');
                log2dev(message,'INFO');
                
                return;
            end
            
            
        end % end else condition
        
    end % next dependence in the list
    
end
%% Split commands in CLIPROINST in order to be sented singoularly
for idxCom = 1:length(CLIPROINST.commands.command)
    argvs = '';
    input = '';
    % CODE
    messagestruct.code = CLIPROINST.commands.command(idxCom).uid;
    % COMMAND
    % If a MATLAB file is invoked, then composed the command has follows:
    if (~isempty(regexp(CLIPROINST.commands.command(idxCom).exec,'\.m','match')))
        % Input splitting and reassembly
        if(isempty(CLIPROINST.commands.command(idxCom).input));
            input = '';
        else
            input = '(';
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
            input = [input, ')'];
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
            for idxArg=1:numel(CLIPROINST.commands.command(idxCom).argvs)
                argvs = [argvs, ...
                    sprintf('%s ',...
                    CLIPROINST.commands.command(idxCom).argvs(idxArg).arg{1:end-1},...
                    CLIPROINST.commands.command(idxCom).argvs(idxArg).arg{end})];
            end
        end
        % Completing reassembly of command line
        messagestruct.command  = [output,' = ',regexprep(CLIPROINST.commands.command(idxCom).exec,'\.m',''),input,';'];
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
    
    messagestruct.priority      = CLIPROINST.exec_priority;
    messagestruct.date_submit   = now();
    messagestruct.export_tag    = CLIPROINST.commands.command(idxCom).tags;
    messagestruct.etc           = 10000;
    messagestruct.refpool       = pools.file;
    % Submit message to server process
    SERVERINST.AppendMessage(messagestruct);
end
%% Submit to server queue
checklist = struct();
checklist.dependence = dependence;
checklist.status = status;
end
%% Subfunctions
function lookup_rep = generateLookupTable()
lookup_rep = {};
for idxExc=1:numel(local.dependences(i).exceptions.exception)
    for idxTags=1:numel(local.dependences(i).exceptions.exception(idxExc).tags.tag)
        internaltag = local.dependences(i).exceptions.exception(idxExc).tags.tag(idxTags).id;
        if(strcmp(local.dependences(i).tags(ntag).tag, internaltag))
            lookup_rep{end+1} = local.dependences(i).exceptions.exception(idxExc).tags.tag(idxTags).rep;
        end
    end
end
end