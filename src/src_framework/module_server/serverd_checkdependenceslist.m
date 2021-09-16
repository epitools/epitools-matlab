function [ dependence, status, interrupt ] = serverd_checkdependenceslist( CLIPROINST, pools, defpool)
%SERVERD_CHECKDEPENDENCESLIST Admission to queue list subjected to dependence check
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
% Initialization of temporary variables
interrupt = false;
dependence = {};
status = [];
local.dependences = CLIPROINST.dependences.dependence;
% For each dependence in the dependences structure
for i = 1:numel(local.dependences)
    % For each tag in tag list check if present in all the possible pools
    for ntag=1:numel(local.dependences(i).tags)
        % Check if the current tag is among those in the pool system or in
        % the default pool
        if(pools.existsTag(local.dependences(i).tags(ntag).tag));
            dependence{end+1} = local.dependences(i).tags(ntag).tag;
            status(end+1) = true;
        elseif (defpool.existsTag(local.dependences(i).tags(ntag).tag))
            dependence{end+1} = local.dependences(i).tags(ntag).tag;
            status(end+1) = true;
        else
            % If the current is not in the pool system, check if there is an exception
            % associated to it.
            % Generate lookup table for the current tag
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
                log2dev(sprintf('%i dependences not satisfied after exception checking.',...
                    (length(status)-sum(status))),'INFO');
                log2dev(sprintf('client process with properties:'),'INFO');
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
                interrupt = true;
            end
        end % end else condition
    end % next dependence in the list
end
% -------------------------------------------------------------------------
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
end


