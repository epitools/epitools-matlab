classdef poold_manager
	%POOLD-MANAGER Event functions associations for Pool Objects

	methods (Static)

	function listenerEvents(pool)
	% Add listener on poold instance for events on Pool objects
            addlistener(pool, 'AddedTag', ...
                @(src, evnt)poold_manager.refreshLinks(src));
            addlistener(pool, 'RemovedTag', ...
                @(src, evnt)poold_manager.refreshLinks(src));
            addlistener(pool, 'PoolModified', ...
                @(src, evnt)poold_manager.updatePool(src));

	end

	function refreshLinks(pool)
    % Refresh association between avail tag list and pool xml file
    end
    % --------------------------------------------------------------------
    %% Standalone functions (GUI Related)
    function updatePool(pool)
         if ~isempty(pool.handleJTreeTable)
                pool.buildGUInterface;
         end
    end
    % --------------------------------------------------------------------
    end 
end