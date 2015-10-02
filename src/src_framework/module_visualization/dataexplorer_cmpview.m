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
reftable = {};
pool_instances = getappdata(input_args(1), 'pool_instances');
for i = 2:numel(pool_instances)
    arrPoolNames{i-1} = pool_instances(i).ref.name;
    for o = 1:numel(pool_instances(i).ref.tags)
        tmp = pool_instances(i).ref.getTag(char(pool_instances(i).ref.tags(o)));
        if strcmp(tmp.class,'graphics')
            if isempty(cmptable);cmptable{1} = tmp.uid; reftable{1} = tmp.uid; end
            if ~strcmp(cmptable(:,1),tmp.uid); cmptable{end+1,1} = tmp.uid; reftable{end+1,1} = tmp.uid; end
            for u = 1:numel(tmp.attributes.attribute)
                if strcmp(tmp.attributes.attribute(u).class,'file') || strcmp(tmp.attributes.attribute(u).class,'variable')
                    idx = sum(~cellfun(@isempty, cmptable(strcmp(cmptable(:,1),tmp.uid),:)));
                    cmptable{strcmp(cmptable(:,1),tmp.uid),idx+1} = tmp.attributes.attribute(u).path;
                    reftable{strcmp(reftable(:,1),tmp.uid),idx+1} = i;
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
if count == 1; 
    count = 1; 
elseif ~size(cmptable,1) == 1
    if ~mod(count,2) == 0; 
        count = count+1;  
    end
