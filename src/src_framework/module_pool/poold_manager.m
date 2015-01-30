classdef poold_manager
    %POOLD-MANAGER Event functions associations for Pool Objects
    
    methods (Static)
        
        function listenerEvents(pool)
            % Add listener on poold instance for events on Pool objects
%             addlistener(pool, 'AddedTag', ...
%                 @(src, evnt)poold_manager.dispacherAddedTag(src,evnt.EventData));
            addlistener(pool, 'AddedTag',...
                @(src, evnt)poold_manager.dispacherAddedTag(src, evnt));
            addlistener(pool, 'RemovedTag', ...
                @(src, evnt)poold_manager.refreshLinks(src));
            addlistener(pool, 'PoolModified', ...
                @(src, evnt)poold_manager.dispacherPoolModified(src, evnt)); 
            addlistener(pool, 'AddedModule', ...
                @(src, evnt)poold_manager.dispacherAddedModule(src,evnt)); 
            addlistener(pool, 'PoolInstance', ...
                @(src, evnt)poold_manager.dispacherPoolInstance(src,evnt)); 
        end
        % --------------------------------------------------------------------
        function dispacherAddedTag(eventSrc,eventData)
            %disp(eventData);
        end
        % --------------------------------------------------------------------
        function dispacherAddedModule(pool,event)
            poold_manager.resetAnalysisLinkage(pool,event.ModuleName);
        end
        % --------------------------------------------------------------------
        function dispacherPoolModified(pool, evnt)
            poold_manager.updatePool(pool);
            if ~isempty(evnt.TagArray)
                poold_manager.updateDisplayGraphics(pool, evnt);
            end
        end
        % --------------------------------------------------------------------
        function dispacherPoolInstance(pool,evnt)
            poold_manager.updatePool(pool);
        end
        % --------------------------------------------------------------------
        function resetAnalysisLinkage(pool, mdname)
            curr_settings = getappdata(getappdata(0,'hMainGui'), 'settings_objectname');
            poolstructure = xml_read(['tmp/',pool.file]);
            idxmodule   = strcmp({poolstructure.tag.module},mdname);
            idxmodule   = find(idxmodule);
            idxmodule   = idxmodule(1);
            idxsettings = strcmp({poolstructure.tag(idxmodule).attributes.attribute.class},'settings');
            if(sum(idxsettings)>0) 
                idxsettings   = find(idxsettings);
                idxsettings   = idxsettings(1);
                tmp = getVariable4Memory(poolstructure.tag(idxmodule).attributes.attribute(idxsettings).path);
            end
            curr_settings.importModule(tmp,mdname);
            curr_settings.discardDownstreamModules(mdname);
            curr_settings.refreshTree(getappdata(0,'hMainGui'));
        end 
        % --------------------------------------------------------------------
        %% Standalone functions (GUI Related)
        function updateDisplayGraphics(pool, evnt)
            % Refresh display graphical tags appended to pool list
            % Tags have to be sorted from the active pool by time of appending
            hMainGui = getappdata(0, 'hMainGui');
            stgObj = getappdata(getappdata(0, 'hMainGui'), 'settings_objectname');
            pool_instances = getappdata(getappdata(0,'hMainGui'), 'pool_instances');           
            uihandles_deletecontrols( 'uiSWslider' );
            uihandles_deletecontrols( 'uiSWImage' );
            uihandles_deletecontrols( 'uiSWFrameNumLabel' );
            uihandles_deletecontrols( 'uiSWFrameNumEdit' );
            uihandles_deletecontrols( 'uiBannerDescription' );
            uihandles_deletecontrols( 'uiBannerContenitor' );
            uihandles_deletecontrols( 'GraphicHandleSingleVDisplay' );
            %% Prepare displays
            inputs = {};
            intDisplays = 1;
            for i=1:numel(evnt.TagArray{:})
                if strcmp(pool.getTag(evnt.TagArray{:}{i}).class,'graphics')
                    attributes = pool.getTag(evnt.TagArray{:}{i}).attributes.attribute;
                    inputs{1}              = hMainGui;
                    inputs{2}{intDisplays} = attributes(strcmp({attributes.class},'file')).path;
                    inputs{3}{intDisplays} = sprintf('%s-%s',...
                                                    pool.getTag(evnt.TagArray{:}{i}).uid,...
                                                    datestr(pool.getTag(evnt.TagArray{:}{i}).timestamp,31));
                    intDisplays = intDisplays+1;
                elseif strcmp(pool.getTag(evnt.TagArray{:}{i}).class,'complex')
                    inputs{1}              = hMainGui;
                    inputs{2}{intDisplays} = attributes(strcmp({attributes.class},'file')).path;
                    inputs{3}{intDisplays} = sprintf('%s-%s',...
                                                    pool.getTag(evnt.TagArray{:}{i}).uid,...
                                                    datestr(pool.getTag(evnt.TagArray{:}{i}).timestamp,31));
                    intDisplays = intDisplays+1;
                
                end
            end
            %% Call display functions
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
            if ~isempty(inputs);
                if (~stgObj.exec_commandline)
                    if(stgObj.icy_is_used)
                        for idxDisp = 1:intDisplays
                            matfile = load(inputs{2}{idxDisp});
                            imgfields = fields(matfile);
                            image2display = [];
                            if isempty(imgfields) && numel(imgfields)>1 
                                if strcmp(imgfields,'CLabels')
                                    image2display = matfile.Clabels;
                                end
                            else
                                image2display = matfile.(char(imgfields(1)));
                            end
                            tag = pool.getTag(evnt.TagArray{:}{idxDisp});
                            poolname = sprintf('%s - %s',evnt.TagArray{:}{idxDisp},datestr(tag.timestamp,31));
                            icy_vidshow(image2display,poolname);
                            status = true;
                        end
                    else
                        [status,argout] = dataexplorer_imageview( inputs );
                    end
                end
            end
            if ~status;
                uihandles_savecontrols( argout(1).description ,argout(1).object );
                log2dev( 'Slide visualisation mode actived', 'INFO', 0, 'hMainGui', 'statusbar' );
            end
        end
        % --------------------------------------------------------------------
        function updatePool(pool)
            % Update graphical objects associated to modified pool 
            if ~isempty(pool.handleJTreeTable)
                pool.loadPool;
                pool.buildGUInterface;
            end
        end
        % --------------------------------------------------------------------
    end
end

