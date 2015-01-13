function [status,argout] = dataexplorer_cmpview( input_args,varargin )
%dataexplore_cmpview This function shows comparative analysis on tags
% stored in server pools.
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function activates the comparative mode in the main EpiTools
% window. This allows for comparative mode and differential image analysis.
% The set up is given by scalable on window dimension and tag number. This
% function is not integrated in server-client function design, so it does
% not respect the standard conventions.
%
% INPUT
%   1. input_args:  variable containing the server pool addresses
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
% DATE:     8.12.14 V0.1 for EpiTools 2.0 beta
%
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the
% original author is referenced and attributed as such. The original author maintains the right
% to be solely associated with this work.

% Copyright by A.Tournier, A. Hoppe, D. Heller, L.Gatti
% ------------------------------------------------------------------------------
%% Retrieve supplementary arguments
if (nargin<2); varargin(1) = {'OUT1'}; end
%% Procedure initialization
status = 1;
%% Retrieve all the pool tags and check for comparisons
% This task look through all the active pools and collects tags and
% references through pool method getTag.
cmptable = {};
pool_instances = getappdata(input_args(1), 'pool_instances');
for i = 2:numel(pool_instances)
    for o = 1:numel(pool_instances(i).ref.tags)
        tmp = pool_instances(i).ref.getTag(char(pool_instances(i).ref.tags(o)));
        if strcmp(tmp.class,'graphics')
            if isempty(cmptable);cmptable{1} = tmp.uid; end
            if ~strcmp(cmptable(:,1),tmp.uid); cmptable{end+1,1} = tmp.uid; end
            for u = 1:numel(tmp.attributes.attribute)
                if strcmp(tmp.attributes.attribute(u).class,'file') || strcmp(tmp.attributes.attribute(u).class,'variable')
                    idx = sum(~cellfun(@isempty, cmptable(strcmp(cmptable(:,1),tmp.uid),:)));
                    cmptable{strcmp(cmptable(:,1),tmp.uid),idx+1} = tmp.attributes.attribute(u).path;
                end
            end
        end
    end
end
%% Desktop environment initialization.
% A new visualization panel is generated storing all the new identifiers in
% the list of graphic handles with the following format
% cmp_img_handle = graphic handle for images
% cmp_txt_handle = graphic handle for texts
% cmp_pnl_handle = graphic handle for panels
% Get dimentions parent panel
position = get(input_args(1), 'Position');
% Panel table preparation
count = size(cmptable,1)*(size(cmptable,2)-1);
if ~mod(count,2) == 0; count = count+1; end
% Graphic parameters
side_x = 0.19*position(3);
side_y = 0.05*position(4);
spacing_x = 3;
spacing_y = 1;
max_width = 50;
max_height = 25;
% Count categories and extract the other denominator
rows = size(cmptable,1);
columns = round(count/rows);
% Computing box dimensions
width   = (position(3) - side_x - (columns*spacing_x))/columns;
height    = (position(4) - side_y - (rows*spacing_y))/rows;
if width > max_width; width = max_width;end
if height > max_height; height = max_height;end
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
        ghandle(idxpanels).panel = uipanel('Parent',input_args(1),'FontSize',10,...
            'BackgroundColor', [0.1608    0.2706    0.5961],...
            'Visible', 'off',...
            'ButtonDownFcn', {@PanelSelectionCallback,idxpanels, i, o},...
            'Position',[pos_x pos_y width height]);
        ghandle(idxpanels).header =  uicontrol('Style','text',...
            'Parent', ghandle(idxpanels).panel,...
            'Units', 'normalized',...
            'Position',[0.005 .90 0.995 0.10],...
            'BackgroundColor', [0.1608    0.2706    0.5961],...
            'ForegroundColor', [1    1    1.0000],...
            'FontUnits','normalized',...
            'FontSize',0.4,...
            'FontWeight', 'bold',...
            'FontName','SansSerif',...
            'HorizontalAlignment', 'left',...
            'String',strcat('Image ', num2str(idxpanels)));
        ghandle(idxpanels).axes =  axes('Parent', ghandle(idxpanels).panel,...
            'Units', 'normalized',...
            'Position',[0.075 .075 0.85 0.85]);
        ghandle(idxpanels).footer =  uicontrol('Style','text',...
            'Parent', ghandle(idxpanels).panel,...
            'Units', 'normalized',...
            'Position',[0.005 0 0.905 0.05],...
            'BackgroundColor', [0.1608    0.2706    0.5961],...
            'ForegroundColor', [1    1    1.0000],...
            'FontUnits','normalized',...
            'FontSize',0.7,...
            'FontWeight', 'bold',...
            'FontName','SansSerif',...
            'HorizontalAlignment', 'left',...
            'String',strcat('Charateristics ', num2str(idxpanels)));
        ghandle(idxpanels).selected = axes('Parent', ghandle(idxpanels).panel,...
                                           'Units', 'normalized',...
                                           'Visible', 'off',...
                                           'Position',[0.94 0 0.06 0.06]);
    end
