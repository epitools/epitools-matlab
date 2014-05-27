function fig = AnalysisGUI(OMERO)

fprintf(['''l'' to toggle on/off deleting points\n' ...
'''h'' to show/hide cell segmentation\n' ...
'''s'' to save segmentation\n' ...
'''g'' to grow cells\n' ...
'''a'' to add dummy pt\n' ...
'''p'' to reload original segmentation created automatically\n'...
'click on image to zoom, press <space> to zoom out\n'])

Clabel = [];
Ilabel = [];
CColors = [];

try
    LoadSavedSeg();
catch
    disp('no hand-modified segmentation. loading original segmentation');
    LoadOriginalSeg();
end

RegisteredCleanProjectionID = ImageExists(OMERO.session, OMERO.AnalysisSetId,OMERO.ProjectionName);
if ~RegisteredCleanProjectionID
    disp('ERROR: can''t find Registered stack')
    return
end
I1 = OMEROGetTimeCourse(OMERO.session,RegisteredCleanProjectionID);

I1 = flipdim(I1,3);

s=size(I1);
s(3) =1;
for i = 1:s(3)
    I1(:,:,i) = I1(:,:,i)*(252/double(max(max(I1(:,:,i)))));
end



SurfaceID = ImageExists(OMERO.session, OMERO.AnalysisSetId,OMERO.SurfaceName);
if ~RegisteredCleanProjectionID
    disp('ERROR: can''t find Surface stack')
    return
end
Surface = double(OMEROGetTimeCourse(OMERO.session,SurfaceID));

SurfWorks = false;
ImStack = [];
if SurfWorks    
    % get original stack so we can recut it!
    LoadImStack();
end

OMERO.client.getStatefulServices()


fs=fspecial('laplacian',0.9);
se = strel('disk',2);   

Itracks = [];
tracklength=[];
trackstarts = [];

SeedMarker = 255;

NClicks = 0;
MaxLabelsize = 2000;

CurrentFrame = 1;
fig = figure;
zoommode = false;
WindowSize = 80;
Cpt = [0 0];
CCellNum = 0;
okeydown = false;
deleteMode = false;
delabelMode = false;
showCells = true;
RemoveTrack = false;
AddDummyPt = false;
FramesToRegrow = [];
cellBoundaries = zeros(s,'int8');
getPoints = false;
getPoint = '';
BoundaryPts = [];
AnalysisCalled = false;
Center = []; BoundaryPt = []; DirectionPt = [];

cellBoundaries(:,:,CurrentFrame) = filter2(fs,Clabel(:,:,CurrentFrame)) >.5;

Ch1On = true;
Ch2On = false;
Ch3On = true;

cbh1 = uicontrol(fig,'Style','checkbox',...
                'String','Overlay',...
                'Value',1, ...
                'units'    ,'normalized', ...
                'Position',[0.04 0.1 0.1 0.04],...
                'Callback',@cb1Callback);

cbh2 = uicontrol(fig,'Style','checkbox',...
                'String','Div Cells',...
                'Value',0, ...
                'units'    ,'normalized', ...
                'Position',[0.04 0.2 0.1 0.04],...
                'Callback',@cb2Callback);
            
cbh3 = uicontrol(fig,'Style','checkbox',...
                'String','Mask outer seeds',...
                'Value',1, ...
                'units'    ,'normalized', ...
                'Position',[0.04 0.3 0.1 0.04],...
                'Callback',@cb3Callback);           

            

Push2 = uicontrol(fig,'Style','PushButton',...
                'Units','normalized',...
                'String','Final grow & clean',...
                'Position',[0.04 0.6 0.1 0.05],...
                'Callback', @FinalGrowClean);
            
            

            
uicontrol(fig,'Style','PushButton',...
                'Units','normalized',...
                'String','Analyse',...
                'Position',[0.88 0.26 0.1 0.03],...
                'Callback', @AnalysisClbk);
            
            
            
framenum = uicontrol(fig ...
    ,'style'    ,'edit' ...
    ,'units'    ,'normalized' ...
    ,'position' ,[0.04 0.05 0.1 0.04] ...
    ,'string'   ,1 ...
);

img = Update();

%set(img,'ButtonDownFcn',@wbmFcn)

%set(fig,'WindowButtonDownFcn',@wbmFcn)

set(fig,'KeyPressFcn',@keyPrsFcn);
set(fig,'WindowScrollWheelFcn',@figScroll);

f1=fspecial( 'gaussian', [50 50], 15);


%% FROM HERE

    function figScroll(src,evnt)
        if ~SurfWorks           % basically needs to load surface
            return
        end
        
        clicks = evnt.VerticalScrollCount;
        mpt = get(gca,'Currentpoint');
        x = round(mpt(1,1));
        y = round(mpt(1,2));
        
        if zoommode 
            x = x-1 + Cpt(2)-WindowSize;
            y = y-1 + Cpt(1)-WindowSize;
        end
            
        
        % now add / remove sliver (guaussian) from surface
        Surface(y-25:y+24,x-25:x+24) = Surface(y-25:y+24,x-25:x+24) + f1*clicks/max(f1(:))/4.;
        
        % now recalc surface
        NewI = GetNewProjection(ImStack,round(Surface));
        
        I1 = NewI;
        
        PaddedS = zeros(s(1)+200,s(2)+200);
        PaddedS(100:99+s(1), 100:99+s(2)) = squeeze(Surface(:, :));
        figure(99); 
        if ~zoommode 
            image(Surface);
        else
            image(PaddedS(Cpt(1)-WindowSize+100:Cpt(1)+WindowSize+100,Cpt(2)-WindowSize+100:Cpt(2)+WindowSize+100))
        end
        axis equal
        Update();
    end

