function uihandles_savecontrols( tag,control )
%UIHANDLES_SAVECONTROLS Summary of this function goes here
%   Detailed explanation goes here

hObject = getappdata(0, 'hMainGui');
hUIControls = getappdata(hObject,'hUIControls');

hUIControls.(char(tag)) = control;

setappdata(hObject,'hUIControls',hUIControls);



end

