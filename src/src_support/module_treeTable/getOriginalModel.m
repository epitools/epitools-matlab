%% Get the basic JTable data model
function originalModel = getOriginalModel(jtable)
    originalModel = jtable.getModel;
    try
        while(true)
            originalModel = originalModel.getActualModel;
        end;
    catch
        a=1;  % never mind - bail out...
    end
end  % getOriginalModel