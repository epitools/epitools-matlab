function uitree_contextualmenu( jtree )
%JTREE_CONTEXTUALMENU
%
% Prepare the context menu (note the use of HTML labels)
menuItem1 = javax.swing.JMenuItem('<html> Open module settings </html>', javax.swing.ImageIcon('./images/icons/magnifier.png'));
menuItem2 = javax.swing.JMenuItem('<html> Open results in finder </html>', javax.swing.ImageIcon('./images/icons/computer.png'));
menuItem3 = javax.swing.JMenuItem('<html> Export module as .xml file </html>',javax.swing.ImageIcon('./images/icons/page_code.png'));
menuItem4 = javax.swing.JMenuItem('<html> Export results as .zip file </html>',javax.swing.ImageIcon('./images/icons/compress.png'));
menuItem5 = javax.swing.JMenuItem('<html> Delete module </html>',javax.swing.ImageIcon('./images/icons/bin_closed.png'));
menuItem6 = javax.swing.JMenuItem('<html> Visualize results </html>', javax.swing.ImageIcon('./images/icons/slides_stack.png'));
menuItem7 = javax.swing.JMenuItem('<html> Export results as .tiff file </html>',javax.swing.ImageIcon('./images/icons/images.png'));
% Retrieve Matlab Handles from Java objects
hmenuItem1 = handle(menuItem1, 'CallbackProperties');
hmenuItem2 = handle(menuItem2, 'CallbackProperties');
hmenuItem3 = handle(menuItem3, 'CallbackProperties');
hmenuItem4 = handle(menuItem4, 'CallbackProperties');
hmenuItem5 = handle(menuItem5, 'CallbackProperties');
hmenuItem6 = handle(menuItem6, 'CallbackProperties');
hmenuItem7 = handle(menuItem7, 'CallbackProperties');
% Set the menu items' callbacks
set(menuItem1,'ActionPerformedCallback',@openModuleSettings);
set(menuItem2,'ActionPerformedCallback',@openModuleinFinder);
set(menuItem3,'ActionPerformedCallback',@exportModuleasXML);
set(menuItem4,'ActionPerformedCallback',@exportResultsasZIP);
set(menuItem5,'ActionPerformedCallback',@deleteModuleSettings);
set(menuItem6,'ActionPerformedCallback',@openModuleResultsinMainView);
set(menuItem7,'ActionPerformedCallback',@exportModuleasTiff);

% Add all menu items to the context menu (with internal separator)
jmenu = javax.swing.JPopupMenu;
jmenu.add(menuItem6);
jmenu.add(menuItem1);
jmenu.add(menuItem2);
jmenu.addSeparator;
jmenu.add(menuItem7);
jmenu.add(menuItem3);
jmenu.add(menuItem4);
jmenu.addSeparator;
jmenu.add(menuItem5);
% Set the tree mouse-click callback
% Note: MousePressedCallback is better than MouseClickedCallback
%       since it fires immediately when mouse button is pressed,
%       without waiting for its release, as MouseClickedCallback does
set(jtree, 'MousePressedCallback', {@mousePressedCallback,jmenu});

% Set the mouse-press callback
    function mousePressedCallback(hTree, eventData, jmenu)
        if eventData.isMetaDown  % right-click is like a Meta-button
            % Get the clicked node
            clickX = eventData.getX;
            clickY = eventData.getY;
            jtree = eventData.getSource;
            treePath = jtree.getPathForLocation(clickX, clickY);
            
            if(~isempty(treePath))
                lengthPath = treePath.getPathCount();
                if(lengthPath == 2)
                    try
                        % Modify the context menu or some other element
                        % based on the clicked node. Here is an example:
                        node = treePath.getLastPathComponent;
                        nodeName = ['Current node: ' char(node.getName)];
                        
                        % Set module name as temporary environment variable
                        mdName = char(node.getName);
                        hMainGui = getappdata(0, 'hMainGui');
                        setappdata(hMainGui,'module_name',mdName);
                        
                        item = jmenu.add(nodeName);
                        
                        % remember to call jmenu.remove(item) in item callback
                        % or use the timer hack shown here to remove the item:
                        timerFcn = {@removeItem,jmenu,item};
                        start(timer('TimerFcn',timerFcn,'StartDelay',0.2));
                    catch
                        % clicked location is NOT on top of any node
                        % Note: can also be tested by isempty(treePath)
                    end
                    
                    % Display the (possibly-modified) context menu
                    jmenu.show(jtree, clickX, clickY);
                    jmenu.repaint;
                end
            end
        end
    end

