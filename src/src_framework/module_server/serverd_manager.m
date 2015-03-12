classdef serverd_manager
    %SERVERD-MANAGER Event functions associations for Server Daemons
    
    methods (Static)
        % Add listener on serverd instance for events on Queue
        function listenerEvents(sd)
            addlistener(sd, 'MessageAdded', ...
                @(src, evnt)serverd_manager.receivedMessage(src));      
            addlistener(sd, 'MessageRemoved', ...
                @(src, evnt)serverd_manager.removedMessage(src));
            addlistener(sd, 'QueueFlushed', ...
                @(src, evnt)serverd_manager.flushedQueue(src)); 
            addlistener(sd, 'QueueModified', ...
                @(src, evnt)serverd_manager.updateQueue(src));
            addlistener(sd, 'ForceQueueExecution', ...
                @(src, evnt)serverd_manager.forceExecution(src)); 
        end
        
        %% Dispatchers
        % Dispatcher function for MessageAdded events
        function receivedMessage(sd)
            serverd_manager.executeQueue(sd)
        end %receivedMessage
        % Dispatcher function for MessageRemoved events
        function removedMessage(sd)
            serverd_manager.executeQueue(sd)
        end %removedMessage
        % Dispatcher for flushedQueue events
        function flushedQueue(sd)
            serverd_manager.executeQueue(sd)
        end %flushedQueue
        % Dispatcher for flushedQueue events
        function forceExecution(sd)
            serverd_manager.executeQueue(sd,'force')
        end %forceExecution
        %% Standalone functions (GUI Related)
        function updateQueue(sd)
             if ~isempty(sd.handleJTreeTable);sd.buildGUInterface;end
        end
        %% Service functions for dispatchers
        % Display server queue in JTableTree Swing Object
        function executeQueue(sd,strInput)
            if nargin<2; strInput = 'noforce'; end
            % If queue lenght is below the execution threshold, then
            % do not proceed with execution. However, listen for [force event]
            if (length(sd.queue) <  sd.execProcessThreshold) && strcmp(strInput, 'noforce');return;end
            %% Executing messages stored in queue from top to bottom
            %  Execution is invoked for each message in the queue.
            %  Evaluation of priority is required since messages are
            %  prioritized according to their content. 
            while ~isempty(fields(sd.queue))
                if (isempty(sd.queue));return;end
                nomatlab = false; nosystem = false;
                i = 1;
                procMeta = struct();
                %% Display execution status 
                log2dev(sprintf('Processing message at position [%s] with code %s',sd.queue(i).idx,sd.queue(i).code ),'INFO');
                % Direct messages on predefined machine if not specified
                % otherwise in user preferences and set its current status
                % in server structure
                procMeta.machine_exec       = 'localhost';
                procMeta.execution_start    = now();
                procMeta.execution_end      = [];
                procMeta.status             = 'executing';
                sd.setMessageStatus(i,procMeta);
                %% Evaluate command in message
                % Send the command line to the auxiliary execution of matlab if allowed in
                % the setting properties of EpiTools. In case an auxiliary execution is not
                % running, then if allowed, run it. In case the user did not set it, then
                % execute it locally, suspending all other processes.   
                %
                % Execute the command as a MATLAB Function
                try
                    [status_exec, argvar] = eval(sd.queue(i).command);
                    % Check output status and adjust stored status accordingly.
                    if(status_exec == 0)
                        procMeta.status = 'Processed';
                    else
                        procMeta.status = 'Failed:MATLAB-ErrorGreaterThan0';
                    end
                catch err
                    % Check output status and adjust stored status accordingly.
                    procMeta.status = 'Failed';
                    log2dev(sprintf('EPITOOLS:executeQueue:MATLAB-ErrorExecutableNotFound | %s',...
                                    err.message),...
                            'DEBUG');
                    nomatlab = true;
                end
                % Execute the command as SYSTEM call if the previous
                % attempt.
                if(nomatlab)
                    try
                        [status,~] = system(sd.queue(i).command);
                        % Check output status and adjust stored status accordingly.
                        if(status == 0)
                            procMeta.status = 'Processed';
                        else
                            procMeta.status = 'Failed:SYSTEM-ErrorGreaterThan0';
                        end
                    catch err
                        % Check output status and adjust stored status accordingly.
                        procMeta.status = 'Failed';
                        log2dev(sprintf('EPITOOLS:executeQueue:SYSTEM-ErrorExecutableNotFound | %s',...
                                        err.message),...
                                'DEBUG');
                        nosystem = true;
                    end
                end
                % Execution ended and time of execution is recorded despite
                % the outcome.
                procMeta.execution_end = now();
                %% Display execution status 
                if(nomatlab && nosystem) 
                    log2dev(sprintf('EPITOOLS:executeQueue:DestinationUnsupported | Message at position [%s] on machine %s cannot be executed since no executable destination has been found!',...
                                    sd.queue(i).idx,...
                                    procMeta.machine_exec),...
                            'WARN');
                else
                    log2dev(sprintf('Executed message at position [%s] on machine %s in %i seconds',...
                                    sd.queue(i).idx,...
                                    procMeta.machine_exec,...
                                    procMeta.execution_end-procMeta.execution_start),...
                            'INFO');
                end
                %% Tag exporting in Pool
                % if execution status has been positive, then release tags
                % in associated pool. Execution status is stored after
                % [evaluate command in messase] section. Only positively
                % ended execution allow for tag exportation. 
                if (strcmp(procMeta.status,'Processed'))
                    % find pool hMainGui environment variables
                    if(~isempty(sd.handleGraphics)) 
                         % Load [poold] objects saved in EpiTools environment
                         hMainGui = getappdata(0, 'hMainGui');
                         pool_instances = getappdata(hMainGui, 'pool_instances');
                         % Loop along the available pools: searching for
                         % the pool associated with executed command
                         poolfound = false;
                         for idxPool = 1:numel(pool_instances(2:end))
                             if(strcmp(pool_instances(idxPool+1).ref.name, sd.queue(i).refpool))
                                % Get process UID from list of available processes
                                hMainGui = getappdata(0, 'hMainGui');
                                clientdWrap = getappdata(hMainGui, 'client_modules');
                                clientdWrap = clientdWrap(2).ref;
                                clientProcess = clientdWrap(strcmp({clientdWrap.path},sd.queue(i).refclientprocess));
                                % Composing outgoing message to pool tag exportation method
                                poolmessage = struct();
                                poolmessage.uid = clientProcess.uid;
                                poolmessage.path = clientProcess.path;
                                poolmessage.tagstruct = sd.queue(i).export_tag;
                                poolmessage.execvalues = argvar;
                                poolmessage.argvar = clientProcess;
                                % Append tags in correspondent pool
                                pool_instances(idxPool+1).ref.processTag(poolmessage);
                                % Store pool reference collector into
                                % session environment
                                setappdata(hMainGui, 'pool_instances',pool_instances);
                                poolfound = true;
                             end
                         end
                         if ~poolfound
                         	log2dev(sprintf('EPITOOLS:executeQueue:ExportingTagsInPool | Message at position [%s] does not have a valid pool reference or pool not found. Possible Data Loss!',...
                                            sd.queue(i).idx),...
                                    'WARN');
                         end
                     else % find pool in the workspace variables if one of the possible pool variables is associated with the file
                         % Retrieve all variables names
                         varList = evalin('base','whos');
                         poolfound = false;
                         for idxVar = 1:numel(varList)
                            if(strcmp(varList(idxVar).class,'poold'))
                                if(strcmp(varList(idxVar).name, sd.queue(i).refpool))
                                    try
                                       p = evalin('base',varList(idxVar).name);
                                       % Get process UID from list of available processes
                                       clientdWrap = varList(strcmp({varList.class},'clientd')).name;
                                       clientObj = evalin('base',clientdWrap);
                                       clientProcess = clientObj(strcmp({clientObj.path},sd.queue(i).refclientprocess));
                                       % Composing outgoing message to pool tag exportation method
                                       poolmessage = struct();
                                       poolmessage.uid = clientProcess.uid;
                                       poolmessage.path = clientProcess.path;
                                       poolmessage.tagstruct = sd.queue(i).export_tag;
                                       poolmessage.execvalues = argvar;
                                       poolmessage.argvar = clientProcess;
                                       % Exporting to pool
                                       p.processTag(poolmessage);
                                       % Reassing object pool to calling environment
                                       assignin('base', varList(idxVar).name, p);
                                       % Pool was found and used correctly
                                       poolfound = true;
                                    catch err
                                       log2dev(sprintf('EPITOOLS:executeQueue:ExportingTaginPool | %s',...
                                                        err.message),...
                                               'WARN');
                                    end 
                                end % if
                            end % if
                         end % for
                         if ~poolfound
                            log2dev(sprintf('EPITOOLS:executeQueue:ExportingTagsInPool | Message at position [%s] does not have a valid pool reference or pool not found. Possible Data Loss!',...
                                            sd.queue(i).idx),...
                                    'WARN');
                         end
                     end % if
                 end % if
                %% Flush message from queue    
                % Update message queue> status and pass it to history
                sd.FlushMessage(i, procMeta);               
            end % /while
             
        end %executeQueue
         % ---------------------------------------------------------------------------
    end
end