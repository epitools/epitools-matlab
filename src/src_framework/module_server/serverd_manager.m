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
        
        function executeQueue(sd)
            
            % If queue lenght is below the execution threshold, then
            % do not proceed with execution. However, listen for [force event]
            if (length(sd.queue) <  sd.execProcessThreshold);return;end
            
            %fprintf('\nQueue length is: %i\n\n',length(sd.queue));
            messages = numel(sd.queue);
            
            while ~isempty(sd.queue)
                %if (isempty(sd.queue));return;end
                i = numel(sd.queue);
                procMeta = struct();
                % Executing messages stored in queue from top to bottom
                log2dev(sprintf('\nProcessing message at position [%s] with code %s \n',sd.queue(i).idx,sd.queue(i).code ),'INFO');

                procMeta.machine_exec    = 'localhost';
                procMeta.execution_start = now();

                % Evaluate command in message
                
                
                 % Release tags in pool
                if (strcmp(sd.status(idxMessage).desc,'Processed'))
                    
                    % find pool in the workspace or hMainGui available variables
            
                sd.queue(idxMessage).refpool;
                
                pool.addTag(sd.queue(i).export_tag)
           
                    if(~isempty(sd.handleGraphics))



                    else
                        eval(sd.queue(idxMessage).refpool.appendTag(''));
                    end
            
                end

                procMeta.execution_end = now();
                procMeta.status = 'Processed';

                % Update message queue> status and pass it to history
                log2dev(sprintf('\nExecuted message at position [%s] on machine %s in %i seconds\n',sd.queue(i).code,procMeta.machine_exec,procMeta.execution_end-procMeta.execution_start),'INFO');
                sd.FlushMessage(i, procMeta);     
                
            end
             
        end %executeQueue
     
    end
end