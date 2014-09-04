function log_guidevice(string2log)

if nargin < 1
   
    string2log = '';
   
end

if(~strcmp(fields(getappdata(0)),'hLogGui'))

    fig = initialize();
    
end

hLogGui = getappdata(0,'hLogGui');
handles = getappdata(hLogGui);
data = get(handles.hListBox,'String');
data{end+1} = string2log;
set(handles.hListBox,'String', data);
update();

    function fig = initialize()
          
        fig = figure('Visible','off',...
                    'Name','Log execution',...
                    'Toolbar', 'none',...
                    'Resize', 'off',...
                    'NumberTitle', 'off',...
                    'Position',[0,0,600,100],...
                    'Resize','on');
        

        %hPanel  = uipanel('Parent', fig, 'ResizeFcn', '');
                          %'Position',[0,0,600,100]%
                            
        
        hListbox = uicontrol('Parent', fig,...
                            'Style','List',...
                            'String',{},...
                            'units', 'normalized','Position',[0, 0, 1, 1],...
                            'FontName', 'Menlo',...
                            'FontWeight','normal',...
                            'FontAngle','normal',...
                            'FontUnits','points',...
                            'FontSize',9);

        
                       
        setappdata(0, 'hLogGui', fig);
        setappdata(fig, 'hListBox',hListbox);
        %setappdata(fig, 'hPanel',hPanel);
        
        set(fig, 'DeleteFcn', {@onclose});
        % Move the GUI to the center of the screen.
        movegui(fig,'southeast')
        % No menu bar
        set(fig,'MenuBar', 'None')
        % Make the GUI visible.
        set(fig,'Visible','on')
               
    end

    function update()
        
        indexItems = size(get(handles.hListBox,'String'), 1); %get how many items are in the list box
        set(handles.hListBox,'Value',indexItems);
        %set(handles.listbox1,'ListboxTop',indexItems); %set the index of last item to be the index of the top-most string
        drawnow;
    end


    function onclose(hObject,eventdata,handles)

        rmappdata(0,'hLogGui');
        delete(fig);
    
    end


end


