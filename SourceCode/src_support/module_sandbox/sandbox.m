classdef sandbox < handle
    %SANDBOX Sandox is an object class containing the specifics of a sandbox object
    % which is declared when a module of the analysis is run twice by the user. It
    % allows the execution to store specific parts of the analysis in a safe
    % environment where the analysis execution does not affect the already obtained
    % results.
    % LG(C)14
    
    properties (SetAccess = private)
        sandbox_status = 0;
    end
    
    properties
        
        module_name = '';
        analysis_settings = struct();
        analysis_tmpdirpath = '';
        results_validity = true;
        results_overrite = false;
        results_backup = false;
        backup_directory = '';
        backup_validity = false;
    end
    
    methods
        
        function sdb = sandbox()
            %  SANDBOX  sandbox initialises the	object sandbox setting its status
            %  to 1 (open)
            
            sdb.sandbox_status = 1;
            sdb.module_name = '';
            sdb.analysis_tmpdirpath = randChar(5,1, char(['a':'z' '0':'9']));
            sdb.analysis_settings = struct();
            sdb.results_validity = true;
            sdb.results_overrite = false;
            sdb.results_backup = false;
            sdb.backup_directory = strcat('backup_',randChar(5,1, char(['a':'z' '0':'9'])));
            sdb.backup_validity = false;
            
        end
        
        function boolean = CreateSandbox(sdb, mdname, mdsett)
            %  CREATESANDBOX CreateSandbox initialises the sandbox object for a
            % 	specific module of the current analysis. The user has to specify
            % 	the following parameters:
            %	mdname =  name of the module the user wants to re-run
            %	mdsett =  struct object containing the specifics of the
            %			  module
            
            boolean = true;
            
            while boolean
                if (nargin == 3)
                    
                    if (sdb.sandbox_status == 0);boolean=false;warning('Your sandbox has not been opened.');end
                    
                    if (isa(mdname, 'char') && isa(mdsett, 'settings'))
                        sdb.module_name = mdname;
                        sdb.analysis_settings = mdsett;
                        return;
                    else
                        %% trown matlab exception for class parameters not allowed
                        boolean = false;
                    end
                    
                else
                    %% trown matlab exception for number parameters below expectances
                    boolean = false;
                end
            end
            
        end
        
        function boolean = Run(sdb)
        %  RUN Run executes the module specified in the public variable
        %  module_name with settings contained in the public object module_settings
            
            boolean = true;
            
            while boolean
                
                if (sdb.sandbox_status == 0);boolean=false;warning('Your sandbox has not been opened.');end
                
                % If a module hame has been specified, then call the executor file
                if (~isempty(sdb.module_name) && ~isempty(sdb.analysis_settings))
                    	
                	% When a new sandbox is instantiated it will redirect the new results in a
                	% temporary directory.
                    if ((sdb.results_validity) && (~sdb.results_overrite))
                        
                        % Indicate an alternative directory to store the objects computed as 
                        % outputs from the analysis.
                        sdb.analysis_settings.data_analysisoutdir = [sdb.analysis_settings.data_fullpath,'/', sdb.analysis_tmpdirpath];

                        % Create the temporary directory where the files will be stored
                        mkdir([sdb.analysis_settings.data_fullpath,'/', sdb.analysis_tmpdirpath]);

                    end
                    
                    switch sdb.module_name
                        case 'Projection'
                            out = ProjectionGUI(sdb.analysis_settings);
                            waitfor(out);
                        case 'Stack_Registration'
                            out = RegistrationGUI(sdb.analysis_settings);
                            waitfor(out);
                        case 'Contrast_Enhancement'
                            out = ImproveContrastGUI(sdb.analysis_settings);
                            waitfor(out);
                        case 'Segmentation'
                            out = SegmentationGUI(sdb.analysis_settings);
                            waitfor(out);
                        case 'Tracking'
                            out = TrackingIntroGUI(sdb.analysis_settings);
                            waitfor(out);
                        otherwise
                            return;
                    end
                    
                    if (out); boolean = true;return;else boolean = false; end
                end
                
                
            end
        end
        
        function boolean = DestroySandbox(sdb)
            
           	boolean = true;
            % Evaluate boolean specifics in order to save/destroy/redirect files & directories.

            % Should I keep new execution results?
        	if(sdb.results_validity)
      			% The new results have to ovverite the old ones? 
        		if(sdb.results_overrite)
        			% Do I want to backup the old results?
	       			if(sdb.results_backup)
        			
        				% Create the backup directory where the files will be moved
	       				mkdir([sdb.analysis_settings.data_fullpath,'/', sdb.backup_directory]);
	       				% Copy files from the old analysis folder to the new one 
	       				copyfile(sdb.analysis_settings.data_analysisindir,...
	       					[sdb.analysis_settings.data_fullpath,'/', sdb.backup_directory]);

        			end
        			
        			% Delete all the files contained in the old analysis directory
	       			delete(strcat(sdb.analysis_settings.data_analysisindir,'/*'));

	       			% Copy the newly-generated result files into the analysis folder
	       			copyfile([sdb.analysis_settings.data_fullpath,'/', sdb.analysis_tmpdirpath],...
	       			 sdb.analysis_settings.data_analysisindir);

	       			% Remove temporary directory
	       			rmdir([sdb.analysis_settings.data_fullpath,'/', sdb.analysis_tmpdirpath], 's');
                    
                    % Reassign correct location to results saved during the
                    % module execution
                    
                    arrayResults = fields(sdb.analysis_settings.analysis_modules.(char(sdb.module_name)).results);
                    
                    for i=1:numel(arrayResults)
                    
                        arrayPathSegments = strsplit(sdb.analysis_settings.analysis_modules.(char(sdb.module_name)).results.(char(arrayResults(i))),'/');
                        originalPathSegment = strsplit(sdb.analysis_settings.data_analysisindir,'/');
                        sdb.analysis_settings.analysis_modules.(char(sdb.module_name)).results.(char(arrayResults(i))) = strjoin([arrayPathSegments(1:end-2),originalPathSegment(end),arrayPathSegments(end)],'/');
                    
                    end
                    

        		% In case the new results are not going to ovverite the previous results
        		else

        			% IMPLEMENTATION IS DUE HERE
        		end
        	
        	% I discard the second-run-generated results
        	else
        		% Remove temporary directory
	       		rmdir([sdb.analysis_settings.data_fullpath,'/', sdb.analysis_tmpdirpath],'s');

        	end
    	
        end

    end
end
