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
        exec_sandboxinuse = false;
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
            obj.exec_sandboxinuse = false;
            
        end      
        % --------------------------------------------------------------------
        function LoadModule(obj,mdname, sourceobj)
        % LOADMODULE LoadModule tranfers setting/metadata/results fields from % a module to another module.
            
            % TODO: warnings for data overwriting
            obj.analysis_modules.(mdname).settings  = sourceobj.analysis_modules.(mdname).settings;
            obj.analysis_modules.(mdname).metadata  = sourceobj.analysis_modules.(mdname).metadata;
            obj.analysis_modules.(mdname).results   = sourceobj.analysis_modules.(mdname).results;
        
        end
        % --------------------------------------------------------------------
        function boolean = hasModule(obj,mdname)
        % HASMODULE hasModule outputs true if mdname module is present
            boolean = logical(sum(strcmp(fields(obj.analysis_modules), mdname)) == 1);
            
        end
        % --------------------------------------------------------------------
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
        % --------------------------------------------------------------------
        function DestroyModule(obj,mdname)
        % Destroy a setting module * remove all the parameters, settings, metadata associated
            
            obj.analysis_modules = rmfield(obj.analysis_modules,mdname);
            
        end
        % --------------------------------------------------------------------
        function AddSetting(obj,mdname, arg, value)
        % Add setting parameter to a certain module * the module has to be
        % already initialized.
            if (strcmp(mdname, 'Main') == 1)
               
                obj.analysis_modules.(mdname).(arg) = value; 
            
            else
                
                obj.analysis_modules.(mdname).settings.(arg) = value; 
                
            end
        end
        % --------------------------------------------------------------------
        function RemoveSetting(obj,mdname, arg)
        % Remove setting parameter to a certain module * the module has to be
        % already initialized.
        
            if (strcmp(mdname, 'Main') == 1)
               
                obj.analysis_modules.(mdname) = rmfield(obj.analysis_modules.(mdname),arg);
            
            else
                
                obj.analysis_modules.(mdname).settings = rmfield(obj.analysis_modules.(mdname).settings,arg);
                
            end
        
        end
        % --------------------------------------------------------------------
        function ModifySetting(obj,mdname, arg,value)
        % Modify setting parameter value in a certain module * the module has to be
        % already initialized.
           
            if (strcmp(mdname, 'Main') == 1)
               
                obj.analysis_modules.(mdname).(arg) = value; 
            
            else
                
                obj.analysis_modules.(mdname).settings.(arg) = value; 
                
            end
            

        end
        % --------------------------------------------------------------------
        function AddResult(obj,mdname, arg, value)
        % Add setting parameter to a certain module * the module has to be
        % already initialized.

                
                obj.analysis_modules.(mdname).results.(arg) = value; 

        end
        % --------------------------------------------------------------------
        function RemoveResult(obj,mdname, arg)
        % Remove setting parameter to a certain module * the module has to be
        % already initialized.

                obj.analysis_modules.(mdname).results = rmfield(obj.analysis_modules.(mdname).results,arg);
        
        end
        % --------------------------------------------------------------------
        function ModifyResult(obj,mdname, arg,value)
        % Modify setting parameter value in a certain module * the module has to be
        % already initialized.
                
                obj.analysis_modules.(mdname).results.(arg) = value; 

        end
        % --------------------------------------------------------------------
        function AddMetadata(obj,mdname, arg, value)
        % Add setting parameter to a certain module * the module has to be
        % already initialized.

                
                obj.analysis_modules.(mdname).metadata.(arg) = value; 

        end
        % --------------------------------------------------------------------
        function RemoveMetadata(obj,mdname, arg)
        % Remove setting parameter to a certain module * the module has to be
        % already initialized.

                obj.analysis_modules.(mdname).metadata = rmfield(obj.analysis_modules.(mdname).metadata,arg);
        
        end
        % --------------------------------------------------------------------
        function ModifyMetadata(obj,mdname, arg,value)
        % Modify setting parameter value in a certain module * the module has to be
        % already initialized.
                
                obj.analysis_modules.(mdname).metadata.(arg) = value; 

        end
        % --------------------------------------------------------------------
        function GenerateXMLFile(obj)
            % Initialize an empty structure
            tmp = struct();
            % Parse the setting object associated with the current session
            tmp = struct(obj);
            % Conversion cell arrays to structure objects
            intNumRows = size(obj.analysis_modules.Main.data,1);
            fieldsFile = {  'name';
                            'dim_x';
                            'dim_y';
                            'dim_z';
                            'num_channels';
                            'num_timepoints';
                            'pixel_type';
                            'exec';
                            'exec_dim_z';
                            'exec_channels';
                            'exec_num_timepoints';};
            tmpFileStruct = struct();
            for r=1:intNumRows
                tmpFileStruct.(strcat('file',num2str(r))) =  cell2struct(obj.analysis_modules.Main.data(r,:)',fieldsFile);
            end
            % Append to temporary structure
            tmp.analysis_modules.Main.data = tmpFileStruct;
            if(sum(strcmp(fields(obj.analysis_modules.Main), 'indices')) == 1)
                tmp.main.analysis_modules.Main = rmfield(tmp.main.analysis_modules.Main,'indices');
            end
            Pref.StructItem = false;
            xml_write(strcat(obj.data_fullpath,'/',obj.analysis_name,'.',num2str(obj.analysis_version),'.xml'), tmp, 'main', Pref);
            % Writing to xml file
            %struct2xml(tmp, strcat(obj.data_fullpath,'/',obj.analysis_name,'.',num2str(obj.analysis_version),'.xml'));

        end
        % --------------------------------------------------------------------
        function discardDownstreamModules(obj, mdname)
            % Get the module names
            arrayStgFields = fields(obj.analysis_modules);
            % Find position on the modules array of the current module
            intIDX = find(strcmp(arrayStgFields, mdname));
            % Delete all the downstream modules 
            for i=(intIDX+1):length(arrayStgFields)
                if (isempty(obj.analysis_modules.(char(arrayStgFields(i))).results));continue;end
                % Move results into backup folder
                arrayResults = fields(obj.analysis_modules.(char(arrayStgFields(i))).results);
                for o=1:numel(arrayResults) 
                    if(strcmp(arrayResults,'tracking_file_path'));continue;end
                    % File name
                    strSourceFileName = obj.analysis_modules.(char(arrayStgFields(i))).results.(char(arrayResults(o)));
                    % File location 
                    strSourceFilePath = obj.data_analysisoutdir;
                    % Check existance backup directory
                    if(~exist([strSourceFilePath,'/Backups'],'dir')); mkdir([strSourceFilePath,'/Backups']); end
                    % subdirectories to be reconstructed
                    if(strcmp(char(arrayStgFields(i)), 'Skeletons'))
                        if(~exist([strSourceFilePath,'/Backups/skeletons'],'dir'))
                            mkdir([strSourceFilePath,'/Backups/skeletons']);
                        end
                    end
                    % Copy file  [strSourceFilePath,'/',strSourceFileName]
                    if(exist([strSourceFilePath,'/',strSourceFileName],'file')==2)
                        copyfile([strSourceFilePath,'/',strSourceFileName], [strSourceFilePath,'/Backups/',strSourceFileName]);
                    else
                        continue;
                    end
                    % Remove file
                    delete([strSourceFilePath,'/',strSourceFileName]);
                end
                % Destroy module
                obj.DestroyModule(arrayStgFields(i));
            end
        end
        % --------------------------------------------------------------------
        function argout = initialiseModule(obj,mdname)
            argout = true;
            %% Sandboxing checking
            % Set the status of sandboxing (TODO: better patch)
            % If any module has been called when sandbox is in use or if the 
            % program has crashed before closing the sandbox, then reset in/out
            % analysis dir and reset status sandbox
            if obj.exec_sandboxinuse
                % -------------------------------------------------------------------------
                % Log status of previous operations
                log2dev('Found Sandbox environment OPEN even if the module was not invoked before!', 'WARN');
                log2dev('Resetting out analysis directory to original path', 'DEBUG');
                % -------------------------------------------------------------------------
                obj.data_analysisoutdir = obj.data_analysisindir;
                obj.exec_sandboxinuse = false;
            end
            %% Procedure 
            % If the module exists already, then sandoxing is required in order to proceed 
            if(obj.hasModule(mdname))
                % Workround for multiple executions of tracking module
                if(strcmp(mdname,'Indexing'));argout = false;return;end
                % Workround for multiple executions of tracking module
                if(strcmp(mdname,'Tracking'));return;end
                %if(strcmp(mdname,'Contrast_Enhancement')); obj.discardDownstreamModules(mdname);return;end
                % When the module has been already executed during the course of the
                % current analysis, the program will ask to the user if he wants to
                % run a comparative analysis. If yes, then it runs everything in a
                % sandbox where the previous modules are stored until the user
                % decides if he wants to keep or discard them.
                out = questdlg(sprintf( 'The analysis module [%s] you are attempting to execute is already present in your analysis.\n\n How do you want to proceed?', mdname),...
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
                        %obj.discardDownstreamModules(mdname);
                    case 'Comparare executions'
                        % Connect a new pool and deactivate all the others
                        pool_name       = strcat(obj.analysis_name,'_cmp_',datestr(now(),30));
                        pool_instances  = getappdata(getappdata(0,'hMainGui'), 'pool_instances');
                        client_modules  = getappdata(getappdata(0,'hMainGui'), 'client_modules');
                        clients         = client_modules(2).ref;
                        % Deactivate other active pools
                        for idxPool = 2:numel(pool_instances); pool_instances(idxPool).ref.deactivatePool; end
                        % Save into global variables
                        setappdata(getappdata(0,'hMainGui'), 'pool_instances', pool_instances);
                        connectPool(pool_name);
                        % copy module dependency tags into new pool (from
                        % default pool to new pool)
                        curClient = clients(strcmp({clients.uid},mdname));
                        defPool = pool_instances(2).ref;
                        [ dependences, status, ~ ] = serverd_checkdependenceslist(curClient,defPool,defPool);
                        availableDependences = dependences(status.*1:numel(dependences));
                        for i = 1:numel(availableDependences)
                            defPool.copyTag(availableDependences(i),pool_name, 'ClassFrom', 'graphics', 'ClassTo', 'data');
                        end
                        % Copy extra tags for specific modules
                        if strcmp(mdname,'Segmentation')
                            if defPool.existsTag('CLAHE_IMAGE')
                                defPool.copyTag('CLAHE_IMAGE', pool_name);
                            end
                        end
                        % Initilization sandbox for the current module
                        sdb = sandbox();
                        % Set the status of sandboxing (TODO: better patch)
                        obj.exec_sandboxinuse = true; 
                        % Create the variables for the current module
                        sdb.setSandBox(mdname,obj);
                        % Retrieve sandbox variations to settings file and
                        % rewrite it
                        sdb.getSandbox()
                        obj.inheritSettings(sdb.analysis_settings); 
                        % Settings file will returned with variations to
                        % calling environment
                    case 'Abort operations'
                        argout = false;
                        return;
                end
            else
                % if no modules match mdname, then create a new one. 
                obj.CreateModule(mdname);
            end
        end
        % --------------------------------------------------------------------
        function inheritSettings(obj,source)
            strFields = fieldnames(source);
            for i = 1:numel(strFields);obj.(char(strFields(i))) = source.(char(strFields(i)));end
        end
        % --------------------------------------------------------------------
        function importModule(obj,source,mdname)
            strFields = fieldnames(source.analysis_modules.(mdname));
            % Legacy compatibility
            for i = 1:numel(strFields);obj.analysis_modules.(mdname).(char(strFields(i))) = source.analysis_modules.(mdname).(char(strFields(i)));end
        end
        % --------------------------------------------------------------------
        function refreshTree(obj,hfig)
            uihandles_deletecontrols('uitree');
            % Load JTREE Class
            jtree = uitree_control(hfig,obj);
            uihandles_savecontrols('uitree', jtree );
            % Load Contextual menu on JTREE class
            uitree_contextualmenu(jtree);
            % Create server/pool container panel 
            if ~uihandles_exists('uisidebarpanel')
                uisidebarpanel = uipanel('Parent', getappdata(0,'hMainGui'),...
                        'Position',[0.0 0.00 0.17 0.325],...
                        'Units', 'normalized');
                uihandles_savecontrols( 'uisidebarpanel', uisidebarpanel);
            end
            if ~uihandles_exists('uipanel_serverqueue')
                uipanel_serverqueue = uipanel('Parent', uisidebarpanel,...
                                              'Position',[0.0 0.0 1 0.40],...
                                              'Units', 'normalized');
                uihandles_savecontrols( 'uipanel_serverqueue', uipanel_serverqueue );
            end
            if ~uihandles_exists('uipanel_serverpool')
                uipanel_serverpool = uipanel('Parent', uisidebarpanel,...
                                              'Position',[0.0 0.40 1 0.59],...
                                              'Units', 'normalized');
                uihandles_savecontrols('uipanel_serverpool', uipanel_serverpool );
            end
        end
        % --------------------------------------------------------------------
        function createPackage(obj)
            try 
                % Load pool file
                listing = dir([obj.data_fullpath,'/pools/']);
                ind = ~cellfun(@isempty, regexp({listing.name}, '.xml'));                   
                x = xml_read([obj.data_fullpath,'/pools/',listing(ind).name]);
                % Get modules
                modules = fields(obj.analysis_modules);
                for i = 3:numel(modules)
                    results = fields(obj.analysis_modules.(char(modules(i))).results);
                    minv = 0; maxv=numel(results);
                    log2dev('Creating analysis package...please wait','INFO',0,'hMainGui', 'statusbar',{minv,maxv,0});
                    for o = 1:numel(results)
                        try
                            log2dev('Creating analysis package...please wait','INFO',0,'hMainGui', 'statusbar',{minv,maxv,o});
                            % Move physical files to the Analysis
                            % directory and its subdirectories
                            a = regexp(obj.analysis_modules.(char(modules(i))).results.(char(results(o))),'/', 'split');
                            
                            % If the folder of origin is tmp or Analysis,
                            % then move everything to Analysis folder, else move to a subdirectory under Analysis 
                            if ~isempty(regexp(a{end-1},'tmp_','ONCE')) || ~isempty(regexp(a{end-1},'Analysis', 'ONCE'))
                                
                                file.original_path = obj.analysis_modules.(char(modules(i))).results.(char(results(o)));
                                file.new_path = obj.data_analysisindir;
                                
                                copyfile(file.original_path,file.new_path);
                                
                            else
                                
                                file.original_path = obj.analysis_modules.(char(modules(i))).results.(char(results(o)));
                                file.new_path = [obj.data_analysisindir,'/',a{end-1},'/'];
                                
                                copyfile(file.original_path,file.new_path);

                            end

                            log2dev(sprintf('EPITOOLS:SettingsClass:createPackage:CopyFile | moved %s --> %s',...
                            file.original_path,...
                            file.new_path),...
                            'DEBUG');
                            
                            % Change path in pool file:
                            % Find all tags associated with the current module 
                            idx_tags = find(strcmp({x.tag.module},char(modules(i))));
                            for u = idx_tags                      
                               
                                % Check for special (as skeleton/vtk) folders [FIRST CASE is for not-nested folders]
                                if ~isempty(regexp(a{end-1},'tmp_','ONCE')) || ~isempty(regexp(a{end-1},'Analysis', 'ONCE'))
                                   
                                    % Select the tag associated with the result matching the path stored in
                                    % both tag attribute and setting result field.
                                    
                                    items_pool = regexp({x.tag(u).attributes.attribute.path},'/','split');
                                    items_settings = regexp(obj.analysis_modules.(char(modules(i))).results.(char(results(o))),'/','split');
                                    
                                    status = 0;
                                    for id = 1:numel(items_pool) 
                                        
                                        singleton = items_pool(id);
                                        check = sum(strcmp(singleton{end}, items_settings{end}));
                                       
                                        if check > 0
                                            pid = id;
                                            status = status + check;
                                            
                                        end
                                    end
                                    
                                    %pid = strcmp(items_pool{end},items_settings{end});
                                    % if the pid does not find a match, then move to the next tag
                                    if status > 0
                                    
                                        % Change path in pool file
                                        tag.original_path = x.tag(u).attributes.attribute(pid).path;
                                        tag.new_path = [obj.data_analysisindir,'/',a{end}];

                                        x.tag(u).attributes.attribute(pid).path = tag.new_path;

                                        % Change path in analysis file
                                        settings.original_path = obj.analysis_modules.(char(modules(i))).results.(char(results(o)));
                                        settings.new_path = [obj.data_analysisindir,'/',a{end}];

                                        obj.analysis_modules.(char(modules(i))).results.(char(results(o))) = settings.new_path;
                                    else
                                        continue;
                                    end
                                    
                                else % [SECOND CASE is for nested folders]
                                                                       
                                    status = 0;
                                    items = regexp({x.tag(u).attributes.attribute.path},'/','split');
                                    for id = 1:numel(items) 
                                        
                                        singleton = items(id);
                                        check = sum(~cellfun(@isempty, regexp(singleton{:}, a{end-1},'match')));
                                        
                                        if check > 0
                                            pid = id;
                                            status = status + check;
                                            
                                        end
                                    end
                                    
                                    if(status>0)
                                       
                                        % Change path in pool file
                                        tag.original_path = x.tag(u).attributes.attribute(pid).path;
                                        tag.new_path = [obj.data_analysisindir,'/',a{end-1},'/'];

                                        x.tag(u).attributes.attribute(pid).path = tag.new_path;

                                        % Change path in analysis file
                                        settings.original_path =  obj.analysis_modules.(char(modules(i))).results.(char(results(o)));
                                        settings.new_path = [obj.data_analysisindir,'/',a{end-1},'/',a{end}];

                                        obj.analysis_modules.(char(modules(i))).results.(char(results(o))) = settings.new_path;
                                    else 
                                        continue;
                                    end
                                end
                                
                                log2dev(sprintf('EPITOOLS:SettingsClass:createPackage:PoolTagUpdate | update %s --> %s',...
                                tag.original_path,...
                                tag.new_path),...
                                'DEBUG');
                                log2dev(sprintf('EPITOOLS:SettingsClass:createPackage:SettingsUpdate | update %s --> %s',...
                                settings.original_path,...
                                settings.new_path),...
                                'DEBUG');

                            end
                            
                        catch err
                           log2dev(sprintf('EPITOOLS:SettingsClass:createPackage:Traverse | %s',err.message),'WARN');
                        end
                    end
                end
                % If everything went ok, then remove temporary folders and save data
                % structures (settings, pool xml file)
                
                % Write to xml pool file
                Pref.StructItem = false;
                xml_write([obj.data_fullpath,'/pools/',listing(ind).name],x,'tags',Pref);
                
                % Remove temporary directories
                listfolders = dir(obj.data_fullpath);
                ind = find(~cellfun(@isempty, regexp({listfolders.name}, 'tmp_')));  
                for i = 1:numel(ind); rmdir([obj.data_fullpath,'/',listfolders(ind(i)).name],'s'); end
                
                % Save settings file
                obj.GenerateXMLFile()
                
            catch err
                log2dev(sprintf('EPITOOLS:SettingsClass:createPackage:generic | %s',err.message),'WARN');
            end
        end
        % --------------------------------------------------------------------
    end
    
end