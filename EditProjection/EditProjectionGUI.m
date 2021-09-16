function fig = EditProjectionGUI(Istack, zslices, frames)

%AUTHOR:   Andreas Hoppe (A.Hoppe@kingston.ac.uk)

% Create new figure        
fig = figure;

fig1=[];

threshold=1.2;

eraseCircle=70;

% initial configuration
frame=1;

zslice=1;

ViewMode = 2; % 1=projection, 2=stack

EraseMode = 0; % 1=enable eraser

MarkerMode = 1; % 1=markers, 2=all markers;
mpos=[0,0];

s=size(Istack);


% surface and projection data
markermap=zeros(s(1),s(2),frames,'uint8');
projections=zeros(s(1),s(2),frames,'uint16');
depthmaps=zeros(s(1),s(2),frames,'uint8');




% ------- Setting Up GUI -------------

set(fig,...
    'Name', 'Create and Edit Projection Markers',... 
    'Color', [0.314 0.314 0.314],...
    'Units', 'normalized',...
    'MenuBar','none',...
    'Position', [0 0 0.8 0.8]);

    % create long slider to control image time frame
    slider1 = uicontrol( fig ...
        ,'style'    ,'slider'   ...
        ,'units'    ,'normalized' ...
        ,'position' ,[0.25 0.02 0.50 0.025] ...
        );

    set(slider1,'min', 1);
    set(slider1,'max', frames);
    set(slider1,'Value', frame);

    addlistener(slider1,'ContinuousValueChange',@sliderActionEventTime);
    
    FrameNumLabel = uicontrol(fig ...
        ,'style'    ,'text' ...
        ,'units'    ,'normalized' ...
        ,'FontSize', 14 ...
        ,'position' ,[0.16 0.01 0.08 0.03] ...
        ,'string'   ,sprintf('Frame %d/%d',frame,frames) ...
        );
    
    
     % create short slider to control image z slice
    slider2 = uicontrol( fig ...
        ,'style'    ,'slider'   ...
        ,'units'    ,'normalized' ...
        ,'position' ,[0.25 0.05 0.50 0.025] ...
        );

    set(slider2,'min', 1);
    set(slider2,'max', zslices);
    set(slider2,'Value', zslice);

    addlistener(slider2,'ContinuousValueChange',@sliderActionEventDepth);
    
    SliceNumLabel = uicontrol(fig ...
        ,'style'    ,'text' ...
        ,'units'    ,'normalized' ...
        ,'FontSize', 14 ...
        ,'position' ,[0.16 0.04 0.08, 0.03] ...
        ,'string'   ,sprintf('z-slice %d/%d',zslice,zslices) ...
        );
    
    
    % threshold slider
    
    slider3 = uicontrol( fig ...
        ,'style'    ,'slider'   ...
        ,'units'    ,'normalized' ...
        ,'position' ,[0.05 0.87 0.07 0.02] ...
        );

    set(slider3,'min', 0);
    set(slider3,'max', 700);
    set(slider3,'Value', threshold*100);

    addlistener(slider3,'ContinuousValueChange',@sliderActionEventSensitivity);
    
    
    SensitivityLabel = uicontrol(fig ...
        ,'style'    ,'text' ...
        ,'units'    ,'normalized' ...
        ,'FontSize', 11 ...
        ,'position' ,[0.05 0.9 0.07, 0.02] ...
        ,'string'   , sprintf('Threshold %1.2f',threshold) ...
        );
    
    
    set (gcf, 'WindowButtonMotionFcn', @MouseMoveEvent);
    
    
    % ------  buttons --------------
    
    SuggestButton = uicontrol(fig ...
        ,'Style', 'pushbutton' ...
        ,'units'    ,'normalized' ...
        ,'FontSize', 14 ...
        ,'String', 'Find Markers'...
        ,'Position', [0.05 0.95 0.1 0.04]...
        ,'Callback', @SuggestMarkers ... 
        );
    
      
    SuggestAllMarkers = uicontrol(fig ...
        ,'Style', 'pushbutton' ...
        ,'units'    ,'normalized' ...
        ,'FontSize', 14 ...
        ,'String', 'Find All Markers'...
        ,'Position', [0.125 0.87 0.1 0.04]...
        ,'Callback', @SuggestMarkersAll ... 
        );
    
    
   ClearButton = uicontrol(fig ...
        ,'Style', 'pushbutton' ...
        ,'units'    ,'normalized' ...
        ,'FontSize', 14 ...
        ,'String', 'Clear Markers'...
        ,'Position', [0.15 0.95 0.1 0.04]...
        ,'Callback', @ClearMarkers ... 
        );
    
    
   ViewModeMenu = uicontrol('Style', 'popup',...
           'String', {'View Projection','View Stack'}...
           ,'units'    ,'normalized' ...
           ,'FontSize', 14 ...
           ,'Value', 2 ...
           ,'Position', [0.35 0.94 0.1 0.05]...
           ,'Callback', @SetViewMode...
           ); 
       
   MarkerModeMenu = uicontrol('Style', 'popup',...
           'String', {'slice','all'}...
           ,'units'    ,'normalized' ...
           ,'FontSize', 14 ...
           ,'Value', 1 ...
           ,'Position', [0.27 0.94 0.07 0.05]...
           ,'Callback', @SetMarkerMode...
           ); 
       
         
    ProjectionButton = uicontrol(fig ...
        ,'Style', 'pushbutton' ...
        ,'units'    ,'normalized' ...
        ,'FontSize', 14 ...
        ,'String', 'Projection'...
        ,'Position', [0.5 0.95 0.1 0.04]...
        ,'Callback', @MakeProjection ... 
        );
    
    
    
     LoadMarkersButton = uicontrol(fig ...
        ,'Style', 'pushbutton' ...
        ,'units'    ,'normalized' ...
        ,'FontSize', 14 ...
        ,'String', 'Load Markers'...
        ,'Position', [0.05 0.7 0.1 0.04]...
        ,'Callback', @LoadMarkers ... 
        );
    
    SaveMarkersButton = uicontrol(fig ...
        ,'Style', 'pushbutton' ...
        ,'units'    ,'normalized' ...
        ,'FontSize', 14 ...
        ,'String', 'Save Markers'...
        ,'Position', [0.05 0.65 0.1 0.04]...
        ,'Callback', @SaveMarkers ... 
        );
    
    FeedbackLabel = uicontrol(fig ...
        ,'style'    ,'text' ...
        ,'units'    ,'normalized' ...
        ,'FontSize', 14 ...
        ,'position' ,[0 0 0.15, 0.03] ...
        ,'string'   ,'Ready' ...
        );

