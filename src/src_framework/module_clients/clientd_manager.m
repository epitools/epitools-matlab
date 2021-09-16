classdef clientd_manager
	%POOLD-MANAGER Event functions associations for Pool Objects

	methods (Static)

	function listenerEvents(cli)
	% Add listener on poold instance for events on Pool objects
            addlistener(cli, 'ClientAdd', ...
                @(src, evnt)clientd_manager.refresh(src));
    end
    
    function refresh(cli)
    end
    
    end
end