% Remove the extra context menu item after display
    function removeItem(hObj,eventData,jmenu,item)
        jmenu.remove(item);
    end

% callback functions
    function openModuleResultsinMainView(hObject, eventData)
        hMainGui = getappdata(0, 'hMainGui');
        stgObj = getappdata(hMainGui,'settings_objectname');
        mdName = getappdata(hMainGui,'module_name');
        % Check if these lines are still in use
        uihandles_deletecontrols( 'uiSWslider' );
        uihandles_deletecontrols( 'uiSWImage' );
        uihandles_deletecontrols( 'uiSWFrameNumLabel' );
        uihandles_deletecontrols( 'uiSWFrameNumEdit' );
        uihandles_deletecontrols( 'uiBannerDescription' );
        uihandles_deletecontrols( 'uiBannerContenitor' );
        uihandles_deletecontrols( 'GraphicHandleSingleVDisplay' );
        varargin = {};
        switch mdName
            case 'Projection'
                SandboxGUIRedesign(0);
                data = load(stgObj.analysis_modules.(char(mdName)).results.projection_path);
                
                if(stgObj.icy_is_used)
                    icy_vidshow(data.ProjIm,'Projected Sequence');
                else
                    inputs{1} = hMainGui;
                    inputs{2} = {stgObj.analysis_modules.(char(mdName)).results.projection_path};
                    inputs{3} = {mdName};
                    %varargin = {'Comparative',1};
                    %StackView(data.ProjIm,'hMainGui','figureA');
                end
                
            case 'Stack_Registration'
                SandboxGUIRedesign(0);
                data = load(stgObj.analysis_modules.(char(mdName)).results.registration_path);
                
                if(stgObj.icy_is_used)
                    icy_vidshow(data.RegIm,'Registered Sequence');
                else
                    %StackView(data.RegIm,'hMainGui','figureA');
                    inputs{1} = hMainGui;
                    inputs{2} = {stgObj.analysis_modules.(char(mdName)).results.registration_path};
                    inputs{3} = {mdName};
                end
                
            case 'Contrast_Enhancement'
                SandboxGUIRedesign(0);
                data = load(stgObj.analysis_modules.(char(mdName)).results.clahe_path);
                
                if(stgObj.icy_is_used)
                    icy_vidshow(data.RegIm,'CLAHE Sequence');
                else
                    %StackView(data.RegIm,'hMainGui','figureA');
                    inputs{1} = hMainGui;
                    inputs{2} = {stgObj.analysis_modules.(char(mdName)).results.clahe_path};
                    inputs{3} = {mdName};
                end
                
            case 'Segmentation'
                SandboxGUIRedesign(0);
                data = load(stgObj.analysis_modules.(char(mdName)).results.segmentation_path);
                if(stgObj.icy_is_used)
                    icy_vid3show(data.ColIms,'Segmented Sequence');
                else
                    %StackView(data.ColIms,'hMainGui','figureA');
                    inputs{1} = hMainGui;
                    inputs{2} = {stgObj.analysis_modules.(char(mdName)).results.segmentation_path};
                    inputs{3} = {mdName};
                end

            otherwise
                h = msgbox('The function has not been implemented for the current module. ', 'Exception handler - DEV');
                
        end
        if ~isempty(inputs);[status,argout] = dataexplorer_imageview( inputs , varargin);end
        if ~status;
            uihandles_savecontrols( argout(1).description ,argout(1).object );
            %log2dev('Preparing display...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
            %log2dev('Slide visualisation mode actived', 'INFO', 0, 'hMainGui', 'statusbar',{0,1,1} );
        end

    end

    function openModuleSettings(hObject, eventData)
        hMainGui = getappdata(0, 'hMainGui');
        mdName = getappdata(hMainGui,'module_name');
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        switch mdName
            case 'Projection'
                out = ProjectionGUI(stgObj);
                uiwait(out);
                
            case 'Contrast_Enhancement'
                out = ImproveContrastGUI(stgObj);
                uiwait(out);
                
            case 'Segmentation'
                out = SegmentationGUI(stgObj);
                uiwait(out);
                
            case 'Tracking'
                out = TrackingIntroGUI(stgObj);
                uiwait(out);
                
            otherwise
                h = msgbox('The function has not been implemented for the current module. ', 'Exception handler - DEV');
        end
        
        
    end

    function openModuleinFinder(hObject, eventData)
        hMainGui = getappdata(0, 'hMainGui');
        stgObj = getappdata(hMainGui,'settings_objectname');
        command = ['open ',stgObj.data_analysisindir];
        if(ispc);command = ['explorer ',stgObj.data_analysisindir];end
        if(isunix);command = ['open ',stgObj.data_analysisindir];end
        status = system(command);
        
    end

    function exportModuleasXML(hObject, eventData)
        hMainGui = getappdata(0, 'hMainGui');
        mdName = getappdata(hMainGui,'module_name');
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        if(strcmp(mdName,'Main'))
            h = msgbox('The function has not been implemented for the current module. ', 'Exception handler - DEV');
            
        else
            tmp = struct();
            tmp.main = stgObj.analysis_modules.(char(mdName));
            struct2xml(tmp, strcat(stgObj.data_fullpath,'/',mdName,'.xml'));
        end
        
    end

    function exportResultsasZIP(hObject, eventData)
        hMainGui = getappdata(0, 'hMainGui');
        mdName = getappdata(hMainGui,'module_name');
        stgObj = getappdata(hMainGui,'settings_objectname');
        
        rstFields = fields(stgObj.analysis_modules.(char(mdName)).results);
        arrayFiles2Zip = {};
        
        for i=1:numel(rstFields)
            
            %arrayFiles2Zip{i} = strcat(stgObj.data_analysisindir,'/',stgObj.analysis_modules.(char(mdName)).results.(char(rstFields(i))));
            arrayFiles2Zip{i} = stgObj.analysis_modules.(char(mdName)).results.(char(rstFields(i)));
        end
        
        zip(strcat(stgObj.data_analysisindir,'/',mdName,'.zip'),arrayFiles2Zip);
        
    end

    function deleteModuleSettings(hObject, eventData)
        hMainGui = getappdata(0, 'hMainGui');
        mdName = getappdata(hMainGui,'module_name');
        stgObj = getappdata(hMainGui,'settings_objectname'); 
        strUserSel = questdlg(sprintf('You are about to delete this module from your analysis.\n\n Do you really want to continue?'),'Delete analysis module - User confirm','Yes','No','No');
        switch strUserSel
            case 'Yes'
                stgObj.DestroyModule(mdName);
                setappdata(hMainGui,'settings_objectname',stgObj);
                SaveAnalysisFile(stgObj,'ForceSave', true);
                stgObj.refreshTree(hMainGui);
                %LoadControls(hMainGui,stgObj); 
        end
    end

    function exportModuleasTiff(hObject, eventData)
        hMainGui = getappdata(0, 'hMainGui');
        mdName = getappdata(hMainGui,'module_name');
        stgObj = getappdata(hMainGui,'settings_objectname');
        if(strcmp(mdName,'Main')) || (strcmp(mdName,'Indices'))
            h = msgbox('The function has not been implemented for the current module. ', 'Exception handler - DEV');
        else
            fieldsResults = fields(stgObj.analysis_modules.(char(mdName)).results);
            min = 0; max=numel(fieldsResults); value=0;
            log2dev(sprintf('Exporting %s module as tiff files...',mdName),'INFO',0,'hMainGui', 'statusbar',{min,max,value});
            for i = 1:numel(fieldsResults)
                matfile = load(stgObj.analysis_modules.(char(mdName)).results.(char(fieldsResults{i})));
                imgfields = fields(matfile);
                image2export = [];
                filename = [stgObj.data_analysisoutdir,'/',mdName,'.',fieldsResults{i}];
                for o = 1:numel(imgfields)
                    % Special case for segmentation
                    if ~isempty(imgfields{o}) && numel(imgfields)>1 
                        if strcmp(imgfields{o},'CLabels')
                            image2export = matfile.CLabels; 
                            filename = [filename,'_CLabels']; 
                        elseif strcmp(imgfields{o},'ILabels')
                            image2export = matfile.ILabels; 
                            filename = [filename,'_ILabels']; 
                        else
                            continue;
                        end
                    else
                        image2export = matfile.(char(imgfields(1)));
                    end
                    if isa(image2export,'uint8') || isa(image2export,'uint16')
                        exportTiffImages(image2export,'filename',[filename,'.tiff']);
                        log2dev(sprintf('Exported %s file as tiff in %s',[filename,'.tiff'],stgObj.data_analysisoutdir),'INFO',0,'hMainGui', 'statusbar',{min,max,i});
                    end
                end
            end
        end 
    end
end