%% TO HERE

    function LoadImStack()
        disp('loading image stack');
        SurfWorks = true;
        [name,sizeC,sizeX,sizeY,sizeZ,sizeT] = GetImageInfo(OMERO.session,OMERO.ImageId);
        if sizeC == 2       % check number of channels, old images save info in channel 1 whereas new ones save it in channel 0
            Ch = 1;
        else
            Ch = 0;
        end
        ImStack = GetStack(OMERO.session,OMERO.ImageId,0,Ch);
        disp('done');
    end

    function cb1Callback(src,evt)
        Ch1On = get(cbh1,'Value');
        Update();
    end

    function cb2Callback(src,evt)
        Ch2On = get(cbh2,'Value');
        Update();
    end

    function cb3Callback(src,evt)
        Ch3On = get(cbh3,'Value');
        Update();
    end

    function imm = DrawPt(imm,pt,size)
        imm(pt(2)-size:pt(2)+size,pt(1)-size:pt(1)+size,:) = 1;
    end


    function img = Update()
        
        figure(fig);
        
        if zoommode
            Irgb = gray2rgb(I1(:,:,CurrentFrame));
            PaddedIm = zeros(s(1)+200,s(2)+200,3);
            PaddedIm(100:99+s(1), 100:99+s(2),:) = squeeze(Irgb(:, :,:));
            
            if Ch1On
                [cpy cpx]=find(Ilabel(:,:,CurrentFrame) > 251);
                for n =1:length(cpy)
                    y = cpy(n); x = cpx(n);
                    if (y > Cpt(1)-WindowSize && y < Cpt(1)+WindowSize && x > Cpt(2)-WindowSize && x < Cpt(2)+WindowSize )
                        CelN = Clabel(y,x,CurrentFrame);
                        if CelN ==0
                            %disp('couldn''t find this one????');
                            col = [1 1 1];
                            TrackL = 0;
                            if Ch3On  && Ilabel(y, x,CurrentFrame) == 253
                                continue
                            end
                        else
                            col = CColors(CelN,:);
                            col = col*.8;
                            TrackL = 1;
                        end
                        
                        
                        if TrackL > 10
                          PaddedIm(y-1+100:y+1+100,x-1+100:x+1+100,1) = col(1);
                            PaddedIm(y-1+100:y+1+100,x-1+100:x+1+100,2) = col(2);
                            PaddedIm(y-1+100:y+1+100,x-1+100:x+1+100,3) = col(3);
                            if trackstarts(CelN) == CurrentFrame || trackstarts(CelN) + TrackL == CurrentFrame
                                PaddedIm(y-2+100:y+2+100,x+100,1) = col(1);
                                PaddedIm(y-2+100:y+2+100,x+100,2) = col(2);
                                PaddedIm(y-2+100:y+2+100,x+100,3) = col(3);
                                
                            end
                            
                        else
                            PaddedIm(y+100,x+100,1) = col(1);
                            PaddedIm(y+100,x+100,2) = col(2);
                            PaddedIm(y+100,x+100,3) = col(3);
                        end
                    end
                end
            end
            if showCells
                PaddedIm(100:end-101,100:end-101,1) = .5*double(cellBoundaries(:,:,CurrentFrame)) + PaddedIm(100:end-101,100:end-101,1).*(1-double(cellBoundaries(:,:,CurrentFrame)));
                PaddedIm(100:end-101,100:end-101,2) = .2*double(cellBoundaries(:,:,CurrentFrame)) + PaddedIm(100:end-101,100:end-101,2).*(1-double(cellBoundaries(:,:,CurrentFrame)));
                PaddedIm(100:end-101,100:end-101,3) = .2*double(cellBoundaries(:,:,CurrentFrame)) + PaddedIm(100:end-101,100:end-101,3).*(1-double(cellBoundaries(:,:,CurrentFrame)));
            end
            
            if Ch2On && ~isempty(DivCellsMask) % show dividing cells
                PaddedCimg = zeros(s(1)+200,s(2)+200);
                PaddedCimg(100:99+s(1), 100:99+s(2)) = DivCellsMask(:,:,CurrentFrame);
                PaddedIm(:,:,1) = PaddedIm(:,:,1) + 0.3*PaddedCimg;
            end
            img = imshow(PaddedIm(Cpt(1)-WindowSize+100:Cpt(1)+WindowSize+100,Cpt(2)-WindowSize+100:Cpt(2)+WindowSize+100,:));
            
        else
            
            Irgb = gray2rgb(I1(:,:,CurrentFrame));
            
            if Ch1On
                [cpy cpx]=find(Ilabel(:,:,CurrentFrame) > 251);
                for n =1:length(cpy)
                    y = cpy(n); x = cpx(n);
                    CelN = Clabel(y,x,CurrentFrame);
                    if CelN ==0
                        col = [1 1 1];
                        if Ch3On  && Clabel(y,x,CurrentFrame) == 0
                            continue
                        end
                    else
                        col = CColors(CelN,:);
                        col = col*.8;
                        TrackL = 1;
                    end
                    
                    ymin = max(y-1,1); ymax = min(y+1,s(1));
                    xmin = max(x-1,1); xmax = min(x+1,s(2));
                    Irgb(ymin:ymax,xmin:xmax,1) = col(1);
                    Irgb(ymin:ymax,xmin:xmax,2) = col(2);
                    Irgb(ymin:ymax,xmin:xmax,3) = col(3);
                end
            end
            if showCells
                Irgb(:,:,1) = .5*double(cellBoundaries(:,:,CurrentFrame)) + Irgb(:,:,1).*(1-double(cellBoundaries(:,:,CurrentFrame)));
            end
            if Ch2On && ~isempty(DivCellsMask) % show dividing cells
                Irgb(:,:,1) = Irgb(:,:,1) + 0.3*DivCellsMask(:,:,CurrentFrame);
            end
            if getPoint == 'b'
                for j= 1: size(BoundaryPts,1)
                    Irgb = DrawPt(Irgb,BoundaryPts(j,:),2);
                end
            end
                
            img = imshow(Irgb);
        end
        
        
        set(img,'ButtonDownFcn',@wbmFcn)
        set(framenum,'String',CurrentFrame);
        drawnow 
    end

    function deletePt(x,y,Frame)
        Ilabel(y, x,Frame) = 127;
        Itracks(y,x,Frame) = 0;
        Clabel(y,x,Frame) = 0;
    end

    function neutralisePt(x,y,Frame)
        Ilabel(y, x,Frame) = 253;
        Itracks(y,x,Frame) = 0;
        %Clabel(:,:,Frame) = Clabel.*uint16(Clabel~=Clabel(y,x));
        Clabel(y,x,Frame) = 0;
    end

    function deletePtsAround(pt)
        [cpy cpx]=find(Ilabel(:,:,CurrentFrame) > 252);
        for n =1:length(cpy)
            y = cpy(n); x = cpx(n);
            dist = sqrt((y-pt(2))^2 + (x-pt(1))^2);
            if dist < 20
                neutralisePt(x,y,CurrentFrame);
            end
        end
    end

    function wbmFcn(src,evt)
        pt = get(gca,'Currentpoint');
        pt = round([pt(1,1), pt(1,2)]);
        mouseuse  = get(gcf,'SelectionType');
        if pt(1,1) > s(2) || pt(1,2) > s(1)
            return
        end
        
        if strcmp(mouseuse ,'normal')
            NClicks = NClicks + 1;
            if zoommode
                if isempty(find(FramesToRegrow==CurrentFrame) )
                    FramesToRegrow(length(FramesToRegrow)+1) = CurrentFrame;
                end
                if ~delabelMode
                    [cpy cpx]=find(Ilabel(:,:,CurrentFrame) > 252);
                    OnASeed = false;
                    for n =1:length(cpy)
                        y = cpy(n); x = cpx(n);
                        if (y > pt(2)-3 + Cpt(1)-WindowSize && y < pt(2)+1 + Cpt(1)-WindowSize && x > pt(1)-3 + Cpt(2)-WindowSize && x < pt(1)+1 + Cpt(2)-WindowSize)
                            if ~RemoveTrack 
                                deletePt(x,y,CurrentFrame);
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
                    if ~OnASeed
                        if ~AddDummyPt
                            Ilabel(Cpt(1)-WindowSize+pt(2)-1, Cpt(2)-WindowSize+pt(1)-1,CurrentFrame) = SeedMarker;
                        else
                            Ilabel(Cpt(1)-WindowSize+pt(2)-1, Cpt(2)-WindowSize+pt(1)-1,CurrentFrame) = 253;
                            Clabel(Cpt(1)-WindowSize+pt(2)-1, Cpt(2)-WindowSize+pt(1)-1,CurrentFrame) = 0;
                            AddDummyPt = false;
                        end
                    end
                else
                    % delete Label here!
                    lbl = Clabel(pt(2) + Cpt(1)-WindowSize,pt(1) + Cpt(2)-WindowSize,CurrentFrame);
                    if lbl ~= 0                       
                        F = Ilabel(:,:,CurrentFrame);
                        C = Clabel(:,:,CurrentFrame);
                        Cnum = C(Cpt(1)-WindowSize+pt(2)-1,Cpt(2)-WindowSize+pt(1)-1);
                        if Cnum == 0 
                            return 
                        end
                        Clabel(:,:,CurrentFrame) = C.*uint16(C~=Cnum);
                        
                        F = F.*uint8(C==Cnum);
                        [cpy cpx]=find(F > 252);
                        neutralisePt(cpx,cpy,CurrentFrame);
                        
                        cellBoundaries(:,:,CurrentFrame) = filter2(fs,Clabel(:,:,CurrentFrame)) >.5;
                    end
                end
            else
                if delabelMode
                    deletePtsAround(pt)
                    cellBoundaries(:,:,CurrentFrame) = filter2(fs,Clabel(:,:,CurrentFrame)) >.5;
                    set(fig,'WindowButtonMotionFcn',@wbmcbDel);
                    set(fig,'WindowButtonUpFcn',@wbucbDel);
                else
                    if getPoints
                        switch getPoint
                            case 'c'
                                Center = [pt(1) pt(2)];
                                disp('centre is set');
                                getPoint = 'bb';
                            case 'bb'
                                BoundaryPt = [pt(1) pt(2)];
                                disp('Boundary pt is set');
                                getPoint = 'd';
                            case 'd'
                                DirectionPt = [pt(1) pt(2)];
                                disp('Direction pt is set, please now click Boudary points');
                                getPoint = 'b';
                                BoundaryPts = [];
                            case 'b'
                                Pt = [pt(1) pt(2)];
                                BoundaryPts = [BoundaryPts ; Pt];
                                Update();
                        end
                        return
                    end
                    
                    zoommode = true;
                    Cpt = [pt(2) pt(1)];
                    CCellNum = 0;
                end
            end
        end
        
        if strcmp(mouseuse ,'alt')
            if zoommode
                [cpy cpx]=find(Ilabel(:,:,CurrentFrame) > 251);
                for n =1:length(cpy)
                    y = cpy(n); x = cpx(n);
                    if (y > pt(2)-3 + Cpt(1)-WindowSize && y < pt(2)+1 + Cpt(1)-WindowSize && x > pt(1)-3 + Cpt(2)-WindowSize && x < pt(1)+1 + Cpt(2)-WindowSize)
                        
                        fprintf('label=%i x=%i y=%i \n' ,Ilabel(y, x,CurrentFrame),x,y);
                        
                        PropsOfCell([x,y]);
                        break
                    end
                end
                xinit = pt(1); yinit = pt(2);
                Cptinit = Cpt;
                set(fig,'WindowButtonMotionFcn',@wbmcb);
                set(fig,'WindowButtonUpFcn',@wbucb);
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
        
        Update();
        
        function wbmcb(src,evnt)
            cp = get(gca,'CurrentPoint');
            xdat = [xinit,cp(1,1)];
            ydat = [yinit,cp(1,2)];
            Cpt(1) = round(Cptinit(1)-cp(1,2)+yinit);
            Cpt(2) = round(Cptinit(2)-cp(1,1)+xinit);
            Update();
        end
        function wbucb(src,evnt)
            set(src,'Pointer','arrow')
            set(src,'WindowButtonMotionFcn','')
            set(src,'WindowButtonUpFcn','')
        end
        
        function wbmcbDel(src,evnt)
            cp = get(gca,'CurrentPoint');
            cp = round([cp(1,1), cp(1,2)]);
            deletePtsAround(cp)
            Update();
        end
        function wbucbDel(src,evnt)
            set(src,'WindowButtonMotionFcn','')
            set(src,'WindowButtonUpFcn','')
        end
        
    end
        
    function keyPrsFcn(src,evt)
        ch = get(gcf,'CurrentCharacter');
        switch ch
            case {' '}
                zoommode = false;
                %Retrack();
                Update();
            case {'s'}
                fprintf('Saving to OMERO');
                SaveToOMERO()                
                fprintf('done\n');
            case {'o'}
                [ResX, ResY, ResZ] = GetResolution(OMERO.session, OMERO.ImageId);
                GeneratePrettyPic(I1(:,:,CurrentFrame),Clabel(:,:,CurrentFrame),ResX);
            case {'d'}
                if ~deleteMode
                    disp('delete mode!')
                    deleteMode = true;
                else
                    disp('delete mode OFF!')
                    deleteMode = false;
                end
            case {'g'}
                GrowCellsInFrame(CurrentFrame);
                showCells = true;
                Update();
            case {'h'}
                if showCells
                    showCells = false;
                else
                    showCells = true;
                end
                Update();
            case {'l'}
                if ~delabelMode
                    disp('de-Label mode!')
                    delabelMode = true;
                else
                    disp('delete mode OFF!')
                    delabelMode = false;
                end
