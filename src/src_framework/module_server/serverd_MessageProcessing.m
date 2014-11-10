function [ SERVERINST ] = serverd_MessageProcessing( CLIPROINST, SERVERINST, SESSIONPOOLS)
%SERVERMESSAGEPROCESSING Summary of this function goes here
%   Detailed explanation goes here

%% CLIPROINST Instance - Admission to queue list subjected to dependence check
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

% Remapping structure to avoid explosion nested structure naming 
local.dependences = CLIPROINST.dependences.dependence;
pools = SESSIONPOOLS;
dependence = {};
status = [];

% Check dependences list
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
                fprintf('------------------------------------------------------------------------------------------\n');
                fprintf('%i dependences not satisfied after exception checking.\n', (length(status)-sum(status)));
                disp(CLIPROINST);
                fprintf('The process cannot be sent to server!\n');
                fprintf('------------------------------------------------------------------------------------------\n')
                return;
            end


        end % end else condition
  
    end % next dependence in the list
    
end

% ===================================================================
% COMMANDS
% Split commands in CLIPROINST in order to be sented singoularly
%
for idxCom = 1:length(CLIPROINST.commands.command)
    
    % MESSAGE
    % * CODE
    % * COMMAND
    % * PRIORITY
    % * DATE_SUBMIT
    % * EXPORT_TAG
    % * ETC
    argvs = ''; 

    messagestruct.code = CLIPROINST.commands.command(idxCom).uid;

    if(isempty(CLIPROINST.commands.command(idxCom).input)); 
        input = ''; 
    else 
        input = [' -i ', CLIPROINST.commands.command(idxCom).input];
    end

    if(isempty(CLIPROINST.commands.command(idxCom).output)); 
        output = ''; 
    else 
        output = [' -o ', CLIPROINST.commands.command(idxCom).output];
    end        
    
    if(~isempty(CLIPROINST.commands.command(idxCom).argvs)); 
        for idxArg=1:numel(CLIPROINST.commands.command(idxCom).argvs)

            argvs = [argvs, ...
                    sprintf('%s ',...
                            CLIPROINST.commands.command(idxCom).argvs(idxArg).arg{1:end-1},...
                            CLIPROINST.commands.command(idxCom).argvs(idxArg).arg{end})];
        end
    end

    messagestruct.command       = [CLIPROINST.commands.command(idxCom).exec,' ',input,output,argvs];
    messagestruct.priority      = CLIPROINST.exec_priority;
    messagestruct.date_submit   = datenum(now());
    messagestruct.export_tag    = CLIPROINST.commands.command(idxCom).tags;
    messagestruct.etc           = 10000;

    % Submit message to server process
    SERVERINST.AppendMessage(messagestruct);

end



% submit to server queue
checklist = struct();
checklist.dependence = dependence;
checklist.status = status;

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

end

