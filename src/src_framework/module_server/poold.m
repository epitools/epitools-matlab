classdef poold < handle
    %POOLD Pool daemon contains the properties and methods for instantiate
    %a pool class. A pool class is responsible to keep track of server and
    %client tag architecture, to push and pull tag changes from xml pool
    %definition file. 
    
    properties (SetAccess = private)
        file = [];
        directory = '';
        name = '';
        tags = {};
        active = false;
        handleGraphics = '';
        handleJTreeTable = '';
    end
    
    events
        AddedTag
        RemovedTag
        PoolInstance
    end
    
    methods
        function pool = poold(filename)
            % This function instanziate the pool object which will trigger its
            % announcement to the calling environment
            %
            % If no file name has been specified, then assigned one randomly
            if (~nargin==1); filename = strcat('unknown',num2str(randi(1000)));end
            pool.file = strcat('pool_',filename,'.xml');
            pool.name = filename;
            pool.directory = filename;
            pool.tags = {};
            pool.active = false;
            pool.handleGraphics = '';
            pool.handleJTreeTable = '';
            % Listeners
            poold_manager.listenerEvents(pool);
            % Announce to environment
            notify(pool,'PoolInstance');
        end
        % ====================================================================
        % Tag functions
        function appendTag(pool,tagstruct)
            % Add pointer to pool list (pool.tags)
            for i=1:numel(tagstruct) 
                if(sum(strcmp(tagstruct(i).tag,pool.tags))>=1)
                    idx = find(strcmp(tagstruct(i).tag,pool.tags),1,'first');
                    pool.tags{idx} = tagstruct(i).tag;
                else
                    pool.tags{end+1} = tagstruct(i).tag;
                end
            end
            % Append structure to xml definition file  (pool.file)
            
            notify(pool, 'AddedTag');
        end
        % --------------------------------------------------------------------
        function removeTag(pool,tagcode)
        
            % Remove structure from xml definition file  (pool.file)    
            % Delete pointer from pool list (pool.tags)
            notify(pool, 'RemovedTag');
        end
        % --------------------------------------------------------------------
        % Check if a certain tag is present in the avail tag list
        function boolean = existsTag(pool,tagcode)
            boolean = false;
            if(sum(strcmp(pool.tags, tagcode)>=1));
                boolean = true;
            end
        end
        % --------------------------------------------------------------------      
        % Retrieve tag association between tag and pool file
        function tag = retrieveTag(pool,tagcode)
        
            tags = xml_read(['tmp/',pool.file]);
            level = find(strcmp(tagcode,pool.tags));
            tag = tags.tag(level);

        end
        % --------------------------------------------------------------------
        % Print all tag in the pool
        function getTagList(pool)
        
        end
        % --------------------------------------------------------------------
        % This funciton loads tags stored in xml pool file
        function loadPool(pool)
            if exist(['tmp/',pool.file], 'file');
                tags = xml_read(['tmp/',pool.file]);
                for i=1:numel(tags.tag)
                    pool.tags{i} = tags.tag(i).uid;
                end
            end
        end
        % --------------------------------------------------------------------
         % This function save in a xml files tags stored in pool object
        function savePool(pool)
            xml_write(['tmp/',pool.file], pool);
        end
        % --------------------------------------------------------------------
        % Save reference in session available resources.
        function announceToFramework(pool, callerID)
            pool_instances = getappdata(callerID, 'pool_instances');
            if isempty(pool_instances)
               pool_instances(1).ref = pool;
            else
               pool_instances(end+1).ref = pool;
            end
            % Set pool directory according to analysis folder
            settings_objectname = getappdata(callerID, 'settings_objectname');
            pool.directory = strcat(settings_objectname.data_analysisindir,'/',pool.directory);
            % Store pool reference collector into
            % session environment
            setappdata(callerID, 'pool_instances', pool_instances);
        end
        % --------------------------------------------------------------------
        function buildGUInterface(pool, GraphicHandle, globalHandle)
            if nargin >= 2
                pool.handleGraphics = GraphicHandle;
            end
            pool.handleJTreeTable   = uitreetable_serverpool(pool.handleGraphics, globalHandle);
        end
        % --------------------------------------------------------------------
        function activatePool(pool)
            pool.active = true;
            notify(pool,'PoolInstance');
        end
        % --------------------------------------------------------------------
        function deactivatePool(pool)
            pool.active = false;
            notify(pool,'PoolInstance');
        end
        % --------------------------------------------------------------------
    end
    
end

