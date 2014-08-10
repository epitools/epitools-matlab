classdef sandbox < handle
%SANDBOX Sandox is an object class containing the specifics of a sandbox object 
% which is declared when a module of the analysis is run twice by the user. It 
% allows the execution to store specific parts of the analysis in a safe 
% environment where the analysis execution does not affect the already obtained
% results.
% LG(C)14
    
    properties
    	private sandbox_status = 0;
    	module_name = '';
    	analysis_settings = struct();
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
    		
    		sandbox_status = 1;
    		module_name = '';
    		analysis_settings = struct();
    		results_validity = true;
    		results_overrite = false;
    		results_backup = false;
    		backup_directory = '';
    		backup_validity = false;

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
    			if (nargin == 2)
    			
    				if (sdb.sandbox_status == 0);error('Your sandbox has not been opened.');boolean=false; end

    				if (isa(mdname, 'string') && isa(mdsett, 'settings'))
    					sdb.module_name = mdname;
    					sdb.module_settings = mdsett;
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

    	function [boolean,tmp_settings] = Run(sdb)
    	%  RUN Run executes the module specified in the public variable 
    	%  module_name with settings contained in the public object module_settings

    		boolean = true;
    		
    		while boolean
    		
    		if (sdb.sandbox_status == 0);error('Your sandbox has not been opened.');boolean=false; end

    		% If a module hame has been specified, then call the executor file
    		if (sdb.module_name && sdb.module_settings)

    			if ((results_validity) && (~results_overrite))
    				
    				stg.data_analysisdir = [stgObj.data_fullpath, '/tmp_analysis'];

    				mkdir([stgObj.data_fullpath, '/tmp_analysis']);
    				% copy all files from old analysis dir into the new one. 
    			end 


    			switch sdb.module_name
    				case 'Projection'
    					out = ProjectionGUI(stgObj);
    				case 'Stack_Registration'
    					out = RegistrationGUI(stgObj);
    				case 'Contrast_Enhancement'
    					out = ImproveContrastGUI(stgObj);
    				case 'Segmentation'
    					out = SegmentationGUI(stgObj);
    				case 'Tracking'
    					out = TrackingIntroGUI(stgObj);
    				otherwise
    					return;
    			end

    		end


    	end 

    	function boolean = DestroySandbox(sdb, )




    	end

    end

    