function [ output_args ] = serverd_Queue( input_args )
%SERVER_QUEUEGUI Summary of this function goes here
%   Detailed explanation goes here

data{end+1} = string2log;
set(handles.hListBox,'String', data);
update();

function update()

    indexItems = size(get(handles.hListBox,'String'), 1); %get how many items are in the list box
    set(handles.hListBox,'Value',indexItems);
    drawnow;
end

end


