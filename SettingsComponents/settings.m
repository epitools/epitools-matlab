classdef settings < handle
    %TEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        analysis_code = '';
        analysis_name = 'Untitled';
        user_name = getenv('USER');
        user_department = 'Not specified';
        platform_id = '';
        platform_units = 1;
        platform_desc = system_dependent('getos') ;
        analysis_version = 0;
        analysis_date = date();
        analysis_modules = struct();
        data_fullpath = '~';
        data_imagepath = '~';
        data_analysisdir = '/Analysis';
        data_benchmarkdir = '/Benchmark';
        data_extensionmask = '.etl';
    end
    
    methods
        
        function obj = settings(analysis_name, analysis_version, data_fullpath)
            
            if (nargin == 3) 
                
                  obj.analysis_name = analysis_name;
                  obj.analysis_version = analysis_version;
                  obj.data_fullpath = data_fullpath;
                
            end

            
            % Get the mac address of the machine running the analysis and
            % format it in the right way [00:00:00:00:00:00]
            ni = java.net.NetworkInterface.getNetworkInterfaces;
            addr = abs(ni.nextElement.getHardwareAddress);
            addr_allOneString = sprintf('%.0f:' , addr);
            addr_allOneString = addr_allOneString(1:end-1);% strip final comma
            
            % Valorize settings fields
            obj.analysis_code = strcat(num2str(floor(now())),'.',num2str(round(rand(1)*100)));   
            obj.platform_id = addr_allOneString;
            
        end      
        
        
        function LoadModule(obj,mdname, sourceobj)
        % Load setting module parsing a configuration file
            
            % TODO: warnings for data overwriting
            obj.analysis_modules.(mdname).settings  = sourceobj.analysis_modules.(mdname).settings;
            obj.analysis_modules.(mdname).metadata  = sourceobj.analysis_modules.(mdname).metadata;
            obj.analysis_modules.(mdname).results   = sourceobj.analysis_modules.(mdname).results;
        
        end
        
        
        function CreateModule(obj,mdname)
        % Create a setting module to add to the configuration file
            
            obj.analysis_modules.(mdname) = struct();
            obj.analysis_modules.(mdname).metadata = struct();
            obj.analysis_modules.(mdname).settings = struct();
            obj.analysis_modules.(mdname).results = struct();
            
        end
        
        
        function DestroyModule(obj,mdname)
        % Destroy a setting module * remove all the parameters, settings, metadata associated
            
            obj.analysis_modules = rmfield(obj.analysis_modules,mdname);
            
        end
        

        function AddSetting(obj,mdname, arg, value)
        % Add setting parameter to a certain module * the module has to be
        % already initialized.
            obj.analysis_modules.(mdname).settings.(arg) = value; 
        end
        
        function RemoveSetting(obj,mdname, arg)
        % Remove setting parameter to a certain module * the module has to be
        % already initialized.
            
            obj.analysis_modules.(mdname).settings = rmfield(obj.analysis_modules.(mdname).settings,arg);

        end
        
        function ModifySetting(obj,mdname, arg,value)
        % Modify setting parameter value in a certain module * the module has to be
        % already initialized.
        
            obj.analysis_modules.(mdname).settings.(arg) = value; 

        end
        
        function [status] = SaveToFile(obj, type)
        
            switch type
                case 'bin'
                    save(strcat(obj.analysis_name,'.etl'),obj);
                
                case 'open'
                    save(strcat(obj.analysis_name,'.etl'),obj);
                
                otherwise
                    error('An error occurred during setting file saving. No file type specified');
                    status = 1;
                    return
            end
            
            
            status = 0;
                    
        end
        
        
       
    end
    
end