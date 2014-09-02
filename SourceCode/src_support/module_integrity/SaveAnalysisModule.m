function [argout,stgObj] = SaveAnalysisModule(hObject, handles, strModuleName)
% Global_SaveModule is intended to check for the presence of the module in
% the setting file when a the user is about to run any analysis module
% during the current session of the analysis.
hMainGui = getappdata(0, 'hMainGui');

argout = true;

if(isappdata(hMainGui,'settings_objectname'))
    if(isa(getappdata(hMainGui,'settings_objectname'),'settings'))
        
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        % Set the status of sandboxing (TODO: better patch)
        % If any module has been called when sandbox is in use or if the 
        % program has crashed before closing the sandbox, then reset in/out
        % analysis dir and reset status sandbox
        
        if(stgObj.exec_sandboxinuse == true)
            
            % -------------------------------------------------------------------------
            % Log status of previous operations
            log2dev('Found Sandbox environment OPEN even if the module was not invoked before!', 'WARN');
            log2dev('Resetting out analysis directory to original path', 'DEBUG');
            % -------------------------------------------------------------------------
            
            stgObj.data_analysisoutdir = stgObj.data_analysisindir;
            stgObj.exec_sandboxinuse = false;
        
        end
        
        
        if(sum(strcmp(fields(stgObj.analysis_modules), strModuleName)) == 1)
            
            % Workround for multiple executions of tracking module
            if(strcmp(strModuleName,'Tracking'));return;end
            if(strcmp(strModuleName,'Contrast_Enhancement')); DiscardAnalysisModules(strModuleName, stgObj);return;end
            
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

                    DiscardAnalysisModules(strModuleName, stgObj);
                    
                case 'Comparare executions'
                    
                    % Initilization sandbox for the current module
                    sdb = sandbox();
                    
                    % Set the status of sandboxing (TODO: better patch)
                    stgObj.exec_sandboxinuse = true;
                    setappdata(hMainGui, 'settings_objectname', stgObj);
                    
                    
                    % Create the variables for the current module
                    sdb.CreateSandbox(strModuleName,stgObj);
                    
                    % Re-run the module in a sandbox environment
                    sdbExecStatus = sdb.Run();
                    
                    waitfor(sdbExecStatus)
                    
                    SandboxGUIRedesign(1);
                     
                    if (sdbExecStatus)
                        % Ask what to do with the results

                        
                        if(~isempty(getappdata(hMainGui, 'uidiag_userchoice')))
                            
                            switch getappdata(hMainGui, 'uidiag_userchoice')
                                case 'Discard result'
                                    % Discard new results implies:
                                    %   [1] Destroy the temporary directory where the
                                    %       results have been stored
                                    
                                    sdb.results_validity = false;
                                    sdb.results_overrite = false;
                                    
                                    
                                case 'Accept result'
                                    % Accept new results implies:
                                    %   [1] Backup previous results in a new folder
                                    %   [2] Remove all files contained in the analysis
                                    %       folder
                                    %   [3] Move all the result files from the temp dir
                                    %       to analysis folder
                                    %   [4] Destroy temporary results folder
                                    
                                    sdb.results_validity = true;
                                    sdb.results_overrite = true;
                                    sdb.results_backup = true;
                                    
                                otherwise
                                    % Restore the previous situation considering saving
                                    % all the new results obtained * this might happen if
                                    % the user accidentally ask for an illegittimate
                                    % operation (needed for compiling standalone apps)
                                    %   [1] Backup previous results in a new folder
                                    %   [2] Remove all files contained in the analysis
                                    %       folder
                                    %   [3] Move all the result files from the temp dir
                                    %       to analysis folder
                                    %   [4] Destroy temporary results folder
                                    
                                    sdb.results_validity = true;
                                    sdb.results_overrite = false;
                                    sdb.results_backup = false;
                            end
                            
                            sdbExecStatus = sdb.DestroySandbox();
                            
                            % Set the status of sandboxing (TODO: better patch)
                            stgObj.exec_sandboxinuse = false;
                            setappdata(hMainGui, 'settings_objectname', stgObj);
                            
                            waitfor(sdbExecStatus);
                            % Destroy modules downstream the current module
                            if(sdb.results_validity)
                                %msgbox('All further analysis results have been moved into Analysis_Directory_Path\Backups since they are invalid due to re-execution of the module ');
                                 sdbExecStatus2 = DiscardAnalysisModules( strModuleName, stgObj );
                                 waitfor(sdbExecStatus2);
                            end
                            
                            
                            SandboxGUIRedesign(0);
                            
                            % Workaround to be patched asap!
                            stgObj.data_analysisoutdir = stgObj.data_analysisindir;
                            setappdata(hMainGui, 'settings_objectname', stgObj);
                            
                            argout = false;
                            
                        end
                    end
                case 'Abort operations'
                    argout = false;
                    return;
            end
            
        else
            
            stgObj.CreateModule(strModuleName);
            setappdata(hMainGui, 'settings_objectname', stgObj);
            
        end
    end
    
end


