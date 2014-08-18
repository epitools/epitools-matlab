classdef settings < handle
    %SETTINGS Settings class defines the properties for a new object of class
    % settings. This object contains the specifics for running an analysis on 
    % EPITOOLS (both gui and no-gui version). This class allows for multiple 
    % object initialisations. 
    
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
        data_analysisindir = '';
        data_analysisoutdir = '';
        data_benchmarkdir = '';
        data_extensionmask = '.xml';
        icy_is_used = 0;
        exec_commandline = false;
    end
    
    methods
        
        function obj = settings(analysis_name, analysis_version, data_fullpath)
        % SETTINGS Setting function initialise the setting object. User should 
        % call the function defining the following variables:
        % string analysis_name  = this variable contains a string with the 
        %                         analysis name
        % int analysis_version  = a progressive number definining the analysis 
        %                         version
        % string data_fullpath  = string containing the full path where the 
        %                         analysis file will be stored
            
            % Who am I?
            [ST,~] = dbstack();
            
            % Convert the object passed into a settings object
            if (nargin == 1)

                objName = analysis_name;
                
                if (isa(objName, 'struct'))

                    % Parsing all the struct fields
                    field_object = fields(objName);
                    
                    % Set the values of the setting object fields with the 
                    % values/ref of the non-setting object.
                    for i=1:numel(field_object)
                        idx = field_object(i);
                        obj.(char(idx)) = objName.(char(idx));
                        
                    end

                    
                else
                    % if the object parsed cannot be read and converted
                    warning([ST 'could not convert the object', objName,'into a settings object']);
                    
                end
            
            return
            end
            
            
            % In case this function has been called with all the parameters 
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
            obj.icy_is_used = 0;
            obj.exec_commandline = false;
            
        end      
        
        
        function LoadModule(obj,mdname, sourceobj)
        % LOADMODULE LoadModule tranfers setting/metadata/results fields from % a module to another module.
            
            % TODO: warnings for data overwriting
            obj.analysis_modules.(mdname).settings  = sourceobj.analysis_modules.(mdname).settings;
            obj.analysis_modules.(mdname).metadata  = sourceobj.analysis_modules.(mdname).metadata;
            obj.analysis_modules.(mdname).results   = sourceobj.analysis_modules.(mdname).results;
        
        end
        
        function boolean = hasModule(obj,mdname)
        % HASMODULE hasModule outputs true if mdname module is present
            boolean = logical(sum(strcmp(fields(obj.analysis_modules), mdname)) == 1);
            
        end
        
        
        function CreateModule(obj,mdname)
        % Create a setting module to add to the configuration file
            
            if (strcmp(mdname, 'Main') == 1)
               
                obj.analysis_modules.(mdname) = struct();
            
            else
                obj.analysis_modules.(mdname) = struct();
                obj.analysis_modules.(mdname).metadata = struct();
                obj.analysis_modules.(mdname).settings = struct();
                obj.analysis_modules.(mdname).results = struct();
            end
            
        end
        
        
        function DestroyModule(obj,mdname)
        % Destroy a setting module * remove all the parameters, settings, metadata associated
            
            obj.analysis_modules = rmfield(obj.analysis_modules,mdname);
            
        end
        

        function AddSetting(obj,mdname, arg, value)
        % Add setting parameter to a certain module * the module has to be
        % already initialized.
            if (strcmp(mdname, 'Main') == 1)
               
                obj.analysis_modules.(mdname).(arg) = value; 
            
            else
                
                obj.analysis_modules.(mdname).settings.(arg) = value; 
                
            end
        end
        
        function RemoveSetting(obj,mdname, arg)
        % Remove setting parameter to a certain module * the module has to be
        % already initialized.
        
            if (strcmp(mdname, 'Main') == 1)
               
                obj.analysis_modules.(mdname) = rmfield(obj.analysis_modules.(mdname),arg);
            
            else
                
                obj.analysis_modules.(mdname).settings = rmfield(obj.analysis_modules.(mdname).settings,arg);
                
            end
        
        end
        
        function ModifySetting(obj,mdname, arg,value)
        % Modify setting parameter value in a certain module * the module has to be
        % already initialized.
           
            if (strcmp(mdname, 'Main') == 1)
               
                obj.analysis_modules.(mdname).(arg) = value; 
            
            else
                
                obj.analysis_modules.(mdname).settings.(arg) = value; 
                
            end
            

        end
        
        function AddResult(obj,mdname, arg, value)
        % Add setting parameter to a certain module * the module has to be
        % already initialized.

                
                obj.analysis_modules.(mdname).results.(arg) = value; 

        end
        
        function RemoveResult(obj,mdname, arg)
        % Remove setting parameter to a certain module * the module has to be
        % already initialized.

                obj.analysis_modules.(mdname).results = rmfield(obj.analysis_modules.(mdname).results,arg);
        
        end
        
        function ModifyResult(obj,mdname, arg,value)
        % Modify setting parameter value in a certain module * the module has to be
        % already initialized.
                
                obj.analysis_modules.(mdname).results.(arg) = value; 

        end

    end
    
end