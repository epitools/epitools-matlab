function UserSettingsGUI()
%USERSETTINGSGUI Summary of this function goes here
%   Detailed explanation goes here

hUSGui = figure();
set(hUSGui,...
    'Name', 'Framework Settings',...
    'Toolbar', 'none',...
    'MenuBar', 'none',...
    'Position', [0 0 800 600]);

movegui(hUSGui,'center');

if(~exist('./.usersettings.xml', 'file'));generate_empty_settingsfile();end

settingsobj = xml_read('./.usersettings.xml');
settingsobj = settingsobj.main;

jtree = uitree_control_usersettings(hUSGui,settingsobj);


% Set the tree mouse-click callback
% Note: MousePressedCallback is better than MouseClickedCallback
%       since it fires immediately when mouse button is pressed,
%       without waiting for its release, as MouseClickedCallback does
set(jtree, 'MousePressedCallback', {@mousePressedCallback});


controlpanel = uipanel('Parent', hUSGui,...
    'Units', 'normalized',...
    'Position', [0.25 0.10 0.75 0.90]);
okcontrol = uicontrol('Style', 'pushbutton',...
    'String', 'Apply',...
    'Units', 'normalized',...
    'Position', [0.9 0.01 0.08 0.05],...
    'Callback', {@(source,eventdata) delete(hUSGui)});
abortcontrol = uicontrol('Style', 'pushbutton',...
    'String', 'Abort',...
    'Units', 'normalized',...
    'Position', [0.82 0.01 0.08 0.05],...
    'Callback', {@(source,eventdata) delete(hUSGui)});

    function update()
        delete(controlpanel);
        controlpanel = uipanel('Parent', hUSGui,...
            'Units', 'normalized',...
            'Position', [0.25 0.10 0.75 0.90]);
        
        settingsobj = xml_read('./.usersettings.xml');
        settingsobj = settingsobj.main;
        hMainGui = getappdata(0, 'hMainGui');
        setappdata(hMainGui, 'settings_execution', settingsobj);
    end

