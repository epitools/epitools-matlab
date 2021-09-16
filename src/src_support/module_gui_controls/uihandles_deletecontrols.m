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
                if isa(hUIControls.(char(items(i))),'struct')
                    for o=1:numel(hUIControls.(char(items(i))))
                            
                            delete(hUIControls.(char(items(i)))(o).panel);

                    end
                else
                    try
                        delete(hUIControls.(char(items(i))));
                    catch err
                        log2dev(sprintf('EPITOOLS:uihandles_deletecontrols:RemovingHandlesNotSuccesfull | %s',...
                                        err.message),...
                                'ERR');

                    end
                end
                hUIControls = rmfield(hUIControls,char(items(i)));
            end
        end
    otherwise       
        if (isfield(hUIControls, input))
            if isa(hUIControls.(char(input)),'struct')
                for i=1:numel(hUIControls.(char(input)))
                    if isempty(fields(hUIControls.(char(input))))
                        hUIControls = rmfield(hUIControls,char(input));
                        setappdata(hObject,'hUIControls',hUIControls);
                    else
                        delete(hUIControls.(char(input))(i).panel); 
                    end
                end
            else
                try
                    delete(hUIControls.(char(input)));
                catch err
                    log2dev(sprintf('EPITOOLS:uihandles_deletecontrols:RemovingHandlesNotSuccesfull | %s',...
                                                        err.message),...
                                               'ERR');
                end 
            end 
            try
                hUIControls = rmfield(hUIControls,char(input)); 
            catch err
                    log2dev(sprintf('EPITOOLS:uihandles_deletecontrols:RemovingHandlesNotSuccesfull | %s',...
                                                        err.message),...
                                               'ERR');
            end
        end
        
end
        
end  

setappdata(hObject,'hUIControls',hUIControls);

end

