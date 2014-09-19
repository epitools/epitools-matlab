function fig = TrackingGUIwOldOK(ImageSeries,Ilabel,Clabel,ColLabels,Ilabelsout,params, oldOKs, FramesToRegrow_old)

%% Reconversion input parameters

Ilabel = uint8(Ilabel);
Clabel = uint16(Clabel);                                                   %unit16 because more than 256 labels possible!

%% Check on image dimensions
ImSize = size(ImageSeries);
% ImSize = [x, y, t];
% check for single frame
if numel(ImSize) == 2 % of got a single frame here
    SingleFrame = true;
    NFrames = 1;
else
    SingleFrame = false;
    NFrames = ImSize(3);
end

% is this typecasting still necessary?
ImageSeries = double(ImageSeries);
ImageSeries = uint8(ImageSeries/max(ImageSeries(:))*255);                  %todo : check casting!

%% Initialization of the variables

fs=fspecial('laplacian',0.9);
CColors = [];
Itracks = [];
tracklength=[];
trackstarts = [];
trackstartX = [];
trackstartY = [];
oktrajs = oldOKs;

% Seed maker is white
SeedMarker = 255;
% Count user clicks
NClicks = 0;
% Start from the first frame
CurrentFrame = 1;

% Zoom in the area of the seed
zoommode = false;

% Unknown parameter
WindowSize = 100;

% Check final tracking
Ch1On = false;

Cpt = [0 0];
CCellNum = 0;

% Application status
okeydown = false;
deleteMode = false;
delabelMode = false;
showCells = true;
RemoveTrack = false;
AddDummyPt = false;
InspectPt = false;
NeedToRetrack = false;
WipeFrame = false;
FramesToRegrow = [];

cellBoundaries = zeros(ImSize,'int8');

%% Gui Preparation 

% Create a new figure
fig = figure;
set(fig,'Color', [0.314 0.314 0.314]);
set(fig,'Position', [0 0 1024 860]);
movegui(fig,'center');

axes_img = axes('Parent',fig,...
                'Position',[0.20 0.25 0.70 0.70]);
% Create axes for statistics hist
axes1 = axes('Parent',fig,...
            'YColor',[0.50 0.50 0.50],...
            'XGrid','on',...
            'XColor',[0.50 0.50 0.50],...
            'Position',[0.04 0.10 0.93 0.055],...
            'FontName','Tahoma',...
            'Color',[0 0 0],...
            'Ylim', [0.5 1.7],...
            'Xlim', [0 1],...
            'YTick',1);

 box(axes1,'on');
 hold(axes1,'all');

if ~SingleFrame
    slider = uicontrol( fig ...
        ,'style'    ,'slider'   ...
        ,'units'    ,'normalized' ...
        ,'position' ,[0.11 0.0 0.78 0.035] ...
        );

    set(slider,'sliderstep',[1/(NFrames),1],...
        'max',NFrames,'min',1, 'Value', 1);

    % sliderListener = addlistener(slider,'ContinuousValueChange',@sliderActionEventCb);
    set(slider,'Callback',@sliderActionEventCb);
    set(fig,'WindowScrollWheelFcn',@figScroll);

end
set(fig,'MenuBar','none');

framenum = uicontrol(fig ...
                    ,'style'    ,'edit' ...
                    ,'units'    ,'normalized' ...
                    ,'position' ,[0.04 0.01 0.05 0.04] ...
                    ,'string'   ,1 ...
                    );
uiLastFrame = uicontrol(fig ...
                ,'style'    ,'edit' ...
                ,'units'    ,'normalized' ...
                ,'position' ,[0.92 0.01 0.05 0.04] ...
                ,'string'   ,1 ...
                );
set(uiLastFrame,'String',NFrames);

% uiStatisticPanel = uicontrol(fig ...
%                 ,'style'    ,'edit' ...
%                 ,'units'    ,'normalized' ...
%                 ,'position' ,[0.92 0.01 0.05 0.04] ...
%                 ,'string'   ,1 ...
%                 );
%             
% uiStatisticDesc = uicontrol(fig ...
%                 ,'style'    ,'edit' ...
%                 ,'units'    ,'normalized' ...
%                 ,'position' ,[0.92 0.01 0.05 0.04] ...
%                 ,'string'   ,1 ...
%                 );
%             
% ToolBar
% Create the toolbar
th = uitoolbar(fig);

