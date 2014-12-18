classdef poold_manager
    %POOLD-MANAGER Event functions associations for Pool Objects
    
    methods (Static)
        
        function listenerEvents(pool)
            % Add listener on poold instance for events on Pool objects
            addlistener(pool, 'AddedTag', ...
                @(src, evnt)poold_manager.updateDisplayGraphics(src));
            addlistener(pool, 'RemovedTag', ...
                @(src, evnt)poold_manager.refreshLinks(src));
            addlistener(pool, 'PoolModified', ...
                @(src, evnt)poold_manager.updatePool(src));
            
        end
        
        function updateDisplayGraphics(pool)
            % Refresh display graphical tags appended to pool list
            % Tags have to be sorted from the active pool by time of appending
            hMainGui = getappdata(0, 'hMainGui');
            pool_instances = getappdata(getappdata(0,'hMainGui'), 'pool_instances');
            uihandles_deletecontrols( 'uiSWslider' );
            uihandles_deletecontrols( 'uiSWImage' );
            uihandles_deletecontrols( 'uiSWFrameNumLabel' );
            uihandles_deletecontrols( 'uiSWFrameNumEdit' );
            uihandles_deletecontrols( 'uiBannerDescription' );
            uihandles_deletecontrols( 'uiBannerContenitor' );
            uihandles_deletecontrols( 'GraphicHandleSingleVDisplay' );
            varargin = {};
            cmptable = {};
            for i = 2:numel(pool_instances)
                if pool_instances(i).ref.active
                    for o = 1:numel(pool_instances(i).ref.tags)
                        tmp = pool_instances(i).ref.getTag(char(pool_instances(i).ref.tags(o)));
                        if strcmp(tmp.class,'graphics')
                            if isempty(cmptable); cmptable(1,:) = {tmp.uid,tmp.timestamp};else cmptable(end+1,1:2) = {tmp.uid,tmp.timestamp};end
                            for u = 1:numel(tmp.attributes.attribute)
                                if strcmp(tmp.attributes.attribute(u).class,'file') || strcmp(tmp.attributes.attribute(u).class,'variable')
                                    idx = sum(~cellfun(@isempty, cmptable(strcmp(cmptable(:,1),tmp.uid),:)));
                                    %cmptable{strcmp(cmptable(:,1),tmp.uid),idx+1} = tmp.attributes.attribute(u).path;
                                    cmptable(strcmp(cmptable(:,1),tmp.uid),idx+1) = {tmp.attributes.attribute(u).path};
                                end
                            end
                        end
                    end
                end
            end
            if isempty(cmptable);return;end
            % Sorting columns
            [~,I] = sort([cmptable{:,2}], 'descend');
            % Check advanced module tags in descending order
            inputs{1} = hMainGui;
            inputs{2}(1) = cmptable(strcmp({cmptable{:,1}},'PROJECTED_IMAGE'),3);
            inputs{3}(1) = {'PROJECTED_IMAGE'};
            latest = cmptable(I(1),1);
            reference = cmptable(strcmp({cmptable{:,1}},'PROJECTED_IMAGE'),1);
            if ~strcmp(reference,latest)
                inputs{2}(end+1) = cmptable(I(1),3);
                inputs{3}(end+1) = cmptable(I(1),1);
                varargin = {'Comparative',1};
            end
            % function should call dataexplorer_imageview.m with the following
            % arguments. graphical parameters should set according the tag
            % category (if clahe is present - as last tag - , then preview mode should be
            % set to 1; if image registration and segmentation are present then
            % comparative mode should be set to 1);
            % return with inputs{1} = hMainGui
            %             inputs{2} = {path-to-mat-file}
            %             inputs{3} = {description}
            %             varargin{1} = {'Comparative', 1} %for each
            %
            if ~isempty(inputs);[status,argout] = dataexplorer_imageview( inputs , varargin);end
            if ~status;
                uihandles_savecontrols( argout(1).description ,argout(1).object );
                log2dev( 'Slide visualisation mode actived', 'INFO', 0, 'hMainGui', 'statusbar' );
            end
        end
        % --------------------------------------------------------------------
        %% Standalone functions (GUI Related)
        function updatePool(pool)
            if ~isempty(pool.handleJTreeTable)
                pool.loadPool;
                pool.buildGUInterface;
            end
        end
        % --------------------------------------------------------------------
    end
end