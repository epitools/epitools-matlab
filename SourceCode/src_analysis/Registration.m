function Registration(stgObj)
%Registration Registers image sequence in Time to correct for sample movement
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
%load(DataSpecificsPath);

tmpObj = load([stgObj.data_analysisindir,'/ProjIm']);
tmpStgObj = stgObj.analysis_modules.Stack_Registration.settings;
% if(~isfield(stgObj.,'useStackReg'))
%     stgObj.useStackReg = false;
% end


% -------------------------------------------------------------------------
% Log current application status
log2dev('******************* REGISTRATION MODULE *******************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.1 beta    $ Date: 2014/09/02 11:37:00       *','INFO');
log2dev('***********************************************************','INFO');
log2dev('Started projection analysis module ', 'INFO');
% -------------------------------------------------------------------------

if(tmpStgObj.useStackReg)
    RegIm = stackRegWrapper(tmpObj.ProjIm);
    
    % ---------------------------------------------------------------------
    % Log current application status
    log2dev('Projection redirected to stackRegWrapper ', 'DEBUG');
    % ---------------------------------------------------------------------
    
    
else
    progressbar('Registering images... (please wait)');
    
    % ---------------------------------------------------------------------
    % Log current application status
    log2dev('Projection redirected to @RegisterStack ', 'DEBUG');
    % ---------------------------------------------------------------------
    
    RegIm = RegisterStack(tmpObj.ProjIm,tmpStgObj);
    progressbar(1);
end


% inspect results
if ~stgObj.exec_commandline
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
            'GUI',...
             2,...
            'hMainGui',...
            'uiBannerDescription');
            
            StackView(RegIm,'hMainGui','figureA');
        
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
stgObj.AddResult('Stack_Registration','registration_path','RegIm.mat');
save([stgObj.data_analysisoutdir,'/RegIm'],'RegIm');

end