% Add a push tool to the toolbar


% Open button
pth1 = uipushtool(th,'CData',gif2cdata('images/gif/folder.gif'),...
               'TooltipString','Open a tracking file',...
               'HandleVisibility','off');

% Save button
pth2 = uipushtool(th,'CData',gif2cdata('images/gif/action_save.gif'),...
               'TooltipString','Save the current tracking corrections',...
               'HandleVisibility','off',...
               'ClickedCallback', {@keyPrsFcn,'s'});

% Wipe toogle       
tth4 = uipushtool(th,'CData',gif2cdata('images/gif/action_go.gif'),'Separator','on',...
                   'TooltipString','Wipe orphan seeds',...
                   'HandleVisibility','off',...
                   'ClickedCallback', {@keyPrsFcn,'w'});
               
           
% Delete toogle       
tth3 = uitoggletool(th,'CData',gif2cdata('images/gif/action_stop.gif'),'Separator','on',...
                   'TooltipString','Delete seeds',...
                   'HandleVisibility','off',...
                   'ClickedCallback', {@keyPrsFcn,'d'});

% Add seed with automatic center toogle
tth9 = uitoggletool(th,'CData',gif2cdata('images/gif/page_wizard.gif'),'Separator','on',...
                   'TooltipString','Final inspection',...
                   'HandleVisibility','off',...
                   'ClickedCallback', {});
               
% Hide boundaries toogle
tth5 = uitoggletool(th,'CData',gif2cdata('images/gif/calendar.gif'),'Separator','on',...
                   'TooltipString','Hide cell boundaries',...
                   'HandleVisibility','off',...
                   'ClickedCallback', {@keyPrsFcn,'h'});
               
% Inspect toogle
tth6 = uitoggletool(th,'CData',gif2cdata('images/gif/icon_wand.gif'),'Separator','on',...
                   'TooltipString','Inspect mode',...
                   'HandleVisibility','off',...
                   'ClickedCallback', {@keyPrsFcn,'i'});
               
% Final inspect toogle
tth7 = uitoggletool(th,'CData',gif2cdata('images/gif/icon_monitor_pc.gif'),'Separator','on',...
                   'TooltipString','Final inspection',...
                   'HandleVisibility','off',...
                   'ClickedCallback', {@cb1Callback});

%% First run executions
log2dev('retrack', 'DEBUG');
Retrack();
log2dev('recalculate cell boundaries', 'DEBUG');
RecalculateCellBoundaries();
%Retrack();
log2dev('update figure', 'DEBUG');

img = Update();
set(fig,'WindowButtonDownFcn',{@wbmFcn,img})
set(fig,'KeyPressFcn',@keyPrsFcn)

