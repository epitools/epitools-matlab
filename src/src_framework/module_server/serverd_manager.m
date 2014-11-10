classdef serverd_manager
    %SERVERD-MANAGER Event functions associations for Server Daemons
    
    methods (Static)
        
        function executeQueue(sd)

            fprintf('\nQueue lenght is: %i\n\n',length(sd.queue));
        end
        
        function listenerEvents(sd)
            
            % Add listener on serverd instance for events on Queue
            addlistener(sd, 'MessageAdded', ...
                @(src, evnt)serverd_manager.executeQueue(src));
            
            addlistener(sd, 'MessageRemoved', ...
                @(src, evnt)serverd_manager.executeQueue(src));
            
            addlistener(sd, 'QueueFlushed', ...
                @(src, evnt)serverd_manager.executeQueue(src));
            
            
        end
        
    end
end