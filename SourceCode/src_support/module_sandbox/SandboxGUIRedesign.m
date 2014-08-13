function SandboxGUIRedesign( intStatus )
%SANDOBOXGUIREDESIGN Summary of this function goes here
%   Detailed explanation goes here
fig = getappdata(0  , 'hMainGui');
handles = guidata(fig);

setappdata(fig,'uidiag_userchoice', '');

switch intStatus
    case 0
        
        set(fig, 'Color', [0.5020 0.5020 0.5020]);
        
        % Deactivate controls
        set(handles.('uiFrameSeparator'), 'Visible', 'off');
        set(handles.('figureC1'), 'Visible', 'off');
        set(handles.('figureC2'), 'Visible', 'off');
        set(handles.('uiDialogBanner'), 'Visible', 'off');
        set(handles.('uiBannerDescription'), 'Visible', 'off');
        set(handles.('uiBannerContenitor'), 'Visible', 'off');
        
        a1 = get(handles.('figureC1'), 'Children');
        a2 = get(handles.('figureC2'), 'Children');
        
        set(a1,'Visible', 'off');
        set(a2,'Visible', 'off');
        
        % Activate controls
        
        %set(handles.('figureA'), 'Visible', 'off');
        %a3 = get(handles.('figureA'), 'Children');
        
        %set(a3,'Visible', 'on');
  
    case 1
        
        
        set(fig, 'Color', [1 0 0]);
        
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
        
        
        % Change banner description
        log2dev('Comparative analysis on current sample for module',...
            'hMainGui',...
            'uiBannerDescription',...
            [],...
            2 );
        
        log2dev('Would you like to save the results obtained from the comparative run of the analysis module?',...
            'hMainGui',...
            'uiTextDialogBanner',...
            [],...
            2);
        
        log2dev('Accept result',...
            'hMainGui',...
            'uiBannerDialog01',...
            [],...
            2 );
        
        log2dev('Discard result',...
            'hMainGui',...
            'uiBannerDialog02',...
            [],...
            2 );
        
        
        % Set controls callbacks
        
        set(handles.('uiBannerDialog01'), 'Callback',{@ctrlAcceptResult_callback});
        set(handles.('uiBannerDialog02'), 'Callback',{@ctrlDiscardResult_callback});
        
        uiwait(fig);
        
end

% Callback functions

    function out = ctrlAcceptResult_callback(hObject,eventdata,handles)
        
        out = 'Accept result';
        setappdata(fig,'uidiag_userchoice', out);
        uiresume(fig);
    end

    function out = ctrlDiscardResult_callback(hObject,eventdata,handles)
        
        out = 'Discard result';
        setappdata(fig,'uidiag_userchoice', out);
        uiresume(fig);
        
    end


end