%             case {'c'}
%                 disp('setting the centre of the disk')
%                 getPoints = true;

            case {'a'}
                AddDummyPt = true;
                
            case {'p'}
                % load previous segmentation
                LoadOriginalSeg();
                
            case {'u'}
                % save updated surface projection
                SaveProjection();
            
            case {'q'} % set up for re-projection
                LoadImStack()
                
            case 13
                switch getPoint
                    case 'b'
                    disp('Got Boundary points');
                    getPoint = false;
                    Analysis()
                end
                
        end
    end

    function SaveToOMERO()
        % ok now save all this
        disp('saving to OMERO');
        DeletePrevious(OMERO.session,OMERO.AnalysisSetId,OMERO.FinalSegmentationLabels);
        [ImId,handle] = CreateNewImageSet(OMERO.session, 'uint16',s(1),s(2),s(3), OMERO.FinalSegmentationLabels , 'Labels coming out of segmentation', OMERO.ProjectId,OMERO.AnalysisSetId);
        for f=1:s(3)
            WriteIm2OMERO(OMERO.session,handle,Clabel(:,:,f),f-1);
        end
        
        DeletePrevious(OMERO.session,OMERO.AnalysisSetId,OMERO.FinalSeeds);
        [ImId,handle] = CreateNewImageSet(OMERO.session, 'uint8',s(1),s(2),s(3), OMERO.FinalSeeds, 'seeds coming out of segmentation', OMERO.ProjectId,OMERO.AnalysisSetId);
        for f=1:s(3)
            WriteIm2OMERO(OMERO.session,handle,Ilabel(:,:,f),f-1);
        end
    end

    function SaveProjection()
        disp('Saving new projection')
        DeletePrevious(OMERO.session,OMERO.AnalysisSetId,OMERO.ProjectionName);
        [ImId,handle] = CreateNewImageSet(OMERO.session,  'uint16',OMERO.ImSize(1),OMERO.ImSize(2),1, OMERO.ProjectionName, 'projection of the 3D data using fitted surface on original data', OMERO.ProjectId,OMERO.AnalysisSetId);
        WriteIm2OMERO(OMERO.session,handle,I1,0);
        
        DeletePrevious(OMERO.session,OMERO.AnalysisSetId,OMERO.SurfaceName);
        [ImId2,handle2] = CreateNewImageSet(OMERO.session,  'uint16',OMERO.ImSize(1),OMERO.ImSize(2),1, OMERO.SurfaceName, 'fitted surface on original data', OMERO.ProjectId,OMERO.AnalysisSetId);
        WriteIm2OMERO(OMERO.session,handle2,Surface,0);
        
        DeletePrevious(OMERO.session,OMERO.AnalysisSetId,OMERO.Seeds);
        [ImId,handle] = CreateNewImageSet(OMERO.session, 'uint8',s(1),s(2),s(3), OMERO.Seeds, 'seeds coming out of segmentation', OMERO.ProjectId,OMERO.AnalysisSetId);
        WriteIm2OMERO(OMERO.session,handle,Ilabel(:,:),0);
        disp('done');
    end

    function LoadSavedSeg()
        disp('Loading saved segmentation')
        SegLabelID = ImageExists(OMERO.session, OMERO.AnalysisSetId,OMERO.FinalSegmentationLabels);
        if ~SegLabelID
            disp('can''t find Final Segmented stack');
            return
        end
        Clabel = OMEROGetTimeCourse(OMERO.session,SegLabelID);
        NC=max(Clabel(:));
        CColors = double(squeeze(label2rgb([1:NC],'jet','k','shuffle')))/255.;
        
        
        SeedsID = ImageExists(OMERO.session, OMERO.AnalysisSetId,OMERO.FinalSeeds);
        if ~SeedsID
            disp('can''t find Final Seeds stack');
            return
        end
        Ilabel = OMEROGetTimeCourse(OMERO.session,SeedsID,'uint8');
    end


    function LoadOriginalSeg()
        % getting data from OMERO
        disp('Loading orginal segmentation')
        SegLabelID = ImageExists(OMERO.session, OMERO.AnalysisSetId,OMERO.SegmentationLabels);
        if ~SegLabelID
            disp('can''t find Segmented stack');
            return
        end
        Clabel = OMEROGetTimeCourse(OMERO.session,SegLabelID);
        NC=max(Clabel(:));
        CColors = double(squeeze(label2rgb([1:NC],'jet','k','shuffle')))/255.;
        
        SeedsID = ImageExists(OMERO.session, OMERO.AnalysisSetId,OMERO.Seeds);
        if ~SeedsID
            disp('can''t find Seeds stack');
            return
        end
        Ilabel = OMEROGetTimeCourse(OMERO.session,SeedsID,'uint8');
    end

    function FinalGrowClean(src,evt)
        % first regrow and clean labels
        %                 F = Ilabel(:,:,CurrentFrame);
        %                 F2 = F;
        %                 F(F==253) = 255;
        %Ilabel(:,:,CurrentFrame) = F;
        GrowCellsInFrame(CurrentFrame);
        %Ilabel(:,:,CurrentFrame) = F2;
        %UnlabelPoorSeedsInFrame(CurrentFrame);
        %RemoveShortTracksInFrame(CurrentFrame)
        Update();   drawnow
        %UnlabelSeeds(CurrentFrame);
    end
                         
 


    function GrowCellsInFrame(f)
        tic
        if SurfWorks
            disp('need to restart to be able to grow cells');
        end
        fprintf('Growing cells!\n');
        bw=double(Ilabel(:,:,f) > 251); % find labels
        I = double(I1(:,:,f)).*(1-bw)+255*bw; % mark labels on image
        Ilabel2=growcellsfromseeds(I,252);
        
        % remove neutralised cells
        [cpy cpx] = find(Ilabel(:,:,f) == 253);
        for c = 1:length(cpx)
            Cnum = Ilabel2(cpy(c),cpx(c));
            if Cnum == 0
                continue
            end
            Ilabel2 = Ilabel2.*(Ilabel2~=Cnum);
        end
        cellBoundaries(:,:,f) = filter2(fs,Ilabel2) >.5;
        Clabel(:,:,f) = Ilabel2;
        
        NC=max(Clabel(:));
        CColors = double(squeeze(label2rgb([1:NC],'jet','k','shuffle')))/255.;
        
        fprintf('Done!')
        toc
       
    end

    function UnlabelPoorSeeds()
        for f = 1: s(3)
            disp(f)
            UnlabelPoorSeedsInFrame(f)
        end
    end

    function UnlabelPoorSeedsInFrame(f)
        tic
        fprintf('de-labelling: removing poor labels')
        L = Clabel(:,:,f);
        F = Ilabel(:,:,f);
        Clist = unique(L);
        Clist = Clist(Clist~=0);
        for c = 1:length(Clist)
            m = L==Clist(c);
            [cpy cpx]=find(m > 0);
            minx = min(cpx); maxx = max(cpx);
            miny = min(cpy); maxy = max(cpy);
            minx = max(minx-5,1); miny = max(miny-5,1);
            maxx = min(maxx+5,s(2)); maxy = min(maxy+5,s(1));
            m1 = m(miny:maxy, minx:maxx);
            F1 = F(miny:maxy, minx:maxx);
            Di = imdilate(m1, se);
            Er = imerode(m1, se);
            Fr = Di - Er;
            IFr = F1(Fr>0);
            IEr = F1(Er>0);
            IBound = mean(IFr);
            H = F1(Fr>0);
            ICentre = mean(IEr);
            %fprintf('%f %f\n',IBound,ICentre)
            %IBounds(length(IBounds)+1) = IBound;
            %ICentres(length(ICentres)+1) = ICentre;
            
            if ( IBound < 30 && IBound/ICentre < 1.2 ) ...
                    || IBound < 25 ...
                    || min(IFr)==0 ...
                    || sum(H<20)/length(H) > 0.1
                Clabel(:,:,f) = Clabel(:,:,f).*uint16(m==0);
            end
            
            
        end
        cellBoundaries(:,:,f) = filter2(fs,Clabel(:,:,f)) >.5;
        fprintf('done')
        toc
    end

    function PropsOfCell(pt)
        L = Clabel(:,:,CurrentFrame);
        F = Ilabel(:,:,CurrentFrame);
        Cnum = L(pt(2),pt(1));
        if Cnum == 0
            return
        end
        m = L==Cnum;
        Di = imdilate(m, se);
        Er = imerode(m, se);
        Fr = Di - Er;
        IBound = mean(F(Fr>0));
        H = F(Fr>0);
        %hist(H(:));
        ICentre = mean(F(Er>0));
        F1 = F;
        F1(~m) = 0;
        [cpy cpx]=find(F1 > 252);
        Cnum2 = Itracks(cpy,cpx,CurrentFrame);
        if Cnum2 ~=0
            leng = tracklength(Cnum2);
            st = trackstarts(Cnum2);
        else
            leng = 1;
            st = CurrentFrame;
        end
        
        fprintf('Boundary=%f Centre=%f B/C=%f minB=%f Labelnum=%i \nTracknum=%i PixVal=%i track length=%i start=%i\n',IBound,ICentre,IBound/ICentre,min(F(Fr>0)),Cnum,Cnum2, F(cpy,cpx),  leng,st);
        fprintf('Ratio of low signal = %f\n', sum(H<20)/length(H));
    end
        
    function RecalculateCellBoundaries()
        for ff = 1:s(3)
            cellBoundaries(:,:,ff) = filter2(fs,Clabel(:,:,ff)) >.5;
        end
    end




