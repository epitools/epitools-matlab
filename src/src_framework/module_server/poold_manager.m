classdef poold_manager
	%POOLD-MANAGER Event functions associations for Pool Objects

	methods (Static)

	function listenerEvents(pool)
	% Add listener on poold instance for events on Pool objects
            addlistener(sd, 'AddedTag', ...
                @(src, evnt)poold_manager.refreshLinks(src));
            addlistener(sd, 'RemovedTag', ...
                @(src, evnt)poold_manager.refreshLinks(src));
	end

	function refreshLinks(pool)
		% Refresh association between avail tag list and pool xml file

         


	end

    end
end