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
        end

        % Dispatcher function for MessageAdded events
        function receivedMessage(sd)
            if ~isempty(sd.handleJTreeTable)
%                 
%                 temp = struct2cell(sd.queue(sd.eventData))';
%                 temp = [temp(end),temp(1:3),sd.status(sd.eventData).desc];
%                 
%                 serverd_manager.updateServerQueueGUI('Add',...
%                                                      sd.handleJTreeTable,...
%                                                      temp)
                    sd.buildGUInterface;
             end
            serverd_manager.executeQueue(sd)
        end %receivedMessage
        
        % Dispatcher function for MessageRemoved events
        function removedMessage(sd)
             if ~isempty(sd.handleJTreeTable)
%                 serverd_manager.updateServerQueueGUI('Remove',...
%                                                      sd.handleJTreeTable,...
%                                                      sd.eventData)

                  sd.buildGUInterface;
            end
            
            serverd_manager.executeQueue(sd)
        end %removedMessage
      
        function flushedQueue(sd)
            serverd_manager.executeQueue(sd)
        end %flushedQueue
        
        %% Service functions for dispatchers
        % Display server queue in JTableTree Swing Object
        function updateServerQueueGUI(action, handle, varargin)
           
           jtable = handle;
           model = jtable.getModel.getActualModel.getActualModel;
           if(isempty(model.getDataVector.get(0).firstElement))
                model.removeRow(0)
           end
           
           switch action
               case 'Add'
                    model.addRow(varargin{1})
               case 'Remove'
                    model.removeRow(varargin{1})
           end
           jtable.repaint;
           
        end %updateServerQueueGUI
        % ---------------------------------------------------------------------------
        function executeQueue(sd)
            % If queue lenght is below the execution threshold, then
            % do not proceed with execution. However, listen for [force event]
            if (length(sd.queue) <  sd.execProcessThreshold);return;end
            %% Executing messages stored in queue from top to bottom
            %  Execution is invoked for each message in the queue.
            %  Evaluation of priority is required since messages are
            %  prioritized according to their content. 
            while ~isempty(sd.queue)
                if (isempty(sd.queue));return;end
                nomatlab = false; nosystem = false;
                %i = numel(sd.queue);
                i = 1;
                procMeta = struct();
                %% Display execution status 
                log2dev(sprintf('\nProcessing message at position [%s] with code %s \n',sd.queue(i).idx,sd.queue(i).code ),'INFO');
                % Direct messages on predefined machine if not specified
                % otherwise in user preferences. 
                procMeta.machine_exec    = 'localhost';
                procMeta.execution_start = now();
                %% Evaluate command in message
                % Send the command line to the auxiliary execution of matlab if allowed in
                % the setting properties of EpiTools. In case an auxiliary execution is not
                % running, then if allowed, run it. In case the user did not set it, then
                % execute it locally, suspending all other processes.   
                %
                % Execute the command as a MATLAB Function
                try
                    [status,~] = eval(sd.queue(i).command);
                    % Check output status and adjust stored status accordingly.
                    if(status == 0)
                        procMeta.status = 'Processed';
                    else
                        procMeta.status = 'Failed:MATLAB-Error0';
                    end
                catch err
                    % Check output status and adjust stored status accordingly.
                    procMeta.status = 'Failed';
                    log2dev(sprintf('\nEPITOOLS:executeQueue:MATLAB-Error0 | %s\n',...
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
                            procMeta.status = 'Failed:MATLAB-Error0';
                        end
                    catch err
                        % Check output status and adjust stored status accordingly.
                        procMeta.status = 'Failed';
                        log2dev(sprintf('\nEPITOOLS:executeQueue:System-Error0 | %s\n',...
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
                    log2dev(sprintf('\nEPITOOLS:executeQueue:destinationUnsupported | Message at position [%s] on machine %s cannot be executed. \n',...
                                    sd.queue(i).idx,...
                                    procMeta.machine_exec),...
                            'WARN');
                else
                    log2dev(sprintf('\nExecuted message at position [%s] on machine %s in %i seconds\n',...
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
                if (~strcmp(procMeta.status,'Processed'))
                    if(~isempty(sd.handleGraphics)) % find pool hMainGui environment variables
                         sd.queue(i).refpool;
                         pool.addTag(sd.queue(i).export_tag)
                     else % find pool in the workspace variables if one of the possible pool variables is associated with the fil
                         % Retrieve all variables names
                         varList = who();
                         for idxVar = 1:numel(varList)
                            if(isa(varList(idxVar),'poold'))
                                
                                if(strcmp(varList(idxVar).file, sd.queue(i).refpool))
                                    try
                                       eval(varList(idxVar).appendTag(export_tag));
                                    catch err
                                       log2dev(sprintf('\nEPITOOLS:executeQueue:ExportingTaginPool | %s\n',...
                                                        err.message),...
                                                'WARN');
                                    end 
                                end % if
                            end % if
                         end % for
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