% Set the mouse-press callback
    function mousePressedCallback(hTree, eventData)
        if ~eventData.isMetaDown  % left-click is not like a Meta-button
            % Get the clicked node
            clickX = eventData.getX;
            clickY = eventData.getY;
            jtree = eventData.getSource;
            treePath = jtree.getPathForLocation(clickX, clickY);
            
            if(~isempty(treePath))
                lengthPath = treePath.getPathCount();
                if(lengthPath == 3)
                    try
                        % Modify the context menu or some other element
                        % based on the clicked node. Here is an example:
                        node = treePath.getLastPathComponent;
                        nodeName = ['Current node: ' char(node.getName)];
                        
                        % Set module name as temporary environment variable
                        mdName = char(node.getName);
                        update();
                        ctlCallbacks(char(treePath.getParentPath.getLastPathComponent.getName),mdName);
                        
                        %item = jmenu.add(nodeName);
                        
                        % remember to call jmenu.remove(item) in item callback
                        % or use the timer hack shown here to remove the item:
                        %timerFcn = {@removeItem,jmenu,item};
                        %start(timer('TimerFcn',timerFcn,'StartDelay',0.2));
                    catch
                        % clicked location is NOT on top of any node
                        % Note: can also be tested by isempty(treePath)
                    end
                    
                    % Display the (possibly-modified) context menu
                    %jmenu.show(jtree, clickX, clickY);
                    %jmenu.repaint;
                end
            end
        end
    end

    function ctlCallbacks(root, leaf)
        
        nodes = fields(settingsobj.(root).(leaf));
        
        for i=1:numel(nodes)
            if(settingsobj.(root).(leaf).(char(nodes(i))).visible == 1)
                if(i>=2);interspace = 1.5;else interspace = 1; end
                %uicontrol('Style', 'radio')
                switch settingsobj.(root).(leaf).(char(nodes(i))).desc
                    
                    case 'single'
                        
                        h = uibuttongroup('Title',settingsobj.(root).(leaf).(char(nodes(i))).name,'visible','on','Units', 'normalized','Position',[0 0 1 1], 'Parent',controlpanel);
                        
                        for o=1:numel(settingsobj.(root).(leaf).(char(nodes(i))).values)
                            uicontrol('Style','radiobutton',...
                                'String', char(settingsobj.(root).(leaf).(char(nodes(i))).values{o}),...
                                'Units', 'normalized',...
                                'Position',[0.01 (0.95-(0.04*o*i)) 0.2 0.04 ],...
                                'Parent',h,...
                                'Value', settingsobj.(root).(leaf).(char(nodes(i))).actived(o),...
                                'HandleVisibility','on');
                        end
                        set(h,'SelectionChangeFcn',{@selcbk,settingsobj,root,leaf,char(nodes(i))});
                        %set(h,'SelectedObject',[]);  % No selection
                        %set(h,'Visible','on');
                        
                        
                    case 'multiple'
                        h = uibuttongroup('Title',settingsobj.(root).(leaf).(char(nodes(i))).name,'visible','on','Units', 'normalized','Position',[0 0 1 1], 'Parent',controlpanel);

                        for u=1:length(settingsobj.(root).(leaf).(char(nodes(i))).values)

                            uicontrol('Style','checkbox',...
                                      'String', char(settingsobj.(root).(leaf).(char(nodes(i))).values{u}),...
                                      'Units', 'normalized',...
                                      'Position',[0.01 (0.95-(0.04*u*i)) 0.2 0.04 ],...
                                      'Parent',h,...
                                      'Value', settingsobj.(root).(leaf).(char(nodes(i))).actived(u),...
                                      'Callback',{@multselcbk,settingsobj,root,leaf,char(nodes(i)),u});

                        end

                        
                    case 'text'
                        h = uipanel('Title',settingsobj.(root).(leaf).(char(nodes(i))).name,'visible','on','Units', 'normalized','Position',[0 0 1 1], 'Parent',controlpanel);
                        
                        switch class(settingsobj.(root).(leaf).(char(nodes(i))).values)
                            case 'double'
                                string2visualize = num2str(settingsobj.(root).(leaf).(char(nodes(i))).values);
                            otherwise
                                string2visualize = settingsobj.(root).(leaf).(char(nodes(i))).values;
                        end
                        uicontrol('Style','text',...
                            'Units', 'normalized',...
                            'Position',[0.01 (0.95-(0.04*i*interspace)) 0.35 0.04 ],...
                            'Parent',h,...
                            'String', settingsobj.(root).(leaf).(char(nodes(i))).name);
                        uicontrol('Style','edit',...
                            'Units', 'normalized',...
                            'HorizontalAlignment', 'left',...
                            'Position',[0.37 (0.95-(0.04*i*interspace)) 0.5 0.04 ],...
                            'Parent',h,...
                            'String', string2visualize,...
                            'Callback', {@editcbk,settingsobj,root,leaf,char(nodes(i))});
                        
                        
                end
            end
            
        end
        
        
    end

    function selcbk(source,eventdata,settingsobj,root,leaf,ctl)
        
        vls = settingsobj.(root).(leaf).(ctl).values;
        mtx = ismember(vls,{get(eventdata.NewValue,'String')});
        settingsobj.(root).(leaf).(ctl).actived = +mtx;
        settingsobj.main = settingsobj;
        xml_write('./.usersettings.xml',settingsobj);
    end

    function multselcbk(source,eventdata,settingsobj,root,leaf,ctl,pos)
        
        if(settingsobj.(root).(leaf).(ctl).actived(pos) == 1);
            settingsobj.(root).(leaf).(ctl).actived(pos) = 0;
        elseif (settingsobj.(root).(leaf).(ctl).actived(pos) == 0)
            settingsobj.(root).(leaf).(ctl).actived(pos) = 1;
        end
        settingsobj.main = settingsobj;
        xml_write('./.usersettings.xml',settingsobj);
    end

    function editcbk(source,eventdata,settingsobj,root,leaf,ctl)
        
        settingsobj.(root).(leaf).(ctl).values = get(source,'string');
        settingsobj.main = settingsobj;
        xml_write('./.usersettings.xml',settingsobj);
    end
end