Update();


function Update()
        
        figure(fig);
        
        
        if (ViewMode == 2)
        
            % ---------- Show Stack -----------------
        img=imshow(Istack(:,:,((frame-1)*zslices)+zslice),[]);
        
        
        else
          % ---------- Show Projection -----------------  
         img=imshow(projections(:,:,frame),[]);    
         
        end
        
        
         % show eraser marker
        if (EraseMode == 1)
        
            hold on,
            
            fig3=plot(mpos(1),mpos(2),'ro','MarkerSize', eraseCircle); 
            hold off
            
            removeMarker(mpos(2), mpos(1), eraseCircle);
            %set(fig3,'ButtonDownFcn',@MouseButtonDown);
            
        end
        
        if (MarkerMode==2)
            
        [vy,vx]=find(markermap(:,:,frame)>0);
        
        hold on
        fig1=plot(vx,vy,'ro','MarkerSize', 4); 
        hold off  
            
            
        end
        
        
        [vy,vx]=find(markermap(:,:,frame)==zslice);
        
        hold on
        fig1=plot(vx,vy,'go','MarkerSize', 4); 
        hold off
        
        
        
        set(fig1,'ButtonDownFcn',@MouseButtonDown);
        set(img,'ButtonDownFcn',@MouseButtonDown);
        
        set(FrameNumLabel,'string',sprintf('Frame %d/%d',frame,frames));
        
        set(SliceNumLabel,'string',sprintf('z-slice %d/%d',zslice,zslices));
        
        
end

% --- Event Handlers -----------------------


function sliderActionEventTime(src,evt)
        frame = round(get(src,'Value'));        
        Update();     
end


function sliderActionEventDepth(src,evt)
        zslice = round(get(src,'Value'));  
        Update(); 
end

function sliderActionEventSensitivity(src,evt)
        threshold = round(get(src,'Value'))/100;
        set(SensitivityLabel,'string',sprintf('Threshold %1.2f',threshold));
end


function SuggestMarkers(src,evt)
        
    
      set(FeedbackLabel,'string',sprintf('Finding markers %d/%d', frame, frames));
      drawnow;
    
      [newmap, depthmaps(:,:,frame)]=GuessMarkersFunc(Istack(:,:,((frame-1)*zslices)+1:frame*zslices), threshold);
    
             
      % new markers for the whole stack   
      markermap(:,:,frame)=newmap;  
     
    
    disp(sprintf('markers identified with threshold %1.2f',threshold));
    
    set(FeedbackLabel,'string','Ready');
    Update();
        
end

function SuggestMarkersAll(src,evt)
        
    
    for n=1:frames,
        
      frame=n;
    
      set(FeedbackLabel,'string',sprintf('Finding markers %d/%d', frame, frames));
      drawnow;
    
      [newmap, depthmaps(:,:,frame)]=GuessMarkersFunc(Istack(:,:,((frame-1)*zslices)+1:frame*zslices), threshold);
    
             
      % new markers for the whole stack   
      markermap(:,:,frame)=newmap;  
      Update();
     
    end
     
    
    disp(sprintf('markers identified with threshold %1.2f',threshold));
    
    set(FeedbackLabel,'string','Ready');
    Update();
        
