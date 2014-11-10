classdef poold < handle
    %POOLD Pool daemon contains the properties and methods for instantiate
    %a pool class. A pool class is responsible to keep track of server and
    %client tag architecture, to push and pull tag changes from xml pool
    %definition file. 
    
    properties (SetAccess = private)
        file = [];
        tags = {};
    end
    
    events
    
        AddedTag
        RemovedTag
        
    end
    
    methods
        
        function pool = poold(filename)
        
            if (~nargin==1); filename = strcat('unknown',num2str(randi(1000)));end
            pool.file = strcat('pool_',filename,'.xml');
            pool.tags = {};
            
            poold_manager.listenerEvents(pool);

            
        end
        
        % =================================================================
        % Tag functions
        
        function appendTag(pool,tagstruct)
        
            % Append structure to xml definition file  (pool.file)
            % Add pointer to pool list (pool.tags)
            notify(pool, 'AddedTag');
        end
        

        function removeTag(pool,tagcode)        
        
            % Remove structure from xml definition file  (pool.file)    
            % Delete pointer from pool list (pool.tags)
            notify(pool, 'RemovedTag');
        end
        
        % Check if a certain tag is present in the avail tag list
        function boolean = existsTag(pool,tagcode)
            boolean = false;
            if(sum(strcmp(pool.tags, tagcode)>=1));
                boolean = true;
            end
            
        end
        
        % Retrieve tag association between tag and pool file
        function tag = retrieveTag(pool,tagcode)
        
            tags = xml_read(['tmp/',pool.file]);
            level = find(strcmp(tagcode,pool.tags));
            tag = tags.tag(level);

        end
        
        % Print all tag in the pool
        function getTagList(pool)
        
        end
        
        % This funciton loads tags stored in xml pool file
        function loadPool(pool)

            tags = xml_read(['tmp/',pool.file]);
            for i=1:numel(tags.tag)

                pool.tags{i} = tags.tag(i).uid;

            end
            
        end
        
    end
    
end

