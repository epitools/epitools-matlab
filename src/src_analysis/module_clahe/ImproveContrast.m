function ImproveContrast(stgObj)
%ImproveContrast Improve image contrast by applying CLAHE
%   CLAHE - Contrast-Limited Adaptive Histogram Equalization
%   DataSpecificsPath - Path Data to analyze (See InspectData function)

tic

tmpStgObj = stgObj.analysis_modules.Contrast_Enhancement.settings;
%load(DataSpecificsPath);

tmpRegObj = load([stgObj.data_analysisindir,'/RegIm']);
        
% -------------------------------------------------------------------------

log2dev('*********************** CLAHE MODULE **********************','INFO');
log2dev('* Authors: A.Tournier, A. Hoppe, D. Heller, L.Gatti       * ','INFO');
log2dev('* Revision: 0.1 beta    $ Date: 2014/09/02 11:37:00       *','INFO');
log2dev('***********************************************************','INFO');  
log2dev('Started clahe analysis module', 'INFO');
% -------------------------------------------------------------------------        
        
progressbar('Enhancing contrast...(please wait)');

%% assuming that images are either 8 or 16bit in input
if ~isa(tmpRegObj.RegIm, 'uint16') && ~isa(tmpRegObj.RegIm, 'uint8')
    error('Images should have either 8 bit or 16 bit pixel depth');
end

%pre-allocate output
RegIm_clahe = zeros(size(tmpRegObj.RegIm), class(tmpRegObj.RegIm));


%% Apply CLAHE

for i=1:size(tmpRegObj.RegIm,3)
    %parameter needs to be adapted for specific image input:
    
    RegIm_uint = tmpRegObj.RegIm(:,:,i);
    
    sizeX = size(tmpRegObj.RegIm,1);
    sizeY = size(tmpRegObj.RegIm,2);
    
    numTilesX = round(sizeX / tmpStgObj.enhancement_width);
    numTilesY = round(sizeY / tmpStgObj.enhancement_width);
    
    %todo, this needs to be adaptive for the image size
    %e.g. compute NumTiles based on a predifined size of tiling (e.g. 30px)
    RegIm_clahe_uint = adapthisteq(RegIm_uint,'NumTiles',[numTilesX numTilesY],'ClipLimit',tmpStgObj.enhancement_limit);
   
    RegIm_clahe(:,:,i) = RegIm_clahe_uint; 

    % -------------------------------------------------------------------------
    % Log status of current application status
    log2dev(sprintf('Local time point: %u | Progression: %0.2f',i,(i/size(tmpRegObj.RegIm,3))), 'DEBUG');
    % -------------------------------------------------------------------------

    progressbar(i/size(tmpRegObj.RegIm,3));
end

elapsedTime = toc;
% -------------------------------------------------------------------------
% Log status of current application status
log2dev(sprintf('Finished after %.2f', elapsedTime), 'DEBUG');
% -------------------------------------------------------------------------

progressbar(1);

% inspect results
if(~stgObj.exec_commandline)
    if(stgObj.icy_is_used)
        icy_vidshow(RegIm_clahe,'CLAHE Sequence');
        
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev('Display results of improve contrast module via IcyConnection ', 'DEBUG');
        % -------------------------------------------------------------------------

        
    else
        if(strcmp(stgObj.data_analysisindir,stgObj.data_analysisoutdir))
            
            fig = getappdata(0  , 'hMainGui');
            handles = guidata(fig);
            
            % Deactivate single frame window configuration
            
            set(handles.('figureA'), 'Visible', 'off');
            a3 = get(handles.('figureA'), 'Children');
            
            set(a3,'Visible', 'off');
            
            % Activate controls
            set(handles.('uiFrameSeparator'), 'Visible', 'on');
            set(handles.('uiBannerDescription'), 'Visible', 'on');
            set(handles.('uiBannerContenitor'), 'Visible', 'on');
            set(handles.('uiDialogBanner'), 'Visible', 'on');
            
            set(handles.('figureC1'), 'Visible', 'off');
            set(handles.('figureC2'), 'Visible', 'off');
            
            a1 = get(handles.('figureC1'), 'Children');
            a2 = get(handles.('figureC2'), 'Children');
            
            set(a1,'Visible', 'on');
            set(a2,'Visible', 'on');
            
            
            StackView(tmpRegObj.RegIm,'hMainGui','figureC1');
            StackView(RegIm_clahe,'hMainGui','figureC2');
            

           % Change banner description
            log2dev('Current analysis hold on module [CLAHE]',...
                'GUI',...
                2,...
                'hMainGui',...
                'uiBannerDescription');
            
            log2dev('Would you like to save the results obtained from running this analysis module?',...
                'GUI',...
                2,...
                'hMainGui',...
                'uiTextDialogBanner');
            
            log2dev('Accept result',...
                'GUI',...
                2,...
                'hMainGui',...
                'uiBannerDialog01');
            
            log2dev('Discard result',...
                'GUI',...
                2,...
                'hMainGui',...
                'uiBannerDialog02');
           
            
            % Set controls callbacks
            
            set(handles.('uiBannerDialog01'), 'Callback',{@ctrlAcceptResult_callback});
            set(handles.('uiBannerDialog02'), 'Callback',{@ctrlDiscardResult_callback});
            
            uiwait(fig);
            
            set(handles.('uiFrameSeparator'), 'Visible', 'off');
            set(handles.('uiBannerDescription'), 'Visible', 'off');
            set(handles.('uiBannerContenitor'), 'Visible', 'off');
            set(handles.('uiDialogBanner'), 'Visible', 'off');
            
                        
            set(handles.('figureC1'), 'Visible', 'off');
            set(handles.('figureC2'), 'Visible', 'off');
            
            a1 = get(handles.('figureC1'), 'Children');
            a2 = get(handles.('figureC2'), 'Children');
            
            set(a1,'Visible', 'off');
            set(a2,'Visible', 'off');
            
            
            
        else
            firstrun = load([stgObj.data_analysisindir,'/RegIm']);
            % The program is being executed in comparative mode
            StackView(firstrun.RegIm,'hMainGui','figureC1');
            StackView(RegIm_clahe,'hMainGui','figureC2');

          
            
        end
        
        % -------------------------------------------------------------------------
        % Log status of current application status
        log2dev('Display results of clahe module via @StackView ', 'DEBUG');
        % -------------------------------------------------------------------------
    end
else
    StackView(RegIm_clahe);
    saveClahe();
end

% Callback functions

    function out = ctrlAcceptResult_callback(hObject,eventdata,handles)
        
        out = 'Accept result';
        %backup previous result
        saveClahe();
        uiresume(fig);
        
        StackView(RegIm_clahe,'hMainGui','figureA');
        
    end

    function out = ctrlDiscardResult_callback(hObject,eventdata,handles)
        
        out = 'Discard result';
        setappdata(fig,'uidiag_userchoice', out);
        uiresume(fig);
        
        StackView(tmpRegObj.RegIm,'hMainGui','figureA');
        
    end

	function saveClahe()
	
		%save new version with contrast enhancement
		RegIm = RegIm_clahe;
		stgObj.AddResult('Contrast_Enhancement','clahe_path','RegIm_wClahe.mat');
		save([stgObj.data_analysisoutdir,'/RegIm_wClahe'],'RegIm');
	
	end

end