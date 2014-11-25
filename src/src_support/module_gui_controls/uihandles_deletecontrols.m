function uihandles_deletecontrols( input )
%UIHANDLES_DESTROYALL Summary of this function goes here
%   Detailed explanation goes here
hObject = getappdata(0, 'hMainGui');
hUIControls = getappdata(hObject,'hUIControls');


if(~isempty(hUIControls))

switch input
    case 'all'
        items = fields(hUIControls);
        if(~isempty(items))
        for i=1:numel(items)
            try
            delete(hUIControls.(char(items(i))));
            catch
            end
            hUIControls = rmfield(hUIControls,char(items(i)));
        end
        end
    otherwise
        
        if (isfield(hUIControls, input))
            try
            delete(hUIControls.(char(input)));
            catch
            end
            hUIControls = rmfield(hUIControls,char(input));
            
        end
        
        
end
        
end  

setappdata(hObject,'hUIControls',hUIControls);

end