end
%% Fill Panels
% per each Tag category in the table
idxcount = 0;
% Status operations
min = 0; max=size(cmptable,1)*(size(cmptable,2)-1); value=0;
log2dev('Preparing comparative display...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
try
    for idxRow = size(cmptable,1):-1:1
        for idxCol = size(cmptable,2):-1:2
            if(~isempty(cmptable{idxRow,idxCol}))
                [~,~,ext] = fileparts(cmptable{idxRow,idxCol});
                if(strcmp(ext,'.mat'))
                    try
                        tmp_im = load(cmptable{idxRow,idxCol});
                        if(isa(tmp_im,'struct'));fields_struct = fields(tmp_im);end
                        for i=1:numel(fields_struct)
                            if isa(tmp_im.(char(fields_struct(i))), 'uint8') || isa(tmp_im.(char(fields_struct(i))), 'uint16')
                                    im = tmp_im.(char(fields_struct(i)));
                                    tmpclass = class(tmp_im.(char(fields_struct(i))));
                                    tmpclass = strrep(tmpclass, 'uint', '');
                                    infoIMG.BitDepth = str2double(tmpclass);
                                    infoIMG.Width = size(tmp_im.(char(fields_struct(i))),2);
                                    infoIMG.Height = size(tmp_im.(char(fields_struct(i))),1);
                                    imshow(im(:,:,1), 'Parent', ghandle(numel(ghandle)-idxcount).axes);
                                    set(ghandle(numel(ghandle)-idxcount).panel, 'Visible', 'on');
                            end
                        end 
                    catch err
                        log2dev(sprintf('EPITOOLS:dataexplorer_cmpview:FillPanels:LoadMatFiles | %s',err.message),'WARN');
                    end
                else
                    try
                        infoIMG = imfinfo(cmptable{idxRow,idxCol});
                        imshow(cmptable{idxRow,idxCol}, 'Parent', ghandle(numel(ghandle)-idxcount).axes);
                    catch err
                        log2dev(sprintf('EPITOOLS:dataexplorer_cmpview:FillPanels:LoadImgFiles | %s',err.message),'WARN');
                    end
                end
                set(ghandle(numel(ghandle)-idxcount).footer, 'String', sprintf('Serie %u | %ux%u | %u bit',...
                    idxCol-1, ...
                    infoIMG.Width, ...
                    infoIMG.Height,...
                    infoIMG.BitDepth));
                set(ghandle(numel(ghandle)-idxcount).header, 'String', cmptable(idxRow,1));            
            else
                set(ghandle(numel(ghandle)-idxcount).panel, 'Visible', 'off');
            end
            % Status operations
            value = value + 1;
            log2dev('Preparing comparative display...','INFO',0,'hMainGui', 'statusbar',{min,max,value});
            %External counter
            idxcount = idxcount + 1;
        end
    end
catch err
    log2dev(sprintf('EPITOOLS:dataexplorer_cmpview:FillPanels:Generic | %s',err.message),'WARN');
end
%% Output formatting
% Each single output need to be described in order to be used for variable exportation.
% ARGOUT variable is a structure object
% argout(1...).description = char();
% argout(1...).ref = variable reference;
% argout(1...).object = undefined;
% First output variable
argout(1).description = 'GraphicHandleCmpDisplay';
argout(1).ref = varargin(1);
argout(1).object = ghandle;
%% Status execution update
status = 0;
    % --------------------------------------------------------------------
    %% CallBack Funtions
    function idPanel = PanelSelectionCallback(src, eventdata, idx, row, column)
    % This function retrieve the id of the selected panel and computes the
    % comparative statistics along the category row
    %% Comparison table
    % Per each group, a comparison image is computed comparing the reference
    % image with the other in the group. Image differences is computed but not
    % visualized. A statistic is generated in order to define significance
    % changes between samples.
    % Initialization of image controls
    for id = 2:numel(cmptable(row,:))
        idux = (size(cmptable,2)-1)*(row-1)+(id-1);
        set(ghandle(idux).header, 'String', cmptable{row,1});
        set(ghandle(idux).header, 'BackgroundColor', [0.1608    0.2706    0.5961]);
        set(ghandle(idux).footer, 'BackgroundColor', [0.1608    0.2706    0.5961]);
        set(ghandle(idux).panel, 'BackgroundColor', [0.1608    0.2706    0.5961]);
        delete(get(ghandle(idux).selected,'Children'))
    end
    % Add selected mark to current panel
    if(isempty(get(ghandle(idx).selected,'Children')))
        A = imread('images/icons/rosette.png');
        A(A==255) = NaN;
        imshow(A,'Parent',ghandle(idx).selected);
        set(ghandle(idx).header, 'BackgroundColor', [0.1176    0.2000    0.4392]);
        set(ghandle(idx).footer, 'BackgroundColor', [0.1176    0.2000    0.4392]);
        set(ghandle(idx).panel, 'BackgroundColor', [0.1176    0.2000    0.4392]);
    end
    % Loop along the other samples on the row % Please add recursive for
    % all time frames
    for id = 2:numel(cmptable(row,:))
        if id == column+1 || isempty(cmptable{row,id}); continue;end
        im_reference = imread(cmptable{row,column+1});
        im_sample = imread(cmptable{row,id});
        imdiff = size(find(imabsdiff(im_reference, im_sample)),1);
        log2dev(sprintf('Pixel difference between %u and %u is: %1.4g\n', column, id-1, imdiff/prod(size(im_sample))),'DEBUG');
        if(imdiff/prod(size(im_sample))>0.01)
            A = imread('images/icons/exclamation_octagon_fram.png');
            A(A==255) = NaN;
            idux = (size(cmptable,2)-1)*(row-1)+(id-1);
            set(ghandle(idux).header, 'String', sprintf('%s var %1.4g',cmptable{row,1},imdiff/prod(size(im_sample))));
            imshow(A,'Parent',ghandle(idux).selected);
        end
    end
    idPanel = idx;
    end
end