%%
%%%%%%%%%%%%%%%%
%  ANALYSIS
%%%%%%%%%%%%%%%%

As ={};
CorrectedAs = [];
SCorrectedAs = [];
Orient ={};
D = {};
DD = [];

Nbins = 50;
Dmax = 0;
BinSize = 0;
Dbin = 0;
ResX = 0; ResY = 0; ResZ = 0;
DS = []; SCorrTerm = [];
OXs = {};
OYs = {};
MajAx ={};
MinAx ={};
MajAxCorrected = [];
MinAxCorrected = [];
ERs = {};
ERsCorrected = {};
Centers ={};
Gridsize = 25;
NX = 0;
NY = 0;
CellDivTracking = containers.Map('KeyType','int32','ValueType','any');
DivcellList = [];
DivCellsMask = [];
V1 = [];
V2 = [];
RCenters = [];

   
    function AnalysisClbk(src,evt)
        
        if delabelMode
            delabelMode = false;
        end
            
        AnalysisCalled = true;
        disp('Click on center of disk to launch analysis')
        getPoints = true;
        getPoint = 'c';
    end

    function MakeMovie()
        clear('M');
        for i = 1:s(3)
            CurrentFrame = i;
            Update();
            M(i) = getframe;
        end
        
        movie2avi(M, '../../Figs/SegmentedStack2.avi', 'quality', 50,'fps',10);
    end

    function Analysis()
        fprintf('Getting data out of segmented frames \n');
        [ResX, ResY, ResZ] = GetResolution(OMERO.session, OMERO.ImageId);
        GrowCellsInFrame(CurrentFrame);
        Update(); drawnow
        AnalyseFrame();
        CreateARadialGraph();
        CreateERRadialGraph();
        CreateORadialGraph();
        SaveToOMERO();
        fprintf('saving analysis to %s\n', OMERO.AnalysisName);
        save(OMERO.AnalysisName,'As','Orient','MajAx','MinAx','ERs','Centers','Center', 'BoundaryPt', 'BoundaryPts','DirectionPt','D','DD','DS','SCorrTerm','ERsCorrected','ResX','V1','V2','RCenters', 'CorrectedAs','SCorrectedAs');
        disp('GOOD to GO!')
    end

    function DivCAnalysisClbk(src,evt)
        if ~isempty(FramesToRegrow)
            FinalGrowClean();
            Analysis();
        end
        tic
        CellDivTracking = containers.Map('KeyType','int32','ValueType','any');
        fprintf('Analysing dividing cells ');
        % detect and measure cell divisions
        % first create a list of all cells which have an area greater than 600 say
        for f = 1:s(3)
            l = find(As{f} > 600);
            L= Clabel(:,:,f);
            T= Itracks(:,:,f);
            m = ismember(L, l);
            list = unique( T(m));
            list = list(list~=0);
            for lll = 1:length(list)
                if ~isKey(CellDivTracking,list(lll))
                    CellDivTracking(list(lll)) = [];
                end
            end
        end
        
        % ok got all the dividing cells now track them!!
        DivcellList = keys(CellDivTracking);
        for c=1:CellDivTracking.Count
            Cnum= DivcellList{c};
            Cstrt = trackstarts(Cnum);
            Clen = tracklength(Cnum);
            for f=Cstrt:Cstrt+Clen
                [cpy cpx] = find(Itracks(:,:,f) == Cnum);
                lbl = Clabel(cpy,cpx,f);
                A = As{f}(lbl);
                CellDivTracking(Cnum)  = [CellDivTracking(Cnum) A];
            end
        end
        
        % visualise tracks
        DivcellList = keys(CellDivTracking);
        DivCellsMask = zeros(s);
        for c=1:CellDivTracking.Count
            Cnum= DivcellList{c};
            Cstrt = trackstarts(Cnum);
            Clen = tracklength(Cnum);
            for f=Cstrt:Cstrt+Clen
                [cpy cpx] = find(Itracks(:,:,f) == Cnum);
                lbl = Clabel(cpy,cpx,f);
                DivCellsMask(:,:,f) = DivCellsMask(:,:,f)+double(Clabel(:,:,f)==lbl);
            end
        end
        
        
        toc
    end

    function AnalyseFrame()
        L = Clabel(:,:);
        F = Ilabel(:,:);
        Clist = unique(L);
        Clist = Clist(Clist~=0);
        Props = regionprops(L,'Area','Orientation','Majoraxislength','Minoraxislength','Centroid');
        As = [Props.Area];
        CorrectedAs = As * ResX * ResX;
        Orient = [Props.Orientation];
        Orient(As<10) = nan;                      % only use cells w areas larger than 10
        MajAx = [Props.MajorAxisLength];
        MinAx = [Props.MinorAxisLength];
        ERs = [Props.MajorAxisLength]./[Props.MinorAxisLength];
        Centers = reshape([Props.Centroid],2,length([Props.Area]))';
        
        D = Centers-repmat(Center,[size(Centers,1),1]);
        D = sqrt(sum(D.*D,2));
        %D = D*ResX;        % correcting in WingDiskAna 
        figure, hist(D*ResX,100); title 'histogram of distances to the center'
        
        
        % calculate surface corrections
        % calc slope of surface
        %figure, contourf(Surface,20,'edgecolor','None'), colorbar
        f3=fspecial( 'gaussian', [s(1) s(2)], 10);
        SSurface = real(fftshift(ifft2(fft2(Surface).*fft2(f3))));      % need to smooth surface
        DxS = zeros(s); DyS = zeros(s);
        DxS( 1:s(1)-1 , : ) = ( SSurface(2:s(1),:) - SSurface(1:s(1)-1,:) )*ResZ;
        DxS(s(1),:) = DxS(s(1)-1,:);        % padding
        DyS( : , 1:s(2)-1 ) = ( SSurface(:,2:s(2)) - SSurface(:,1:s(2)-1) )*ResZ;
        DxS(:,s(2)) = DxS(:,s(2)-1);        % padding
        DS = (DxS + DyS)/sqrt(2.);
        SCorrTerm = sqrt(1 + DS.^2);
        %figure, contourf(flipud(SCorrTerm),100,'edgecolor','None'), colorbar, title 'Surface correction term'

        DxSn = DxS./DS;
        DySn = DyS./DS;
        
        XOrient = cos(Orient);
        YOrient = sin(Orient);
        
        for c = 1:length(Orient)
            x = round(Centers(c,1)); y = round(Centers(c,2));
            if isnan(x)
                MajAxCorrected(c) = nan;
                MinAxCorrected(c) = nan;
                continue; 
            end
            MajAxCorrected(c) = MajAx(c)* sqrt(1 + (SCorrTerm(x,y)^2 - 1) * (DxSn(x,y)*XOrient(c) + DySn(x,y)*YOrient(c))^2);
            MinAxCorrected(c) = MinAx(c)* sqrt(1 + (SCorrTerm(x,y)^2 - 1) * (- DxSn(x,y)*YOrient(c) + DySn(x,y)*XOrient(c))^2);
            
            SCorrectedAs(c) = CorrectedAs(c) * SCorrTerm(x,y);
        end
        ERsCorrected = MajAxCorrected./MinAxCorrected;  
        %figure, hist(ERs(~isnan(ERs)) ./ ERsCorrected(~isnan(ERs)),100), title 'hist of corrections to ER'
        
        
        
        
        Nbins = 20;
        Dmax = max(D);
        BinSize = ceil(Dmax/Nbins);
        Dbin = ceil(D/BinSize);
        
        % new coordinate system
        V1 = BoundaryPt - Center;
        V1 = V1/double(norm(V1));
        V2 = [V1(2) -V1(1)];
        V3 = DirectionPt-Center;
        V3 = V3/double(norm(V3));
        if dot(V3,V2) < 0 
            V2 = -V2;
        end
        %fprintf('V1=(%f,%f) V2=(%f,%f)\n', V1(1), V1(2), V2(1), V2(2));
        OCenters = Centers - repmat(Center,[size(Centers,1),1]);
        RCenters2(:,1) = OCenters(:,1)*V1(1) + OCenters(:,2)*V1(2);
        RCenters2(:,2) = OCenters(:,1)*V2(1) + OCenters(:,2)*V2(2);
        
        RCenters(:,1) = (Centers(:,1)-Center(1))*V1(1) + (Centers(:,2)-Center(2))*V1(2);
        RCenters(:,2) = (Centers(:,1)-Center(1))*V2(1) + (Centers(:,2)-Center(2))*V2(2);
        
        % use resolution
        RCenters = RCenters * ResX;
        %figure, plot(Centers(:,2) , -Centers(:,1) ,'.'), axis equal
        %figure, plot(OCenters(:,2) , -OCenters(:,1) ,'.'), axis equal
        figure, plot(RCenters(:,1), -RCenters(:,2),'.'), axis equal
    end


    function CreateARadialGraph()  
        G = [];
        stdE = [];
        for i=1:Nbins
            G(i) = mean(CorrectedAs(Dbin==i));
            stdE(i) = std(CorrectedAs(Dbin==i));
        end
        %X = 0:BinSize:(Dmax-BinSize/2.+.001) + BinSize/2.;
        X = 1:length(G);
        figure; subplot(2,2,1); errorbar(X*ResX,G,stdE); title 'Radial Area plot'; xlabel 'distance nm'
               
    end

    function CreateERRadialGraph()  
        G = [];
        stdE = [];
        for i=1:Nbins
            G(i) = mean(ERs(Dbin==i));
            stdE(i) = std(ERs(Dbin==i));
        end
        %X = 0:BinSize:(Dmax-BinSize/2.) + BinSize/2.;
        X = 1:length(G);
        subplot(2,2,2); errorbar(X*ResX,G,stdE); title 'Radial ER plot'; xlabel 'distance nm'
               
    end

    function CreateORadialGraph()
        G = [];
        stdE = [];
        DD = Centers - repmat(Center,[size(Centers,1),1]);
        COrient = atan(DD(:,2)./DD(:,1)) / pi * 180;
        ROrient = Orient' + COrient;
        ROrient(ROrient>90) = ROrient(ROrient>90) - 180;
        ROrient(ROrient<-90) = ROrient(ROrient<-90) + 180;
        
