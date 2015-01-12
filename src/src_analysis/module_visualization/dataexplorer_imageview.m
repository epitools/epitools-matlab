function [status,argout] = dataexplorer_imageview( input_args,varargin )
%dataexplore_cmpview This function shows comparative analysis on tags
% stored in server pools.
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function activates the single view mode in the main EpiTools
% window. The set up is given by scalable on window dimension and tag number. This
% function is not integrated in server-client function design, so it does
% not respect the standard conventions.
%
% INPUT
%   1. input_args(1):  variable containing the window graphic handle
%   2. input_args(2):  cell containing image filepaths
%   3. input_args(3):  cell containing image descriptions
%   4. varargin:  additional graphic parameters as
%                 [1] 'Comparative', 1;
%
% OUTPUT
%   1. status:  status elaboration (0  executed correctly; > 0 fatal error)
%   2. argout:  variable containing a structure with output objects, description
%               and ref association
%
% REFERENCES
%
% AUTHOR:   Lorenzo Gatti (lorenzo.gatti@alumni.ethz.ch)
%
% DATE:     18.12.14 V0.1 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.
%
% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
%% Retrieve supplementary arguments
if (nargin<2); varargin(1) = {'OUT1'};else graphic_pars=varargin{1}; end
%% Procedure initialization
status = 1;
%% Retrieve all the pool and graphics tags
cmptable = input_args{2};
categories = input_args{3};
%% Desktop environment initialization.
% Get dimentions parent panel
position = get(input_args{1}, 'Position');
% Graphic parameters
side_x = 0.19*position(3);
side_y = 0.05*position(4);
spacing_x = 3;
spacing_y = 1;
max_width = 50;
max_height = 25;
% Count categories and extract the other denominator
rows = size(cmptable,1);
columns = size(cmptable,2);
% Computing box dimensions
width   = (position(3) - side_x - (columns*spacing_x))/columns;
height    = (position(4) - side_y - (rows*spacing_y))/rows;
%if width > max_width; width = max_width;end
%if height > max_height; height = max_height;end
%high    = (position(4)/(rows))-(spacing_y*(rows)) - spacing_y;
width   = width/position(3);
height    = height/position(4);
side_x  = side_x/position(3);
side_y  = side_y/position(4);
% Prepare Panels
ghandle = struct();
idxpanels = 0;
for i=1:rows % tag categories
    pos_y = 1 - ((height +((spacing_y)/position(4))) * (i));
    for o=1:columns % samples
        pos_x = (((width+(spacing_x/position(3))) * (o-1) + side_x));
        idxpanels = idxpanels +1;
        % ---------------------------------------------
        ghandle(idxpanels).panel = uipanel(getappdata(0,'hMainGui'), ...
            'units'    ,'normalized', ...
            'BackgroundColor', [0.6667    0.6667    0.6667],...
            'position' ,[pos_x pos_y width height]);
        % ---------------------------------------------
        ghandle(idxpanels).top = uipanel(ghandle(idxpanels).panel,...
            'units'    ,'normalized', ...
            'position' ,[0.00 0.965 1 0.035]);
        % ---------------------------------------------
        ghandle(idxpanels).controls = uipanel(ghandle(idxpanels).panel,...
            'units'    ,'normalized', ...
            'position' ,[0.00 0.025 1 0.035]);
        % ---------------------------------------------
        ghandle(idxpanels).status = uipanel(ghandle(idxpanels).panel,...
            'units'    ,'normalized', ...
            'BackgroundColor', [0.3059    0.3961    0.5804],...
            'position' ,[0.00 0.0 1 0.025]);
        % ---------------------------------------------
        % ---------------------------------------------
        ghandle(idxpanels).screeshot = uicontrol(ghandle(idxpanels).top,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.0 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).screeshot);
        myIcon = fullfile('images/gif/monitor.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        
        ghandle(idxpanels).zoomin = uicontrol(ghandle(idxpanels).top,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.05 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).zoomin);
        myIcon = fullfile('images/gif/zoom_in.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        
        ghandle(idxpanels).zoomout = uicontrol(ghandle(idxpanels).top,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.1 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).zoomout);
        myIcon = fullfile('images/gif/zoom_out.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        
        ghandle(idxpanels).hand = uicontrol(ghandle(idxpanels).top,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.15 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).hand);
        myIcon = fullfile('images/gif/hand_point.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        
        ghandle(idxpanels).info = uicontrol(ghandle(idxpanels).top,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.20 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).info);
        myIcon = fullfile('images/gif/information.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        
        ghandle(idxpanels).quit = uicontrol(ghandle(idxpanels).top,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.95 0 0.05 1],...
            'Callback', @(src,evt)  uihandles_deletecontrols( 'GraphicHandleSingleVDisplay' ));
        jButton = findjobj(ghandle(idxpanels).quit);
        myIcon = fullfile('images/gif/cross_octagon.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        % ---------------------------------------------
        ghandle(idxpanels).start = uicontrol(ghandle(idxpanels).controls,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.0 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).start);
        myIcon = fullfile('images/gif/control_start_blue.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        set(ghandle(idxpanels).start,'Callback',{@CallBack_Start,idxpanels});
        
        ghandle(idxpanels).rewind = uicontrol(ghandle(idxpanels).controls,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.05 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).rewind);
        myIcon = fullfile('images/gif/control_rewind_blue.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        set(ghandle(idxpanels).rewind,'Callback',{@CallBack_Rewind,idxpanels});
        
        ghandle(idxpanels).stop = uicontrol(ghandle(idxpanels).controls,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.1 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).stop);
        myIcon = fullfile('images/gif/control_stop_blue.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        set(ghandle(idxpanels).stop,'Callback',{@CallBack_Stop,idxpanels});
        
        ghandle(idxpanels).play = uicontrol(ghandle(idxpanels).controls,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.15 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).play);
        myIcon = fullfile('images/gif/control_play_blue.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        set(ghandle(idxpanels).play,'Callback',{@CallBack_Play,idxpanels});
        
        ghandle(idxpanels).fastforward = uicontrol(ghandle(idxpanels).controls,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.20 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).fastforward);
        myIcon = fullfile('images/gif/control_fastforward_blue.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        set(ghandle(idxpanels).fastforward,'Callback',{@CallBack_FastForward,idxpanels});
        
        ghandle(idxpanels).end = uicontrol(ghandle(idxpanels).controls,...
            'Style','pushbutton',...
            'units'    ,'normalized', ...
            'position' ,[0.25 0 0.05 1]);
        jButton = findjobj(ghandle(idxpanels).end);
        myIcon = fullfile('images/gif/control_end_blue.gif');
        jButton.setIcon(javax.swing.ImageIcon(myIcon));
        set(ghandle(idxpanels).end,'Callback',{@CallBack_End,idxpanels});
        
        ghandle(idxpanels).slider = uicontrol(ghandle(idxpanels).controls,...
            'Style','slider',...
            'units'    ,'normalized', ...
            'position' ,[0.32 0 0.50 0.65]);
        
        ghandle(idxpanels).sliderlistener = addlistener(ghandle(idxpanels).slider,'ContinuousValueChange',@(src,evt) sliderActionEventCb(src,evt, idxpanels));
        
        ghandle(idxpanels).frameinfo = uicontrol(ghandle(idxpanels).controls,...
            'Style','text',...
            'String','Frame x of y',...
            'units'    ,'normalized', ...
            'FontName','Lucida Grande',...
            'FontUnits','normalized',...
            'FontSize',0.9,...
            'position' ,[0.84 0.35 0.15 0.53]);
        % ---------------------------------------------
        ghandle(idxpanels).categoryinfo = uicontrol(ghandle(idxpanels).status,...
            'Style','text',...
            'String','Unknown Category',...
            'HorizontalAlignment', 'left',...
            'units'    ,'normalized', ...
            'FontName','Lucida Grande',...
            'FontUnits','normalized',...
            'FontSize',0.8,...
            'ForegroundColor', [1 1 1], ...
            'BackgroundColor', [0.3059    0.3961    0.5804],...
            'position' ,[0.0 0.25 0.25 0.8]);
        
        ghandle(idxpanels).planeinfo = uicontrol(ghandle(idxpanels).status,...
            'Style','text',...
            'String','Plane informations',...
            'HorizontalAlignment', 'right',...
            'units'    ,'normalized', ...
            'FontName','Lucida Grande',...
            'FontUnits','normalized',...
            'FontSize',0.8,...
            'ForegroundColor', [1 1 1], ...
            'BackgroundColor', [0.3059    0.3961    0.5804],...
            'position' ,[0.70 0.25 0.298 0.8]);
        if ~isempty(graphic_pars)
            if graphic_pars{strcmp(graphic_pars,'Comparative'),find(strcmp(graphic_pars,'Comparative'))+1}
                set(ghandle(idxpanels).status, 'BackgroundColor', [0.8000    0.2000         0]);
                set(ghandle(idxpanels).planeinfo, 'BackgroundColor', [0.8000    0.2000         0]);
                set(ghandle(idxpanels).categoryinfo, 'BackgroundColor', [0.8000    0.2000         0]);
            end
        end
        % ---------------------------------------------
        ghandle(idxpanels).axes = axes('Parent',ghandle(idxpanels).panel,...
            'Visible', 'off',...
            'units'    ,'normalized', ...
            'position' ,[0.0 0.06 1 0.905]);
    end
end
%% Fill Panels
% Status operations
min = 0; max=(size(cmptable,2)); value=0;
log2dev('Preparing display...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
for i=1:size(cmptable,2)
    fillImgPanel(1,i)
    % Status operations
    value = value + 1;
    log2dev('Preparing display...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
end
log2dev('Image display ready','INFO',0,'hMainGui', 'statusbar',{0,max,max});
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
argout(1).description = 'GraphicHandleSingleVDisplay';
argout(1).ref = varargin(1);
argout(1).object = ghandle;
%% Status execution update
status = 0;
% --------------------------------------------------------------------
%% CallBack Funtions
    function CallBack_Start(src,evt,idx); fillImgPanel(1,idx); end
    function CallBack_Rewind(src,evt,idx)
        % Get current frame
        currframenum = get(ghandle(idx).slider,'Value');
        if (currframenum-1) < 1; new_framenum = 1; else new_framenum = currframenum -1;end
        fillImgPanel(new_framenum,idx);
    end
    function CallBack_Play(src,evt,idx)
    end
    function CallBack_Stop(src,evt,idx)
    end
    function CallBack_FastForward(src,evt,idx)
        % Get current frame
        currframenum    = get(ghandle(idx).slider,'Value');
        upperframebound = get(ghandle(idx).slider,'max');
        if (currframenum+1 < upperframebound); new_framenum = currframenum+1; else new_framenum = upperframebound;end
        fillImgPanel(new_framenum,idx);
    end
    function CallBack_End(src,evt,idx); 
        % Get max frame
        upperframebound = get(ghandle(idx).slider,'max');
        fillImgPanel(upperframebound,idx);
    end
    function sliderActionEventCb(src,evt,idx)
        % Get the new position
        new_framenum = round(get(src,'Value'));
        % If the slider has not been moved or the moving step was too short
        %if new_framenum == i; return; end %i = newi;
        %set(src,'Value',new_framenum);
        fillImgPanel(new_framenum,idx)
    end
    function fillImgPanel(framenum,idpanel)
        try
            img = load(cmptable{idpanel});obj = fieldnames(img);Is=img.(char(obj));
            switch numel(size(Is))
                case 2 % Single frame
                    im = Is(:,:);
                    q = quantile(single(im(:)),[.001 .999]);
                    im(im<q(1)) = q(1);
                    im(im>q(2)) = q(2);
                    imshow(im,[],'Parent', ghandle(idpanel).axes);
                    % Set Frame informations
                    set(ghandle(idpanel).frameinfo,'String',sprintf('Frame %u of %u',1,1));
                    % Set Plane informations
                    set(ghandle(idpanel).planeinfo,'String',sprintf('%ux%u, %s',size(Is,1),size(Is,2),class(Is)));
                    % Set Category informations
                    set(ghandle(idpanel).categoryinfo,'String',categories{idpanel});
                    % Set slider
                    set(ghandle(idpanel).slider,'max', 1);
                    set(ghandle(idpanel).slider,'min', 1);
                    set(ghandle(idpanel).slider,'Value', 1);
                    set(ghandle(idpanel).slider, 'SliderStep', [1 1]);
                case 3 % TimeLapse
                    im = Is(:,:,framenum);
                    q = quantile(single(im(:)),[.001 .999]);
                    im(im<q(1)) = q(1);
                    im(im>q(2)) = q(2);
                    imshow(im,[],'Parent', ghandle(idpanel).axes);
                    % Set Frame informations
                    set(ghandle(idpanel).frameinfo,'String',sprintf('Frame %u of %u',framenum,size(Is,3)));
                    % Set Plane informations
                    set(ghandle(idpanel).planeinfo,'String',sprintf('%ux%u, %s',size(Is,1),size(Is,2),class(Is)));
                    % Set Category informations
                    set(ghandle(idpanel).categoryinfo,'String',categories{idpanel});
                    % Set slider
                    set(ghandle(idpanel).slider,'max', size(Is,3));
                    set(ghandle(idpanel).slider,'min', 1);
                    set(ghandle(idpanel).slider,'Value', framenum);
                    set(ghandle(idpanel).slider, 'SliderStep', [1 1]);
                case 4 %Multichannel
                    if size(Is,3) == 3
                        imshow(squeeze(Is(:,:,:,1)),[],'Parent', ghandle(idpanel).axes);
                    else
                        %image might have 3 color channels on another dimension
                        if size(Is,4) == 3
                            imshow(squeeze(Is(:,:,framenum,:)),[],'Parent', ghandle(idpanel).axes);
                        end
                    end
            end
        catch err
            log2dev(sprintf('EPITOOLS:dataexplorer_imageview:FillPanels:Generic | %s',err.message),'WARN');
        end
    end
end