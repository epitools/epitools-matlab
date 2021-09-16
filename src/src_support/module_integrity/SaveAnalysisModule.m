function [status,analysis_struct] = SaveAnalysisModule(analysis_struct,strModuleName)
%SAVEANALYSISMODULE 
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function is is intended to check for the presence of the module in
% the setting file when the user is about to run any analysis module
% during the current session of the analysis.
%
% INPUT
%   1. analysis_struct:  analysis settings structure object
%   2. strModuleName:    module name to process
%
% OUTPUT
%   1. status:          status elaboration (0  executed correctly; > 0 fatal error)
%   2. analysis_struct: analysis settings structure modified accordingly 
%
% REFERENCES
%
% AUTHOR:   Lorenzo Gatti (lorenzo.gatti@alumni.ethz.ch)
%
% DATE:     8.12.14 V0.1 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.

% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
status = true;
%% Sandboxing
% Set the status of sandboxing (TODO: better patch)
% If any module has been called when sandbox is in use or if the 
% program has crashed before closing the sandbox, then reset in/out
% analysis dir and reset status sandbox
if analysis_struct.exec_sandboxinuse
    % -------------------------------------------------------------------------
    % Log status of previous operations
    log2dev('Found Sandbox environment OPEN even if the module was not invoked before!', 'WARN');
    log2dev('Resetting out analysis directory to original path', 'DEBUG');
    % -------------------------------------------------------------------------
    analysis_struct.data_analysisoutdir = analysis_struct.data_analysisindir;
    analysis_struct.exec_sandboxinuse = false;
end
%% Procedure
% If the module exists already, then sandoxing is required in order to proceed 
if(analysis_struct.hasModule(strModuleName))
    % Workround for multiple executions of tracking module
    if(strcmp(strModuleName,'Tracking'));return;end
    if(strcmp(strModuleName,'Contrast_Enhancement')); DiscardAnalysisModules(strModuleName, analysis_struct);return;end
    % When the module has been already executed during the course of the
    % current analysis, the program will ask to the user if he wants to
    % run a comparative analysis. If yes, then it runs everything in a
    % sandbox where the previous modules are stored until the user
    % decides if he wants to keep or discard them.
    out = questdlg(sprintf('The analysis module [%s] you are attempting to execute is already present in your analysis.\n\n How do you want to proceed?', strModuleName),...
        'Control workflow of analysis modules',...
        'Overrite module',...
        'Comparare executions',...
        'Abort operations',...
        'Abort operations');
    switch out
        case 'Overrite module'                  
            % -------------------------------------------------------------------------
            % Log status of previous operations
            log2dev('All further analysis results have been moved into Analysis_Directory_Path\Backups since they are invalid due to re-execution of the module', 'WARN');
            % -------------------------------------------------------------------------
            DiscardAnalysisModules(strModuleName, analysis_struct);
        case 'Comparare executions'
            % Connect a new pool and deactivate all the others
            pool_name       = strcat(analysis_struct.analysis_name,'_cmp_',datestr(now(),30));
            pool_instances  = getappdata(hMainGui, 'pool_instances');
            % Deactivate other active pools
            for idxPool = 2:numel(pool_instances); pool_instances(idxPool).ref.deactivatePool; end
            % Save into global variables
            setappdata(hMainGui, 'pool_instances', pool_instances);
            connectPool(pool_name);
            % Initilization sandbox for the current module
            sdb = sandbox();
            % Set the status of sandboxing (TODO: better patch)
            analysis_struct.exec_sandboxinuse = true; 
            setappdata(hMainGui, 'settings_objectname', analysis_struct); 
            SaveAnalysisFile(analysis_struct,'ForceSave', true);
            % Create the variables for the current module
            sdb.CreateSandbox(strModuleName,analysis_struct);
            % Re-run the module in a sandbox environment
            sdbExecStatus = sdb.Run(); 
        case 'Abort operations'
            status = false; return;
    end
end
% Redirected after exporting tag to pool 
%else
%    analysis_struct.CreateModule(strModuleName);
%    setappdata(hMainGui, 'settings_objectname', analysis_struct);
%end
end