%         figure, plot(abs(ROrient(Dbin<5)),ERs(Dbin<5),'.'), hold on ; plot(abs(ROrient(Dbin>7)),ERs(Dbin>7),'r.')
%         
%         N = BinData2(abs(ROrient(Dbin > 7)),ERs(Dbin > 7),0,90,0,5,10,10);
%         figure, contourf(N',20,'edgecolor','None');  colorbar
%         
%         [X,Y,N] = BinData3(abs(ROrient(Dbin > 7)),ERs(Dbin > 7),0,90,0,4,8,9);
%         f1 = figure, contourf(X,Y,N',20,'edgecolor','None');  colorbar
%         
%         [X,Y,N] = BinData3(abs(ROrient(Dbin < 5)),ERs(Dbin < 5),0,90,0,4,8,10);
%         f2 = figure, contourf(X,Y,N',20,'edgecolor','None');  colorbar
        
        [X,Y,N] = BinData3(abs(ROrient(Dbin > 7)),ERsCorrected(Dbin > 7),0,90,0,4,8,9);
        subplot(2,2,4);  contourf(X,Y,N',20,'edgecolor','None');  colorbar, title 'bins > 7 corrected'; xlabel 'angle'
        
        [X,Y,N] = BinData3(abs(ROrient(Dbin < 5)),ERsCorrected(Dbin < 5),0,90,0,4,8,10);
        subplot(2,2,3);  contourf(X,Y,N',20,'edgecolor','None');  colorbar, title 'bins < 5 corrected'; xlabel 'angle'
        
        
%         
%         
%         for i=1:Nbins
%             % # 1  using more sophisticated weighted histogram method
%             dat = ROrient(Dbin==i);
%             %W = ones(size(dat));
%             W = ERs(Dbin==i)-1;
%             [G(i),stdE(i)] = MaxOnCircularData(dat,W);
%             
% %             % #2 using crude approach
% %             Odat = Orient(Dbin==i);
% %             Odat = Odat(~isnan(Odat));
% %             G(i) = mean(Odat);
% %             stdE(i) = std(Odat);
%             
%         end
%         X = 0:BinSize:(Dmax-BinSize/2.) + BinSize/2.;
%         figure, plot(X*ResX,abs(G)); title 'RadialOrientation plot'
    end 

    function N = BinData2(X,Y,Xmin,Xmax,Ymin,Ymax,NX,NY)
        good = ~(isnan(X) + isnan(Y'));
        X = X(good);
        Y = Y(good);
        XBinSize = (Xmax - Xmin + .01)/NX;
        YBinSize = (Ymax - Ymin + .01)/NY;
        N = zeros([NX,NY]);
        for i = 1:length(X)
            ix = ceil(X(i)/XBinSize)
            iy = ceil(Y(i)/YBinSize)
            N(ix,iy) = N(ix,iy) + 1;
        end
    end

    function [Xrge,Yrge,N] = BinData3(X,Y,Xmin,Xmax,Ymin,Ymax,NX,NY)
        % here use different approach to span whole area of data
        % areas close to edges have only 1/2 the data as a consequence
        good = ~(isnan(X) + isnan(Y'));
        X = X(good);
        Y = Y(good);
        XBinSize = (Xmax - Xmin )/(NX-1);
        YBinSize = (Ymax - Ymin )/(NY-1);
        N = zeros([NX,NY]);
        for i = 1:length(X)
            ix = ceil((X(i)-Xmin+XBinSize/2.)/XBinSize);
            iy = ceil((Y(i)-Ymin+YBinSize/2.)/YBinSize);
            ix = min(max(ix,1),NX);
            iy = min(max(iy,1),NY);
            N(ix,iy) = N(ix,iy) + 1;
        end
        % now correct for size
        N(:,1) = N(:,1)*2;
        N(:,NY) = N(:,NY)*2;
        N(1,:) = N(1,:)*2;
        N(NX,:) = N(NX,:)*2;
        
        N = N/sum(N(:));
        
        Xrge = Xmin:XBinSize:Xmax;
        Yrge = Ymin:YBinSize:Ymax;
        
    end

    function CreateAGraphs(src,evt)
        
        CreateTimeLapse(As,3,1,100,500,false);
        
    end

%  [dataAs,err, N] = CreateGraph(As);
%         figure, contourf(flipud(N),20,'edgecolor','None');  axis equal; axis([1 20 1 17]); colorbar
%         title 'N statistic'
%         figure, contourf(flipud(dataAs),20,'edgecolor','None');  axis equal; axis([1 20 1 17]); colorbar
%         title('Areas');
%         
%         
%         

    function CreateOPlts(src,evt)
        % Orientation plot!!
        NX = ceil(s(1)/Gridsize);
        NY = ceil(s(2)/Gridsize);
        [dataERs,err,N] = CreateGraph(ERs);
%         figure, contourf(flipud(dataERs),20,'edgecolor','None');  axis equal; axis([1 NY 1 NX]); colorbar
%         title('ERs');
        [dataO,err,N] = CreateGraph(Orient, true);
%         figure, contourf(flipud(dataO),20,'edgecolor','None');  axis equal; axis([1 NY 1 NX]); colorbar
%         title('Orientation');
%         figure, contourf(flipud(err),20,'edgecolor','None');  axis equal; axis([1 NY 1 NX]); colorbar
%         title('Orientation err');

        dataO = flipud(dataO);
        dataERs = flipud(dataERs);
        
        DX = cos(dataO/180*pi).*(dataERs-1);
        DY = sin(dataO/180*pi).*(dataERs-1);

        [X,Y] = meshgrid(1:size(dataO,2),1:size(dataO,1));
        figure, contourf(dataERs,20,'edgecolor','None');  axis equal; axis([1 NY 1 NX]); colorbar
        hold on
        q=quiver(X,Y,DX,DY);
        set(q,'ShowArrowHead','off','AutoScale','off');
        set(q,'Color','black');
        q2=quiver(X,Y,-DX,-DY);
        set(q2,'ShowArrowHead','off','AutoScale','off');
        set(q2,'Color','black');
        hold off
    end

    function [data,N] = BinData(List)
        NX = ceil(s(1)/Gridsize);
        NY = ceil(s(2)/Gridsize);
        data = cell([NX,NY]);
        N = zeros([NX,NY],'int16');
        for f = 1:s(3)
            for p=1:length(List{f})
                x = Centers{f}(p,2);
                y = Centers{f}(p,1);
                if isnan(x) || isnan(y) %|| isnan(List{f}(p))
                    continue
                end
                if isnan(List{f}(p))
                    disp('fs')
                end
                ix = ceil(x/Gridsize);
                iy = ceil(y/Gridsize);
                data{ix,iy}(length(data{ix,iy})+1) =  List{f}(p);
                N(ix,iy) = N(ix,iy) + 1;
            end
        end
        
    end

    function [H,xout] = Whist(data,W,N)
        W=W(~isnan(data));
        data = data(~isnan(data));
        dmin = min(data);
        dmax = max(data);
        if length(data) == 1
            H = [W];
            xout = data(1);
            return
        end
        w = (dmax-dmin)/N;
        d = data - dmin + w;
        d = floor(d/w);
        d(d==N+1) = N;
        try
            H = accumarray(d, W)';
        catch
            disp('fsd')
        end
        xout = dmin+w/2.:w:dmax-w/2.+w/10.;
    end
        
      

    function [data2, data2e,N] = CreateGraph(List,circular)
        if nargin < 2
            circular = false;
        else
            [dataER,N] = BinData(ERs);
        end
        [data,N] = BinData(List);
        data2 = zeros([NX,NY]);
        data2e = zeros([NX,NY]);
        for ii=1:NX
            for j=1:NY
                if ~circular
                    data2(ii,j) = mean(data{ii,j});
                    data2e(ii,j) = std(data{ii,j});
                else
                    % weight the contribution to bins by the ER -1
                    if isempty(data{ii,j})
                        continue
                    end
                    if isnan(data{ii,j})
                        continue
                    end
                    %[n,xout] = hist(data{i,j},20);
                    [n2,xout2] = Whist(data{ii,j},dataER{ii,j}-1,20);
                    %figure , bar(xout2,n2)
                    
                    [C,I] = max(n2);
                    maxi = xout2(I);         % this an approximation of the mean value of the data, refold around this
                    d = data{ii,j};
                    d= d(~isnan(d));
                    m = d < maxi - 90;
                    m2 = d > maxi + 90;
                    d(m) = d(m) + 180;
                    d(m2) = d(m2) - 180;
                    data2(ii,j) = mean(d);
                    fprintf('diff = %f\n', abs(mean(d) - maxi));
                    data2e(ii,j) = std(d);
                end
            end
        end
        data2(N<10) = nan;          % only trust average if you have at least 10 values
        data2e(N<10) = nan;
    end

    function [Mean,stdE] = MaxOnCircularData(data,W)
        if max(W) ==0 || sum(~isnan(data)) == 0
            Mean = 0;
            stdE = 999;
            return
        end
        [n2,xout2] = Whist(data,W,20);
        %figure , bar(xout2,n2)
        [C,I] = max(n2);
        maxi = xout2(I);         % this an approximation of the mean value of the data, refold around this
        d = data;
        d= d(~isnan(d));
        m = d < maxi - 90;
        m2 = d > maxi + 90;
        d(m) = d(m) + 180;
        d(m2) = d(m2) - 180;
        Mean = mean(d);
        stdE = std(d);
    end

    function CreateTimeLapse(D,W,Step,zmin,zmax,circular)
        if nargin < 6
            circular = false;
        end
        % creates a time-lapse series from data D, using a window of data W before and after, with step step
        N = floor((s(3)-2*W-1)/Step);
        if (N-1)*Step + 2*W+1 > s(3)
            N = N -1;
        end
        Ms = zeros(ceil(s(1)/Gridsize),ceil(s(2)/Gridsize),N);
        Es = zeros(ceil(s(1)/Gridsize),ceil(s(2)/Gridsize),N);
        for i = 1:N
            pos = W+1 + (i-1)*Step;
            try
                [M,E] = GetDataMeanaStd(D,pos-W,pos+W,circular);
            catch
                disp('fs')
            end
            Ms(:,:,i) = M;
            Es(:,:,i) = E;
        end
        StackViewContour(Ms,zmin,zmax);
        %StackViewContour(Ms,min(Ms(:)),max(Ms(:)));
        StackViewContour(Es,min(Es(:)),max(Es(:)));
    end

    function [M,E] = GetDataMeanaStd(List,Strt,Fin,circular)
        if nargin < 4
            circular = false;
        end
        X = ceil(s(1)/Gridsize);
        Y = ceil(s(2)/Gridsize);
        data = cell([X,Y]);
        N = zeros([X,Y],'int16');
        for f = Strt:Fin
            for p=1:length(List{f})
                x = Centers{f}(p,2);
                y = Centers{f}(p,1);
                if isnan(x) || isnan(y) || isnan(List{f}(p))
                    continue
                end
                ix = ceil(x/Gridsize);
                iy = ceil(y/Gridsize);
                data{ix,iy}(length(data{ix,iy})+1) =  List{f}(p);
                N(ix,iy) = N(ix,iy) + 1;
            end
        end
        M = zeros([X,Y]);
        E = zeros([X,Y]);
        for ii=1:X
            for j=1:Y
                if ~circular
                    M(ii,j) = mean(data{ii,j});
                    E(ii,j) = std(data{ii,j});
                else
                    [n,xout] = hist(data{ii,j},20);
                    [C,I] = max(n);
                    maxi = xout(I);         % this an approximation of the mean value of the data, refold around this
                    d = data{ii,j};
                    m = data{ii,j} < maxi - 90;
                    m2 = data{ii,j} > maxi + 90;
                    d(m) = d(m) + 180;
                    d(m2) = d(m2) - 180;
                    M(ii,j) = mean(d);
                    E(ii,j) = std(d);
                end
            end
        end
%         M(N<10) = nan;          % only trust average if you have at least 10 values
%         E(N<10) = nan;
    end
     
    function CellDivClbk(src,evt)
        CellDiv();
    end
               
    function CellDiv()
        if ~isempty(FramesToRegrow)
            FinalGrowClean();
            Analysis();
            DivCAnalysisClbk();
        end
        % plot
        W = s(3);
        DivcellList = keys(CellDivTracking);
        S = zeros(2*W+2,CellDivTracking.Count);
        N = zeros(2*W+2,1);
        
        for c=1:CellDivTracking.Count
            Cnum= DivcellList{c};
            [C,I] = max(CellDivTracking(Cnum));
            d = zeros(4*W,1);
            d(2*W+-I:length(CellDivTracking(Cnum))-I+2*W-1) = CellDivTracking(Cnum);
            trlen = length(CellDivTracking(Cnum))-I;
            if trlen < 6
                % track too short for our purposes
                remove(CellDivTracking,Cnum);
                continue
            end
            baseline = mean(d(2*W-1+trlen-5:2*W-1+trlen));
%             if C/baseline < 2.5
%                 % probably not a dividing cell
%                 remove(CellDivTracking,Cnum);
%                 continue
%             end
            S(:,c) = S(:,c) + d(2*W-1:end)/baseline;
            n = d(2*W-1:end) ~=0;
            N = N + n;
        end
        
        
%         % visualise tracks
%         DivcellList = keys(CellDivTracking);
%         DivCellsMask = zeros(s);
%         for c=1:CellDivTracking.Count
%             Cnum= DivcellList{c};
%             Cstrt = trackstarts(Cnum);
%             Clen = tracklength(Cnum);
%             for f=Cstrt:Cstrt+Clen
%                 [cpy cpx] = find(Itracks(:,:,f) == Cnum);
%                 lbl = Clabel(cpy,cpx,f);
%                 DivCellsMask(:,:,f) = DivCellsMask(:,:,f)+double(Clabel(:,:,f)==lbl);
%             end
%         end
%         StackView(DivCellsMask);
        
        
        meanA = sum(S,2)./N;
        S(S==0) = nan;
        
        figure,plot(S(1:10,:))
        
        St = S-repmat(meanA,[1,size(S,2)]);
        St(isnan(St)) = 0;
        stdA = sqrt(sum(St.^2,2)./sum(~isnan(S),2));
        figure, errorbar(meanA(1:10), stdA(1:10),'*')
        
        
    end
        
end