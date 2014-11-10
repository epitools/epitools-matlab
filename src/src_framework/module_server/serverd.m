classdef serverd < handle
    %SERVER-Daemon Class for server instances
    %   A server instance will provide methods and properties in order to
    %   serve client processes during the execution of a main application.
    
    properties (SetAccess = private)
        status = struct();
        history = struct();
        queue = struct();
    end
    
    % Define events triggered by server daemon execution
    events
        MessageAdded
        MessageRemoved
        QueueFlushed
        QueueEmpty
    end
    
    methods
        
        % =================================================================
        % Initialisation
        
        function sd = serverd()
            sd.queue = struct();
            sd.status = struct();
            sd.history = struct();
            serverd_manager.listenerEvents(sd);
        end
        
        
        % =================================================================
        % Queue functions
        
        function FlushQueue(sd)
            % Remove all messages in queue after flushing them and report
            % their status to session history
            
            
            try % If queue is empty, then do not flush
            if isempty(fieldnames(sd.queue)); return; end
            
            % Move into session history
            for i=1:numel(sd.queue)
                
                sd.queue(i).machineid       = sd.status(i).machineid;
                sd.queue(i).execution_start = sd.status(i).execution_start;
                sd.queue(i).execution_end   = sd.status(i).execution_end;
                sd.queue(i).status          = sd.status(i).desc;
                
            end
            
            [code, idxQueue, idxStatus] = intersect({sd.queue.code},{sd.status.code});
            
            merged = struct('code', code, ...
                'command', {sd.queue(idxQueue).command},...
                'priority',{sd.queue(idxQueue).priority},...
                'date_submit',{sd.queue(idxQueue).date_submit},...
                'export_tag',{sd.queue(idxQueue).export_tag},...
                'machine_exec',{sd.status(idxStatus).machineid},...
                'execution_start',{sd.status(idxStatus).execution_start},...
                'execution_end',{sd.status(idxStatus).execution_end},...
                'execution_status',{sd.status(idxStatus).desc});
            
            if(length(sd.history) == 1)
                
                sd.history = merged;
            else
                sd.history(end+1) = merged;
            end
            
            % Flush queue
            sd.queue = struct();
            sd.status = struct();
            
            % Server queue is empty
            notify(sd,'QueueEmpty');
            catch exceptions
            
                disp(exceptions);
            end
            
        end
        
        % =================================================================
        % Client Processes functions
        
        function AppendMessage(sd,structMessage)
            % Append message at the end of the queue
            % Message is a struct containing the following fields:
            % MESSAGE                       STATUS
            % * CODE                        * CODE
            % * COMMAND                     * MACHINEID
            % * PRIORITY                    * EXECUTION_START
            % * DATE_SUBMIT                 * EXECUTION_END
            % * EXPORT_TAG                  * DESC
            % * ETC
            %
            
            if(isempty(fieldnames(sd.queue)))
                idx = 1;
            elseif( length(sd.queue) == 1 && ~isempty(fieldnames(sd.queue)) )
                idx = 2;
            else
                idx = length(sd.queue) +1;
            end
            
            structMessage.idx =  idx;
            status.code = structMessage.code;
            status.machineid = '';
            status.execution_start = '';
            status.execution_end = '';
            status.desc = 'pending';
            
            
            if(~isempty(fieldnames(sd.queue)))
                sd.queue(end+1) = structMessage;
                sd.status(end+1) = status;
            else
                sd.queue = structMessage;
                sd.status = status;
            end
            
            
            % Notify event if everything above was executed correctly
            notify(sd,'MessageAdded');
            
        end
        
        
        function RemoveMessage(sd, position_numbers)
            % Remove message at the end of the queue given position number.
            %
            % * POSITION_NUMBER
            
            sd.status(position_numbers).desc = 'purged from queue';
           
            [code, idxQueue, idxStatus] = intersect({sd.queue.code},{sd.status.code});
            
            merged = struct('code', code, ...
                'command', {sd.queue(idxQueue).command},...
                'priority',{sd.queue(idxQueue).priority},...
                'date_submit',{sd.queue(idxQueue).date_submit},...
                'export_tag',{sd.queue(idxQueue).export_tag},...
                'machine_exec',{sd.status(idxStatus).machineid},...
                'execution_start',{sd.status(idxStatus).execution_start},...
                'execution_end',{sd.status(idxStatus).execution_end},...
                'execution_status',{sd.status(idxStatus).desc});
            
            if(length(sd.history) == 1)
                
                sd.history = merged;
            else
                sd.history(end+1) = merged;
            end
            
            
            sd.queue(position_numbers) = [];
            sd.status(position_numbers) = [];
            
            % Notify event if everything above was executed correctly
            notify(sd,'MessageRemoved');
        end
        
        % =================================================================
        % Display Server Health status
        
        function PrintQueue(sd)
            %TODO suppress printing in console
            if(~isempty(fieldnames(sd.queue)))
                [code, idxQueue, idxStatus] = intersect({sd.queue.code},{sd.status.code});
                %[code, idxQueue, idxStatus] = intersect(mat2str(sd.queue.code),mat2str(sd.status.code));
                
                merged = struct('idx',{sd.queue(idxQueue).idx},...
                    'code', code, ...
                    'command', {sd.queue(idxQueue).command},...
                    'priority',{sd.queue(idxQueue).priority},...
                    'date_submit',{sd.queue(idxQueue).date_submit},...
                    'export_tag',{sd.queue(idxQueue).export_tag},...
                    'machine_exec',{sd.status(idxStatus).machineid},...
                    'execution_start',{sd.status(idxStatus).execution_start},...
                    'execution_end',{sd.status(idxStatus).execution_end},...
                    'execution_status',{sd.status(idxStatus).desc});
                disp('-------------------------- Current Queue ----------------------------');
                
                if lenght(merged) == 1
                    disp(merged)
                else
                    disp(struct2table(merged));
                end
            end
            
            if(~isempty(fieldnames(sd.history)))
                disp('-------------------------- History Queue ----------------------------');
                
                if length(sd.history) == 1
                    disp(sd.history)
                else
                    disp(struct2table(sd.history));
                end
                
            end
            
            
        end
        
    end
end