end






function ClearMarkers(src,evt)
        
     % erase markes in slice
     map=markermap(:,:,frame);
     map(map==zslice)=0;
     markermap(:,:,frame)=map;   
    
    Update();
        
end


function MouseMoveEvent (object, eventdata)
    
     pt = get (gca, 'CurrentPoint');
     mpos=[pt(1,1) pt(1,2)];
    
    if (EraseMode==1)
        Update();    
    end
    

end



function SetViewMode(src,evt)
        
       ViewMode=get(src,'Value');
       Update();
        
end

function SetMarkerMode(src,evt)
        
       MarkerMode=get(src,'Value');
       Update();
        
end


function LoadMarkers(src,evt)
        
    [filename, pathname]=uigetfile('*.tif','Load Markers');
    if (filename==0)
     disp('no file selected');
    else
      markermap=imread3(fullfile(pathname,filename));
      disp(fullfile(pathname,filename));
    end
    Update();
    
end

function SaveMarkers(src,evt)
        
   [filename, pathname]=uiputfile('*.tif','Save Markers');
    if (filename==0)
     disp('no file selected');
    else
      imwrite3(uint8(markermap),fullfile(pathname,filename));
       disp(fullfile(pathname,filename));
    end 
   
end

function MakeProjection(src,evt)
        
    set(FeedbackLabel,'string','Constructing projection .....');
    drawnow;
    
    projection_image=CreateProjectionMarkers(Istack(:,:,((frame-1)*zslices)+1:frame*zslices), double(markermap(:,:,frame)));
    projections(:,:,frame)=projection_image;
    %figure(2), imshow(projection_image);
    
    
    set(FeedbackLabel,'string','Ready');
    
    ViewMode=1;  set(ViewModeMenu,'Value', ViewMode);
    Update();
    
   
   
end



% ---- handling mouse buttons ----

set(img,'ButtonDownFcn',@MouseButtonDown);


function MouseButtonDown(src,evt)
    
       pt = get(gca,'Currentpoint');
       
       mouseclick  = get(gcf,'SelectionType');
       
       if strcmp(mouseclick ,'normal')
       
       crd = round([pt(1,1), pt(1,2)]);
       
       % check bounds
       if (crd(1) < 1) crd(1)=1; end
       if (crd(1) > s(2)) crd(1)=s(2); end
       if (crd(2) < 1) crd(2)=1; end
       if (crd(2) > s(1)) crd(2)=s(1); end
       
       markermap(crd(2), crd(1), frame)=zslice;
       
       Update();
       end
       
       if strcmp(mouseclick ,'alt')
           
          crd = round([pt(1,1), pt(1,2)]);
          removeMarker(crd(2), crd(1), 20);
          Update();
           
       end
        
       
        
end


function removeMarker(x,y, mindistance)
    
     
     [vx,vy]=find(markermap(:,:,frame)==zslice);
    
     for n=1:length(vx)
         if (hypot(vx(n)-x,vy(n)-y) < mindistance)
           
            markermap(vx(n),vy(n),frame)=0; 
             
         end    
     end
     
end


%  ----- handling keyboard inputs -----


set(fig,'KeyPressFcn',@KeyPressEvent);

function KeyPressEvent(src,evt)
        ch = get(gcf,'CurrentCharacter');
        switch ch
            case {' ' , 29 }
                if frame < frames
                    frame = frame+1;
                end
                set(slider1,'Value', frame);
                Update();
                
            case 'a'
                if frame > 1
                    frame = frame-1;
                end
                set(slider1,'Value', frame);
                Update();
                
            case 'd'
                if frame < frames
                    frame = frame+1;
                end
                set(slider1,'Value', frame);
                Update();
                
            case ','
                if zslice > 1
                    zslice = zslice-1;
                end
                set(slider2,'Value', zslice);
                Update();
                
            case '.'
                if zslice < zslices
                    zslice = zslice+1;
                end
                set(slider2,'Value', zslice);
                Update();    
                
            case 'c'
                 map=markermap(:,:,frame);
                 map(map==zslice)=0;
                 markermap(:,:,frame)=map; 
                 Update();
            case 'm'
                SuggestMarkers();
            case 'p'
                if (ViewMode==1)
                     ViewMode=2;
                else
                     ViewMode=1;
                end
                  set(ViewModeMenu,'Value', ViewMode);
                   Update();
    
                   
            case 'e'
                if (EraseMode==0)
                    EraseMode=1;
                else
                    EraseMode=0;
                end
                Update();
                
                
            case '1'
                ViewMarkersMode=1;
                set(ViewMarkersMenu,'Value', 1);
                Update();
            case '2'
                ViewMarkersMode=2;
                set(ViewMarkersMenu,'Value', 2);
                Update();
                
        end
end



   
    

end
