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
        
        if(strcmp(stgObj.data_analysisindir,stgObj.data_analysisoutdir))
            
            fig = getappdata(0  , 'hMainGui');
            handles = guidata(fig);
            
            set(handles.('uiBannerDescription'), 'Visible', 'on');
            set(handles.('uiBannerContenitor'), 'Visible', 'on');
            
            % Change banner description
            log2dev('Currently executing the [Registration] module',...
            'hMainGui',...
            'uiBannerDescription',...
            [],...
            2 );
            
            StackView(RegIm,'hMainGui','figureA');
            SandboxGUIRedesign(0);
        
        else
            firstrun = load([stgObj.data_analysisindir,'/RegIm']);
            % The program is being executed in comparative mode
            StackView(firstrun.RegIm,'hMainGui','figureC1');
            StackView(RegIm,'hMainGui','figureC2');
            
        end

   end
else
    StackView(RegIm);
end



%saving results
stgObj.AddResult('Stack_Registration','registration_path',strcat(stgObj.data_analysisoutdir,'/RegIm'));
save([stgObj.data_analysisoutdir,'/RegIm'],'RegIm');

end

