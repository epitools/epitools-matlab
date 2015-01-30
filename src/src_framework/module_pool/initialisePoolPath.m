function initialisePoolPath(obj)
%INITIALISEPOOLPATH This function check the integrity of pool path when user 
% calls a module
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function checks if the default pool is active when a module is called and is going to be
% executed during the current session. In case it does not find any default pool open, it asks the
% user to decide for activate or continue without any pool status variations.
%
% REFERENCES
%
% AUTHOR:   Lorenzo Gatti (lorenzo.gatti@alumni.ethz.ch)
%
% DATE:     27.01.15 V0.1 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.

% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
% Supress function in case of legitimate comparative mode
if ~strcmp(obj.data_analysisindir,obj.data_analysisoutdir);return;end
% Check if the active pool is default 
pool_instances  = getappdata(getappdata(0,'hMainGui'), 'pool_instances');
for idxPool = 2:numel(pool_instances); 
    if ~isempty(regexpi(pool_instances(idxPool).ref.name,'_default'))
        % Check if the default pool is active
        if ~pool_instances(idxPool).ref.active
            answer = questdlg({'It seems that the [Default] pool is not active and this is probably due to previous comparative analyses.',...
                                'Do you want to switch to the [Default] pool now?'},...
                                '[WARN] Default pool not ready to receive tags');
            drawnow; pause(0.05);                     
            switch answer
                case 'Yes'
                    % Activate pool
                    pool_instances(idxPool).ref.activatePool
                case 'No'
                    break;
                otherwise
                    return;
            end
        end
    else
        % Deactivate other active pools
        pool_instances(idxPool).ref.deactivatePool; 
    end               
end

end