end
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
            'HitTest','Off',...
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
                                    him = imshow(im(:,:,1), 'Parent', ghandle(numel(ghandle)-idxcount).axes);
                                    set(him,'HitTest','off');
                                    %% Contextual menu on axes 
                                    hcmenu = uicontextmenu;
                                    item0 = uimenu(hcmenu,...
                                                   'Label','<html><b>Move current result to pool:</b></html>',...
                                                   'Enable','off');
                                    %for idxPD = 1:numel(arrPoolNames)
                                    idxPD = 1;
                                    uimenu(hcmenu,'Label',sprintf('[%s] %s',num2str(idxPD),arrPoolNames{idxPD}),...
                                        'Callback', {@moveTag2NewPool,cmptable{idxRow,1},idxPD,numel(ghandle)-idxcount, idxRow, idxCol});
                                    %uimenu(hcmenu,'Label',arrPoolDesc{idxPD});
                                    %end
                                    item3 = uimenu(hcmenu,...
                                                   'Label','<html><b>Comparative mode </b></html>',...
                                                   'Separator','on',...
                                                   'Enable','off');
                                    item5 = uimenu(hcmenu,...
                                                   'Label','<html>Select this result as reference </html>',...
                                                   'Callback', {@SelectionRefCallback,numel(ghandle)-idxcount, idxRow, idxCol});
                                    item6 = uimenu(hcmenu,...
                                                   'Label','<html>Compare with original image</html>',...
                                                   'Callback', {@compareSelectionWithOriginal,cmptable{idxRow,1},idxPD,numel(ghandle)-idxcount, idxRow, idxCol});
                                    item7 = uimenu(hcmenu,...
                                                   'Label','<html><b>Panel information</b></html>',...
                                                   'Separator','on',...
                                                   'Enable','off');
                                    item8 = uimenu(hcmenu,...
                                                   'Label','<html>Inspect analysis metadata</html>',...
                                                   'Callback', {@SelectionAnalysisMetadataCallback,numel(ghandle)-idxcount, idxRow, idxCol});
                                    item9 = uimenu(hcmenu,...
                                                   'Label',sprintf('Panel: %i',numel(ghandle)-idxcount),...
                                                   'Enable','off');
                                    set(ghandle(numel(ghandle)-idxcount).panel,'uicontextmenu',hcmenu)
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
                tag = pool_instances(reftable{idxRow,idxCol}).ref.getTag(cmptable(idxRow,1));
                poolname = sprintf('%s - %s',cmptable{idxRow,1},datestr(tag.timestamp,31));
                set(ghandle(numel(ghandle)-idxcount).header, 'String', poolname);            
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
    function idPanel = SelectionRefCallback(src, eventdata, idpanel, row, column) 
            %% Comparison table
            % This function retrieve the id of the selected panel and computes the
            % comparative statistics along the category row
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
                set(ghandle(idux).panel,  'BackgroundColor', [0.1608    0.2706    0.5961]);
                delete(get(ghandle(idux).selected,'Children'))
            end
            % Add selected mark to current panel
            if(isempty(get(ghandle(idpanel).selected,'Children')))
                A = imread('images/icons/rosette.png'); A(:,:,4) = A(:,:,1);
                h = imshow(A(:,:,1:3),'Parent',ghandle(idpanel).selected); set(h, 'AlphaData', A(:,:,4));
                set(ghandle(idpanel).header, 'BackgroundColor', [0.1176    0.2000    0.4392]);
                set(ghandle(idpanel).footer, 'BackgroundColor', [0.1176    0.2000    0.4392]);
                set(ghandle(idpanel).panel,  'BackgroundColor', [0.1176    0.2000    0.4392]);
            end
            % Load reference image from cmptable (independent from the loop)
            %cmptable(row,~cellfun(@isempty,cmptable(row,:)))
            if row > 1; idpanel = idpanel-(size(cmptable,2)*(row-1)-1);end
                [~,~,ext] = fileparts(cmptable{row,column});
                if(strcmp(ext,'.mat'))
                    im_reference = load(cmptable{row,column});
                    im_reference = im_reference.(char(fieldnames(im_reference)));
                else
                    im_reference = imread(cmptable{row,column});
                end
            % Loop along the other samples on the same row 
            % TODO: Add recursive difference computation for all time frames if any
            for id = 2:numel(cmptable(row,:))
                % Skip comparison with the reference or empty cells
                if id == column || isempty(cmptable{row,id}); continue; end
                % Load sample images from cmptable
                [~,~,ext] = fileparts(cmptable{row,id});
                if(strcmp(ext,'.mat'))
                    im_sample = load(cmptable{row,id});
                    im_sample = im_sample.(char(fieldnames(im_sample)));
                else
                    im_sample = imread(cmptable{row,id});
                end
                % Compute the difference
                imdiff = size(find(imabsdiff(im_reference, im_sample)),1);
                log2dev(sprintf('Pixel difference between %u and %u is: %1.4g', column, id-1, imdiff/prod(size(im_sample))),'DEBUG');
                if(imdiff/prod(size(im_sample))>0.05)
                    A = imread('images/icons/error.png');A(:,:,4) = A(:,:,1);
                    idux = (size(cmptable,2)-1)*(row-1)+(id-1);
                    set(ghandle(idux).header, 'String', sprintf('%s var %1.4g',cmptable{row,1},imdiff/prod(size(im_sample))));
                    h = imshow(A(:,:,1:3),'Parent',ghandle(idux).selected);set(h, 'AlphaData', A(:,:,4));
                end
            end
            idPanel = idpanel;
        %end
    end
    % --------------------------------------------------------------------
    function moveTag2NewPool(src, eventdata,nameTag,destPoolId,idpanel,row,column)
        answer = questdlg({'Moving tags between pools may overwrite previous computed results','Do you want to continue?'}, '[WARN] Tag moving between pools');
        drawnow; pause(0.05);
        switch answer
            case 'Yes'
                if  uihandles_exists( 'GraphicHandleCmpDisplay' )
                    uihandles_deletecontrols( 'GraphicHandleCmpDisplay' );
                    log2dev( 'Standard visualisation mode actived', 'INFO', 0, 'hMainGui', 'statusbar' );
                end
                % Get module name associated to the tag to export
                moduleName = pool_instances(reftable{row,column}).ref.getTag(nameTag).module;
                % Move all the tags stored in the current pool assocated
                % with the module name
                minv = 0; maxv=numel(pool_instances(reftable{row,column}).ref.tags);
                log2dev('Moving tags...plase wait','INFO',0,'hMainGui', 'statusbar',{minv,maxv,0});
                num = 1;
                for iterTag = pool_instances(reftable{row,column}).ref.tags
                    log2dev('Moving tags...plase wait','INFO',0,'hMainGui', 'statusbar',{minv,maxv,num});
                    if strcmp(pool_instances(reftable{row,column}).ref.getTag(iterTag{1}).module,moduleName)
                        pool_instances(reftable{row,column}).ref.moveTag(iterTag{1},arrPoolNames{destPoolId});
                    end
                    num = num+1;
                end
                
                %pool_instances(reftable{row,column}).ref.moveTag(nameTag,arrPoolNames{destPoolId});
            case 'No'
                return
            otherwise
                return;
        end
    end
    function idPanel = compareSelectionWithOriginal(src, eventdata, nameTag,destPoolId,idpanel,row,column)
        % Clear workspace from comparative mode
        if uihandles_exists( 'GraphicHandleCmpDisplay' )
            uihandles_deletecontrols( 'GraphicHandleCmpDisplay' );
        end
        % Retrieve selected tag from current pool
        curtag = pool_instances(reftable{row,column}).ref.getTag(nameTag);
        % 
        deftag = pool_instances(reftable{row,column}).ref.getTag('Generic_Image');
        [status, argout] = RetrieveData2Load({'Generic_Image'}, 'SearchIn', 'default');
        %[~,data] = RetrieveData2Load('Generic_Image');
        inputs       = {};
        inputs{1}    = getappdata(0,'hMainGui');
        
        inputs{2}{2} = curtag.attributes.attribute(strcmp({curtag.attributes.attribute.class},'file')).path;
        inputs{3}{2} = sprintf('%s-%s',curtag.uid,datestr(curtag.timestamp,31));

        inputs{2}{1} = deftag.attributes.attribute(strcmp({deftag.attributes.attribute.class},'file')).path;
        inputs{3}{1} = sprintf('%s-%s',deftag.uid,datestr(deftag.timestamp,31));
        
        [status_exec,dispargout] = dataexplorer_imageview( inputs );
        if ~status_exec;
            uihandles_savecontrols( dispargout(1).description ,dispargout(1).object );
            log2dev( 'Slide visualisation mode actived', 'INFO', 0, 'hMainGui', 'statusbar' );
        end
    end
    % --------------------------------------------------------------------
    function idPanel = SelectionAnalysisMetadataCallback(src, eventdata, idpanel, row, column)
        setIDX = strcmp({pool_instances(reftable{row,column}).ref.getTag(cmptable(row,1)).attributes.attribute.class},'settings');
        moduleName = pool_instances(reftable{row,column}).ref.getTag(cmptable(row,1)).module;
        tmp = getVariable4Memory(pool_instances(reftable{row,column}).ref.getTag(cmptable(row,1)).attributes.attribute(setIDX).path);
        if isempty(tmp); return; end 
        structfields = fields(tmp.analysis_modules.(moduleName).settings);
        strVar = {};
        for idxFields = 1:numel(structfields)
            valuestruct = class(tmp.analysis_modules.(moduleName).settings.(char(structfields(idxFields))));
            switch valuestruct
            case 'double'
                strVar{idxFields} = sprintf('%s = %s',structfields{idxFields},num2str(tmp.analysis_modules.(moduleName).settings.(char(structfields(idxFields)))));
            case 'char'
                strVar{idxFields} = sprintf('%s = %s',structfields{idxFields},tmp.analysis_modules.(moduleName).settings.(char(structfields(idxFields))));
            end
        end
        %tmp.analysis_modules.(moduleName).settings
        helpdlg(strVar,'Analysis Metadata')
    end
end