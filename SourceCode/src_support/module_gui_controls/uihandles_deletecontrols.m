function uihandles_deletecontrols( input )
%UIHANDLES_DESTROYALL Summary of this function goes here
%   Detailed explanation goes here
hObject = getappdata(0, 'hMainGui');
hUIControls = getappdata(hObject,'hUIControls');


if(~isempty(hUIControls))

switch input
    case 'all'
        items = fields(hUIControls);
        for i=1:numel(items)

            delete(hUIControls.(char(items(i))));
            hUIControls = rmfield(hUIControls,char(items(i)));
        end
        
    otherwise
        
        if (isfield(hUIControls, input))
            
            delete(hUIControls.(char(input)));
        end
        
end
        
end  

setappdata(hObject,'hUIControls',hUIControls);

end

