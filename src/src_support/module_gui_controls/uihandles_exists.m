function out = uihandles_exists( input )
%UIHANDLES_DESTROYALL Summary of this function goes here
%   Detailed explanation goes here
hObject = getappdata(0, 'hMainGui');
hUIControls = getappdata(hObject,'hUIControls');

out = false;
if(~isempty(hUIControls))
    if(~isempty(hUIControls))
        if (isfield(hUIControls, input))
            out = true;
        end
    end  
end
end

