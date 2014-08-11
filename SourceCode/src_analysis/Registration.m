function Registration(stgObj)
%Registration Registers image sequence in Time to correct for sample movement
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
%load(DataSpecificsPath);

tmpObj = load([stgObj.data_analysisindir,'/ProjIm']);
tmpStgObj = stgObj.analysis_modules.Stack_Registration.settings;
% if(~isfield(stgObj.,'useStackReg'))
%     stgObj.useStackReg = false;
% end

if(tmpStgObj.useStackReg)
    RegIm = stackRegWrapper(tmpObj.ProjIm);
else
    progressbar('Registering images... (please wait)');
    RegIm = RegisterStack(tmpObj.ProjIm,tmpStgObj);
    progressbar(1);
end


% inspect results
if stgObj.hasModule('Main')
    if(stgObj.icy_is_used)
        icy_vidshow(RegIm,'Registered Sequence');
    else
        StackView(RegIm,'hMainGui','figureA');
    end
else
    StackView(RegIm);
end



%saving results
stgObj.AddResult('Stack_Registration','registration_path',strcat(stgObj.data_analysisoutdir,'/RegIm'));
save([stgObj.data_analysisoutdir,'/RegIm'],'RegIm');

end

