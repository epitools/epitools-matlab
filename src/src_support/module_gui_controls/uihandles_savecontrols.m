function uihandles_savecontrols( tag,control )
%UIHANDLES_SAVECONTROLS Summary of this function goes here
%   Detailed explanation goes here
hObject = getappdata(0, 'hMainGui');
hUIControls = getappdata(hObject,'hUIControls');

rng('shuffle');

if(isfield(hUIControls, char(tag)))
    
    tag = strcat(char(tag),num2str(randi(1000,1)));

end

hUIControls.(char(tag)) = control;

setappdata(hObject,'hUIControls',hUIControls);



end

