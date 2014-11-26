classdef serverd < handle
    %SERVER-Daemon Class for server instances
    %   A server instance will provide methods and properties in order to
    %   serve client processes during the execution of a main application.
    
    properties (SetAccess = private)
        status = struct([]);
        history = struct([]);
        queue = struct([]);
        handleJTreeTable = '';
        handleGraphics = '';
        execProcessThreshold = [];
        eventData = [];
    end
    
    % Define events triggered by server daemon execution
    events
        MessageAdded
        MessageRemoved
        QueueFlushed
        QueueEmpty
        ServerInstance
    end
    
    methods   
        function sd = serverd()
        % This function instanziate the serverd object which will trigger 
        % its announcement to the calling environment
            sd.queue = struct([]);
            sd.status = struct([]);
            sd.history = struct([]);
            sd.handleJTreeTable = '';
            sd.handleGraphics = '';
            sd.execProcessThreshold = 5;
            sd.eventData = '';
            
            % Listeners
            serverd_manager.listenerEvents(sd);
            % Announce to environment
            notify(sd,'ServerInstance');
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
                if strcmp(sd.status(i).desc, 'pending')
                    sd.status(i).desc          = 'flushed before execution';
                else
                    sd.status(i).desc          = sd.status(i).desc;
                end
                
                
            end
            
            [code, idxQueue, idxStatus] = intersect({sd.queue.idx},{sd.status.idx});
            
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
        function FlushMessage(sd, idxMessage, metadata)
        % Remove all messages in queue after flushing them and report
        % their status to session history

            try
            % Move into session history
            
            sd.status(idxMessage).machineid         = metadata.machine_exec;
            sd.status(idxMessage).execution_start   = metadata.execution_start;
            sd.status(idxMessage).execution_end     = metadata.execution_end;
            sd.status(idxMessage).desc              = metadata.status;      

                       
            merged = struct('idx', {sd.queue(idxMessage).idx},...
                    'code', {sd.queue(idxMessage).code}, ...
                    'command', {sd.queue(idxMessage).command},...
                    'priority',{sd.queue(idxMessage).priority},...
                    'date_submit',{sd.queue(idxMessage).date_submit},...
                    'export_tag',{sd.queue(idxMessage).export_tag},...
                    'machine_exec',{sd.status(idxMessage).machineid},...
                    'execution_start',{sd.status(idxMessage).execution_start},...
                    'execution_end',{sd.status(idxMessage).execution_end},...
                    'execution_status',{sd.status(idxMessage).desc});     
            
            if(length(sd.history) < 1);sd.history = merged;else sd.history(end+1) = merged; end
            
            % Flush queue
            sd.queue(idxMessage)  = [];
            sd.status(idxMessage) = [];
            
            catch exceptions
         
                disp(exceptions);
            
            end
            
        end
        % =================================================================
        % Server functions: internal
        % =================================================================
        % Append Message to server daemon queue
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
            % Count messages sent to history structure
            structMessage.idx =  strcat('Q',num2str(idx + length(sd.history)));
            status.code = structMessage.code;
            status.machineid = '';
            status.execution_start = '';
            status.execution_end = '';
            status.desc = 'pending';
            status.idx = structMessage.idx;
            if(~isempty(sd.queue) && ~isempty(fieldnames(sd.queue)))
                sd.queue(end+1) = structMessage;
                sd.status(end+1) = status;
            else
                sd.queue = structMessage;
                sd.status = status;
            end
            sd.eventData = length(sd.queue);
            % Notify event if everything above was executed correctly
            notify(sd,'MessageAdded');
        end   
        % Remove Message from server daemon queue
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
            
            sd.eventData = position_numbers;
            
            % Notify event if everything above was executed correctly
            notify(sd,'MessageRemoved');
        end
        % Display Server Health status
        function [outQueue, outHistory] = PrintQueue(sd)
            outHistory = [];
            outQueue = [];
            
            %if(~isempty(fieldnames(sd.queue)))
            if(~isempty(sd.queue) && ~isempty(fieldnames(sd.queue)))
                
                [code, idxQueue, idxStatus] = intersect({sd.queue.idx},{sd.status.idx});
                %[code, idxQueue, idxStatus] = intersect(mat2str(sd.queue.code),mat2str(sd.status.code));
                
                merged = struct('idx', {sd.queue(idxQueue).idx},...
                    'code', {sd.queue(idxQueue).code}, ...
                    'command', {sd.queue(idxQueue).command},...
                    'priority',{sd.queue(idxQueue).priority},...
                    'date_submit',{sd.queue(idxQueue).date_submit},...
                    'export_tag',{sd.queue(idxQueue).export_tag},...
                    'machine_exec',{sd.status(idxStatus).machineid},...
                    'execution_start',{sd.status(idxStatus).execution_start},...
                    'execution_end',{sd.status(idxStatus).execution_end},...
                    'execution_status',{sd.status(idxStatus).desc});
                
                
                if length(merged) == 1
                    outQueue = merged;
                else
                    outQueue = struct2table(merged);
                end
            end
            
            if(~isempty(sd.history))
                
                
                if length(sd.history) == 1
                    outHistory = sd.history;
                else
                    outHistory = struct2table(sd.history);
                end
                
            end
            
            
        end     
        % Announce to Framework 
        function announceToFramework(sd, callerID)
            server_instances = getappdata(callerID, 'server_instances');
            if isempty(server_instances)
               server_instances(1).ref = sd;
            else
               server_instances(end+1).ref = sd;
            end
            setappdata(callerID, 'server_instances', server_instances);
        end
        % =================================================================
        % Server Functions: external
        % =================================================================
        function receiveMessage(sd, clientprocess, pool)
        
            sd = serverd_MessageProcessing( clientprocess, sd, pool);
        end
        % Initialize GUI interface for server process
        function buildGUInterface(sd, GraphicHandle)          
            if nargin == 2
                sd.handleGraphics   = GraphicHandle;
            end  
            sd.handleJTreeTable = uitreetable_serverqueue(sd.handleGraphics,sd);
        end
        % Initialize GUI interface for server process
        function out = getQueueStatistics(sd)

                out(1) = length(sd.queue);
                out(2) = length(sd.history);
        end
    end
end