%% Support functions
% Evaluate the final check
    function cb1Callback(src,evt)
        if(Ch1On);Ch1On = false;else Ch1On = true; end
        img = Update();
    end

    function figScroll(src,evt)
        clicks = evt.VerticalScrollCount;
        CurrentFrame = CurrentFrame - clicks;
        CurrentFrame = max(1,CurrentFrame);
        CurrentFrame = min(NFrames,CurrentFrame);
        set(slider,'Value', CurrentFrame);
        img = Update();
    end

    function sliderActionEventCb(src,evt)
        newi = round(get(src,'Value'));
        if newi == CurrentFrame
            return
        end
        CurrentFrame = newi;
        set(src,'Value',CurrentFrame);
        img = Update();
    end

    function img = Update()

        if zoommode
            Irgb = gray2rgb(ImageSeries(:,:,CurrentFrame));
            PaddedIm = zeros(ImSize(1)+200,ImSize(2)+200,3);
            PaddedIm(100:99+ImSize(1), 100:99+ImSize(2),:) = squeeze(Irgb(:, :,:));
            
            % 251 marks the threshold for a seed pixel!
            [cpy,cpx]=find(Ilabel(:,:,CurrentFrame) > 251);
            
            for n =1:length(cpy)
                y = cpy(n); x = cpx(n);
                
                if ~checkLabelValidity(x,y)
                    continue
                end
                
                if (y > Cpt(1)-WindowSize && y < Cpt(1)+WindowSize && x > Cpt(2)-WindowSize && x < Cpt(2)+WindowSize )
                    CelN = Itracks(y,x,CurrentFrame);
                    if CelN ==0
                        col = [1 1 1];
                        TrackL = 0;
                    else
                        col = CColors(CelN,:);
                        col = col*.8;
                        TrackL = tracklength(CelN);
                    end
                    
                    %assuming full tracking is marked here
                    if TrackL == NFrames-1
                        PaddedIm(y-2+100:y+2+100,x-2+100:x+2+100,1) = col(1);
                        PaddedIm(y-2+100:y+2+100,x-2+100:x+2+100,2) = col(2);
                        PaddedIm(y-2+100:y+2+100,x-2+100:x+2+100,3) = col(3);
                        
                        
                        %and incomplete tracking here
                    else
                        %base is a 1px smaller cube
                        PaddedIm(y-1+100:y+1+100,x-1+100:x+1+100,1) = col(1);
                        PaddedIm(y-1+100:y+1+100,x-1+100:x+1+100,2) = col(2);
                        PaddedIm(y-1+100:y+1+100,x-1+100:x+1+100,3) = col(3);
                        
                        if CelN~=0 && ~SingleFrame
                            %if track-problem is due to late start, e.g.
                            %correctly tracked daughter cell, left pixel
                            %is added
                            first_frame_no = trackstarts(CelN);
                            movie_start = 1;
                            if first_frame_no ~= movie_start
                                PaddedIm(y+100,x-2+100:x+100,1) = col(1);
                                PaddedIm(y+100,x-2+100:x+100,2) = col(2);
                                PaddedIm(y+100,x-2+100:x+100,3) = col(3);
                            end
                            
                            %if track-problem is due to premature end, e.g.
                            %eliminated cell, right pixel is added
                            final_frame_no = trackstarts(CelN) + TrackL;
                            movie_length = NFrames;
                            if final_frame_no ~= movie_length
                                PaddedIm(y+100,x+100:x+2+100,1) = col(1);
                                PaddedIm(y+100,x+100:x+2+100,2) = col(2);
                                PaddedIm(y+100,x+100:x+2+100,3) = col(3);
                            end
                            
                            %if trajectory key is found in oktrajs,
                            %a vertical band is added
                            trajectory_key = TrajKey(...
                                trackstartX(CelN), trackstartY(CelN) ,trackstarts(CelN));
                            if ~isempty(find(oktrajs == trajectory_key, 1))
                                PaddedIm(y-2+100:y+2+100,x+100,1) = col(1);
                                PaddedIm(y-2+100:y+2+100,x+100,2) = col(2);
                                PaddedIm(y-2+100:y+2+100,x+100,3) = col(3);
                            end
                        end
                    end
                end
            end
            if showCells
                PaddedIm(100:end-101,100:end-101,1) = .5*double(cellBoundaries(:,:,CurrentFrame)) + PaddedIm(100:end-101,100:end-101,1).*(1-double(cellBoundaries(:,:,CurrentFrame)));
                PaddedIm(100:end-101,100:end-101,2) = .2*double(cellBoundaries(:,:,CurrentFrame)) + PaddedIm(100:end-101,100:end-101,2).*(1-double(cellBoundaries(:,:,CurrentFrame)));
                PaddedIm(100:end-101,100:end-101,3) = .2*double(cellBoundaries(:,:,CurrentFrame)) + PaddedIm(100:end-101,100:end-101,3).*(1-double(cellBoundaries(:,:,CurrentFrame)));
            end
            
            img = imshow(PaddedIm(Cpt(1)-WindowSize+100:Cpt(1)+WindowSize+100,Cpt(2)-WindowSize+100:Cpt(2)+WindowSize+100,:),...
                        'Parent', axes_img);
            
        else
            
            Irgb = gray2rgb(ImageSeries(:,:,CurrentFrame));
            
            [cpy,cpx]=find(Ilabel(:,:,CurrentFrame) > 253);
            for n =1:length(cpy)
                y = cpy(n); x = cpx(n);
                
                if ~checkLabelValidity(x,y)
                    continue
                end
                
                CelN = Itracks(y,x,CurrentFrame);
                if CelN ==0
                    col = [1 1 1];
                else
                    col = CColors(CelN,:);
                    col = col*.8;
                    %TrackL = tracklength(CelN);
                end
                
                ymin = max(y-2,1); ymax = min(y+2,ImSize(1));
                xmin = max(x-2,1); xmax = min(x+2,ImSize(2));
                if ~SingleFrame &&  CelN ~=0 && tracklength(CelN) ~= NFrames-1 && isempty(find(oktrajs == TrajKey(trackstartX(CelN), trackstartY(CelN) ,trackstarts(CelN)), 1))
                    Irgb(ymin:ymax,xmin:xmax,:) = 1;
                else
                    if CelN ==0
                        Irgb(ymin:ymax,xmin:xmax,:) = 1;
                    end
                end
                
                if ~Ch1On
                    Irgb(ymin+1:ymax-1,xmin+1:xmax-1,1) = col(1);
                    Irgb(ymin+1:ymax-1,xmin+1:xmax-1,2) = col(2);
                    Irgb(ymin+1:ymax-1,xmin+1:xmax-1,3) = col(3);
                end
            end
            
            if showCells
                Irgb(:,:,1) = .5*double(cellBoundaries(:,:,CurrentFrame)) + Irgb(:,:,1).*(1-double(cellBoundaries(:,:,CurrentFrame)));
            end
            
            img = imshow(Irgb,...
                        'Parent', axes_img);
            
        end
        
        
        set(img,'ButtonDownFcn',@wbmFcn)
        set(framenum,'String',CurrentFrame);
        
        % Attached statistics figures
        trajectories_statistics(CurrentFrame);
        
        
        % Reset toolbar toggles

        if(showCells);set(tth5,'State','on');else set(tth5,'State','off');end
        if(deleteMode);set(tth3,'State','on');else set(tth3,'State','off');end
        if(InspectPt);set(tth6,'State','on');else set(tth6,'State','off');end
        if(Ch1On);set(tth7,'State','on');else set(tth7,'State','off');end
        
        drawnow;

    end

    function trajectories_statistics(idxtime)
        % ---------------------------------------------------------------
        % Data preparation
        cmplength = [];
        cmphists = [];
        
        
        [x1,y1] = find(Itracks(:,:,idxtime));
        [x2,y2] = find(Ilabel(:,:,idxtime)==255);
        orphan_seeds = setdiff([x2,y2],[x1,y1], 'rows', 'stable');
        track_uids = Itracks(x1,y1,idxtime);
        track_uids = sort(track_uids(track_uids~=0));
        
        % Seeds not associated to any track (value == 255) are those which
        % coordinate is present in Ilabel but not in Itracks.
        orphan_seeds = ones(size(orphan_seeds,1),1);

        %cmpstarts(idxtime,:) = trackstarts(track_uids);
        cmplength = [tracklength(track_uids)+2; orphan_seeds]';
        
        % compute bins
        if NFrames <= 10; nbins = NFrames;else nbins = round((NFrames/10)*2.5); end
        binEdges = linspace(min(cmplength),max(cmplength),nbins);

        % assign values to bins
        cmphists = histc(cmplength, [binEdges(1:end-1) Inf])/sum(histc(cmplength, [binEdges(1:end-1) Inf]));
        
        % Histograms to include in update image function passing time id
        data = [cmphists;NaN(size(cmphists,2),1)'];
        
        % ---------------------------------------------------------------
        % Plotting
        % per each frame represent track length distribution in percentage 

        hDataSeries = barh(data,...
                        'Stacked',...
                        'EdgeColor',[0.83 0.81 0.78],...
                        'Parent',axes1);

        hPatches = get(hDataSeries,'Children');
        try hPatches = cell2mat(hPatches); catch, end  % no need in case of single patch
        yData = get(hPatches(1),'YData');
        yPos = yData(end,:) - 0.40;
        xData = get(hPatches,'XData');
        try xData = cell2mat(xData); catch, end
        barXs = xData(2:4:end,:);
        barValues = diff([zeros(1,size(barXs,2)); barXs]);
        barValues(bsxfun(@minus,barValues,sum(barValues))==0) = 0;  % no sub-total for bars having only a single sub-total
        xPos = xData(1:4:end,:) + barValues/3;
        yPos = yPos(ones(1,size(xPos,1)),:);
        
        yPos(barValues==0)      = [];  % remove entries for empty bars patches
        xPos(barValues==0)      = [];  % remove entries for empty bars patches
        barValues(barValues==0) = [];  % remove entries for empty bars patches
        barValues = barValues * 100;
        cutoffpercentage = 2.5;
        labels = strcat(' ', arrayfun(@(x) num2str(x,'%0.1f'),barValues(:),'uniform',false), '%');
        hText = text(xPos(find(barValues>=cutoffpercentage)), yPos(find(barValues>=cutoffpercentage)), labels(find(barValues>=cutoffpercentage)), 'Parent', axes1);
        set(hText, 'FontSize',9, 'Color', [0.40 0.40 0.40], 'FontName', 'Tahoma');
        title(axes1, 'Trajectories length distribution', 'FontName', 'Tahoma', 'FontSize',9,'Color', [0.50 0.50 0.50] );
        
        %legend1 = legend(axes1,arrayfun(@(x) num2str(x,'%0.1f'), binEdges ,'uniform',false),...
        %                'TextColor',[0.80 0.80 0.80],...
        %                'Orientation','horizontal',...
        %                'Location','NorthOutside');
     
        set(axes1,'Position',[0.04 0.10 0.93 0.055]);

    end

%deletion of a point, intensity 25 is assigned
    function deletePt(x,y,Frame)
        %Ilabel(y, x,Frame) = 25;
        Ilabel(y,x,Frame) = ImageSeries(y,x,Frame);
        Itracks(y,x,Frame) = 0;
    end

    function neutralisePt(x,y,Frame)
        Ilabel(y, x,Frame) = 253;
        Itracks(y,x,Frame) = 0;
    end

    function deletePtsAround(pt)
        [cpy cpx]=find(Ilabel(:,:,CurrentFrame) > 251);
        for n =1:length(cpy)
            y = cpy(n); x = cpx(n);
            dist = sqrt((y-pt(2))^2 + (x-pt(1))^2);
            if dist < 20
                deletePt(x,y,CurrentFrame);
            end
        end
    end

    function k = TrajKey(cpx,cpy,strt)
        k = 1000000*strt + 1000*cpx + cpy;
    end

% WBMFCN or WindowButtonMotionFunCtioN
% i.e. what happens for MOUSE events
    function wbmFcn(src,evt,img)
        pt = get(gca,'Currentpoint');
        pt = round([pt(1,1), pt(1,2)]);
        
        % -----------------------------------------------------------------
        % in order to get rid of the click outside the image frame
        
        %get(axes_img,'CurrentPoint')

        xlim = get(img,'XData');
        ylim = get(img,'YData');
             
        if(isempty(find([xlim(1):xlim(2)] == pt(1),1))); return;end
        if(isempty(find([ylim(1):ylim(2)] == pt(2),1))); return;end
        % -----------------------------------------------------------------
        
        mouseuse  = get(gcf,'SelectionType');
        %PropsOfCell(pt)
        
        %LEFT MOUSE BUTTON
        if strcmp(mouseuse ,'normal')
            NClicks = NClicks + 1;
            if zoommode
                
                %Check first if the location of the click is valid
                if ~checkPointValidity(pt(1),pt(2));return;end
                
                % Any modification requires the frame to be resegmented
                if isempty(find(FramesToRegrow==CurrentFrame) )
                    FramesToRegrow(length(FramesToRegrow)+1) = CurrentFrame;
                end
                
                % NORMAL ACTION, i.e. not delete mode
                if ~delabelMode
                    
                    if InspectPt && NeedToRetrack
                        Retrack();
                        NeedToRetrack = true;
                    end

                    % find all known seeds
                    [cpy cpx]=find(Ilabel(:,:,CurrentFrame) > 251);
                    OnASeed = false;
        
                    % loop through all seeds
                    for n =1:length(cpy)
                        y = cpy(n); x = cpx(n);
                        
                        %check whether the user hit the seed square
                        if (checkSeedMatch(x,y,pt))
                            
                            n = Itracks(y,x,CurrentFrame);
                            
                            % INSPECT
                            if InspectPt && n ~=0
                                % -------------------------------------------------------------------------
                                % Log status of current application status
                                log2dev(sprintf('Track starts at %i and finishes at %i \n',trackstarts(n),trackstarts(n)+tracklength(n)), 'DEBUG');
                                % -------------------------------------------------------------------------
                                if trackstarts(n) ~= 1
                                    CurrentFrame = trackstarts(n)-1;
                                end
                                if trackstarts(n)+tracklength(n) ~= NFrames
                                    CurrentFrame = trackstarts(n)+tracklength(n)+1;
                                end
                            end
                            
                            % OK
                            if okeydown  && n ~=0 % mark this traj as ok even (delaminating cell or cell created during traj)
                                oktrajs = [oktrajs , TrajKey(trackstartX(n),trackstartY(n),trackstarts(n))];
                            end
                            
                            % REMOVE
                            if ~RemoveTrack
                                if ~InspectPt && ~okeydown deletePt(x,y,CurrentFrame); end
                                
                                % ADD-PARTICLE
                            else
                                N = Itracks(y,x,CurrentFrame);
                                Ilabel(Itracks==N) = 253;
                                Itracks(Itracks==N) = 0;
                                RemoveTrack = false;
                            end
                            
                            OnASeed = true;
                            break;
                        end
                    end
                    if InspectPt InspectPt = false; end
                    if(InspectPt);set(tth6,'State','on');else set(tth6,'State','off');end
                    if okeydown okeydown = false; end
                    if ~OnASeed
                        if ~AddDummyPt
                            Ilabel(Cpt(1)-WindowSize+pt(2)-1, Cpt(2)-WindowSize+pt(1)-1,CurrentFrame) = SeedMarker;
                        else
                            Ilabel(Cpt(1)-WindowSize+pt(2)-1, Cpt(2)-WindowSize+pt(1)-1,CurrentFrame) = 253;
                            AddDummyPt = false;
                        end
                    end
                    Retrack();
                    NeedToRetrack = true;
                    
                else
                    % delete Label here!
                    lbl = Clabel(pt(2) + Cpt(1)-WindowSize,pt(1) + Cpt(2)-WindowSize,CurrentFrame);
                    if lbl ~=0
                        F = Ilabel(:,:,CurrentFrame);
                        C = Clabel(:,:,CurrentFrame);
                        Cnum = C(Cpt(1)-WindowSize+pt(2)-1,Cpt(2)-WindowSize+pt(1)-1)
                        % Cancel the cell label belonging to the clicked point. 
                        Clabel(:,:,CurrentFrame) = C.*int16(C~=Cnum);
                        % Now, neutralize the seed corresponding to the
                        % deleted label.
                        % 1. Find image region corresponding to label 
                        
                        F = F.*uint8(C==Cnum);
                        % 2. Find the seeds in the cancelled region
                        [cpy cpx]=find(F > 252)
                        % 3. Neutralised the seed setting its value to 251
                        neutralisePt(cpx,cpy,CurrentFrame);
                        
                        cellBoundaries(:,:,CurrentFrame) = filter2(fs,Clabel(:,:,CurrentFrame)) >.5;
                    end
                 end
            else
                if deleteMode
                    
                    deletePtsAround(pt)
                    set(src,'WindowButtonMotionFcn',@wbmcbDel);
                    set(src,'WindowButtonUpFcn',@wbucbDel);
                else
                    zoommode = true;
                    Cpt = [pt(2) pt(1)];
                    CCellNum = 0;
                end
            end
        end
        
        %RIGHT MOUSE BUTTON
        if strcmp(mouseuse ,'alt')
            if zoommode
                
                %Check first if the location of the click is valid
                if ~checkPointValidity(pt(1),pt(2));return;end
                
                [cpy cpx]=find(Ilabel(:,:,CurrentFrame) > 251);
                for n =1:length(cpy)
                    
                    %seed coordinates
                    y = cpy(n); x = cpx(n);
                    
                    if checkSeedMatch(x,y,pt)

                        cnum = Itracks(y,x,CurrentFrame);
                        if cnum ~= 0
                            log2dev(sprintf('label=%i x=%i y=%i cellnum=%i tracklen=%i trackStart=%i',...
                                Ilabel(y, x,CurrentFrame),x,y,cnum,tracklength(cnum),trackstarts(cnum)),...
                                'INFO');
                        else
                            log2dev(sprintf('label=%i x=%i y=%i' ,...
                                Ilabel(y, x,CurrentFrame),x,y),...
                                'INFO');
                        end
                        break
                        
                    end
                end
                
                %potential bug here that sends img error
                xinit = pt(1); yinit = pt(2);
                Cptinit = Cpt;
                set(src,'WindowButtonMotionFcn',@wbmcb);
                set(src,'WindowButtonUpFcn',@wbucb);
            else
                if deleteMode
                    % delete label of this cell
                    F = Ilabel(:,:,CurrentFrame);
                    C = Clabel(:,:,CurrentFrame);
                    Cnum = C(pt(2),pt(2));
                    Clabel(:,:,CurrentFrame) = C.*int16(C~=Cnum);
                    F = F.*int16(C~=Cnum);
                    [cpy cpx]=find(F > 252)
                    deletePt(cpy,cpx,CurrentFrame);
                end
            end
        end
        
        img = Update();
        
        % CallBack funtions for NORMAL mode
        function wbmcb(src,evnt)
            cp = get(gca,'CurrentPoint');
            xdat = [xinit,cp(1,1)];
            ydat = [yinit,cp(1,2)];
            Cpt(1) = round(Cptinit(1)-cp(1,2)+yinit);
            Cpt(2) = round(Cptinit(2)-cp(1,1)+xinit);
            img = Update();
        end
        
        function wbucb(src,evnt)
            set(src,'Pointer','arrow')
            set(src,'WindowButtonMotionFcn','')
            set(src,'WindowButtonUpFcn','')
        end
        
        % CallBack funtions for DELETE mode
        function wbmcbDel(src,evnt)
            cp = get(gca,'CurrentPoint');
            cp = round([cp(1,1), cp(1,2)]);
            deletePtsAround(cp)
            img = Update();
        end
        
        function wbucbDel(src,evnt)
            set(src,'WindowButtonMotionFcn','')
            set(src,'WindowButtonUpFcn','')
        end
        
    end

% KEY PRESS FUNCTION
    function keyPrsFcn(src,evt,ch)
        if nargin < 3
        ch = get(gcf,'CurrentCharacter');
        end
        switch ch
            case {29} %RIGHT ARROW
                if CurrentFrame < size(Ilabel,3)
                    CurrentFrame = CurrentFrame+1;
                end
                set(slider,'Value', CurrentFrame);
                img = Update();
            case {28} %LEFT ARROW
                if CurrentFrame > 1
                    CurrentFrame = CurrentFrame-1;
                end
                set(slider,'Value', CurrentFrame);
                img = Update();
            case {'n'}
                GotoNextProbPt();
                img = Update();
            case {' '} %SPACE BAR
                zoommode = false;
                Retrack();
                img = Update();
            case {'r'}
                Retrack();
                img = Update();
            case {'s'}
                %fprintf('Saving ... ');
                ILabels = Ilabel;      
                FramesToRegrow = union(FramesToRegrow,FramesToRegrow_old);
                
                save(Ilabelsout,'ILabels','FramesToRegrow','oktrajs','Itracks','tracklength','trackstartX','trackstartY','trackstarts');
                % -------------------------------------------------------------------------
                log2dev(sprintf('Saving trackign file as %s', Ilabelsout), 'INFO');
                log2dev('Tracking module is over!', 'INFO');
                % ------------------------------------------------------------------------- 
                %fprintf('done\n');
                hMainGui = getappdata(0, 'hMainGui');
                stgObj = getappdata(hMainGui, 'settings_objectname');
                
                if isfield(stgObj.analysis_modules.Tracking.metadata, 'click_counts')
                    stgObj.ModifyMetadata('Tracking','click_counts', stgObj.analysis_modules.Tracking.metadata.click_counts + NClicks);
                else
                   stgObj.AddMetadata('Tracking','click_counts', NClicks); 
                end
                close(gcf);
            case {'o'}
                okeydown = true;
            case {'d'}
                if ~deleteMode
                    log2dev('Tracking module is in mode: DELETE ON', 'INFO');
                    %disp('delete mode!')
                    deleteMode = true;
                else
                    log2dev('Tracking module is in mode: DELETE OFF', 'INFO');
                    %disp('delete mode OFF!')
                    deleteMode = false;
                end
            case {'h'}
                if showCells
                    showCells = false;
                else
                    showCells = true;
                end
                Update();
            case {'t'}
                RemoveTrack = true;
            case {'a'}
                AddDummyPt = true;
            case {'i'}
                InspectPt = true;
            case {'w'}
                WipeFrame = true;
                log2dev('Key W pressed', 'DEBUG');
                Update();
        end
    end

    function Retrack()
        % -------------------------------------------------------------------------
        log2dev('Start retracking', 'DEBUG');
        % -------------------------------------------------------------------------   
        %fprintf('Retracking!')
        tic
        %output vectors
        % Itracks       - 3D information with seed information (255)
        % pTracks       - position of the track (max 100K) for each time point
        %                 (track_id, frame_no, (x,y))
        % trackstarts   - frame no where the track starts
        % trackstartX   - initial position X
        % trackstartY   - initial position Y
        
        if ~SingleFrame
            [Itracks, pTracks, tracklength, trackstarts, trackstartX, trackstartY]= ....
                cellTracking4(Ilabel,params.TrackingRadius);
            NC=max(Itracks(:));
            CColors = double(squeeze(label2rgb([1:NC],'jet','k','shuffle')))/255.;
        else
            
            Itracks = Clabel.*uint16(Ilabel > 253);
            NC = max(Clabel(:));
            tracklength = ones(NC);
            CColors = double(squeeze(label2rgb([1:NC],'jet','k','shuffle')))/255.;
            
        end
        
        elapsedtime = toc();
        % -------------------------------------------------------------------------
        log2dev(sprintf('Finished retracking in %0.2f seconds and with %i clicks',elapsedtime ,NClicks), 'DEBUG');
        % -------------------------------------------------------------------------
        %fprintf('Done! %i Clicks', NClicks)
        %toc
        
    end

    function RecalculateCellBoundaries()
        for ff = 1:NFrames
            cellBoundaries(:,:,ff) = filter2(fs,Clabel(:,:,ff)) >.5;
        end
    end

    function does_seed_match_point = checkSeedMatch(x,y,pt)
    %This function checks whether the seed has been selected
    %by the user. Pt is the mouse location clicked by the user.
    
        buffer_down = 5;%3;
        buffer_up = 5;%1;
        
        abs_pt_x = pt(1) + Cpt(2) - WindowSize;
        abs_pt_y = pt(2) + Cpt(1) - WindowSize;
        
        does_seed_match_point = ...
            y > abs_pt_y - buffer_down &&...
            y < abs_pt_y + buffer_up   &&...
            x > abs_pt_x - buffer_down &&...
            x < abs_pt_x + buffer_up;

%         %Feedback function in case correspondence should be checked
%         if does_seed_match_point
%             fprintf(...
%                 'x %d\t%d\t%d\t%d\ny %d\t%d\t%d\t%d\nFx %d\nFy %d\nWd %d\n',...
%                 x,abs_pt_x - buffer_down,abs_pt_x,abs_pt_x + buffer_up,...
%                 y,abs_pt_y - buffer_down,abs_pt_y,abs_pt_y + buffer_up,...
%                 Cpt(1),Cpt(2),WindowSize);
%         end
    end

    function has_seed_valid_label = checkLabelValidity(x,y)
        %Function to check whether a seed has a valid label
        %this might be not the case when a polygonal crop has been applied
        
        
        %check input validity
        if x > ImSize(2) || y > ImSize(1)
            has_seed_valid_label = 0;
            return;
        end
        
        %for most likely displaying reasons x,y are swapped
        if(Clabel(y,x,CurrentFrame) > 1)
            has_seed_valid_label = 1;
        else
            has_seed_valid_label = 0;
        end
        
    end

    function is_seed_outside_image = checkPointValidity(x,y)
        %Checks whether the point is within an image 
        %and whether there is labelled area below.
        
        % Keep in mind indeces are inversed
        abs_pt_x = x + Cpt(2) - WindowSize;
        abs_pt_y = y + Cpt(1) - WindowSize;
        
        is_seed_outside_image = 0;
        
        sprintf('Clicked Point [%d,%d] \n',abs_pt_x,abs_pt_y);
        
        %Check if clicked location is within image boundaries
        %find is used instead of boolean for faster lookup
        if(isempty(find([1:ImSize(2)] == abs_pt_x,1)));
            log2dev(sprintf('Click [%d,%d] is outside the image 1!',...
                abs_pt_x,abs_pt_y),'DEBUG');
            %fprintf('x=%d outside imagereturn\n',abs_pt_x);
            return;
        end
        
        if(isempty(find([1:ImSize(1)] == abs_pt_y,1)));
            log2dev(sprintf('Click [%d,%d] is outside the image 2!',...
                abs_pt_x,abs_pt_y),'DEBUG');
            %fprintf('y=%d outside imagereturn\n',abs_pt_y);
            return;
        end
        
        %Checks if point has labelled background
        if ~checkLabelValidity(abs_pt_x,abs_pt_y)
            log2dev(sprintf('Click [%d,%d] is outside the poloygon crop!',...
                abs_pt_x,abs_pt_y),'INFO');
            return;
        end;
        
        is_seed_outside_image = 1;
        
    end
        
end