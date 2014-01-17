function fig = ViewCellTrajs(Is,CLabels,Cells)

s = size(Is);


[cpx,cpy] = find(ismember(CLabels(:,:,1),Cells));
Mx = mean(cpx);
My = mean(cpy);


% 
% M = mean(Pts);
% Mx = mean([M(1),M(3)]);
% My = mean([M(2),M(4)]);
M = round([Mx , My]);
wind = 100;
Wminx = round(max(1,Mx-wind));
Wmaxx = round(min(s(1),Mx+wind));
Wminy = round(max(1,My-wind));
Wmaxy = round(min(s(1),My+wind));

Is = Is(Wminx:Wmaxx , Wminy:Wmaxy,:,:); 
CL = CLabels(Wminx:Wmaxx , Wminy:Wmaxy,:); 
i = 1;

fig = figure;

slider = uicontrol( fig ...
    ,'style'    ,'slider'   ...
    ,'units'    ,'normalized' ...
    ,'position' ,[0.17 0.05 0.80 0.04] ...
    );

% if version == '7.9.0.529 (R2009b)'
    %sliderListener = addlistener(slider,'Action',@sliderActionEventCb);
    sliderListener = addlistener(slider,'ContinuousValueChange',@sliderActionEventCb);
% else
%     set(slider,'Callback',@sliderActionEventCb);
% end


%set(slider,'max', s(2));
if size(s,2) > 3
    set(slider,'max', s(4));
else
    set(slider,'max', s(3));
end

set(slider,'min', 1);
set(slider,'Value', i);


% uicontrol(fig ...
%     ,'style'    ,'text' ...
%     ,'units'    ,'normalized' ...
%     ,'position' ,[0.04 0.1 0.1 0.04] ...
%     ,'string'   ,'Frame ' ...
% );

framenum = uicontrol(fig ...
    ,'style'    ,'edit' ...
    ,'units'    ,'normalized' ...
    ,'position' ,[0.04 0.05 0.1 0.04] ...
    ,'string'   ,1 ...
);


img = Update();

% set(img,'ButtonDownFcn',@wbmFcn)

set(fig,'WindowButtonDownFcn',@wbmFcn)
set(fig,'KeyPressFcn',@keyPrsFcn)


    function sliderActionEventCb(src,evt)
        newi = round(get(src,'Value'));
        if newi == i 
            return
        end
        %tic
        i = newi;
        set(src,'Value',i);
        Update();
        %toc
    end

    function img = Update()
        figure(fig);

        tmp = Is(:,:,:,i);
        tmp(:,:,1) =  tmp(:,:,1) + ismember(CL(:,:,i),Cells);
%         if size(Pts,1) >= i 
%             pts = fliplr(Pts(i,:));
%             if pts(1) > 0
%                 tmp = DrawLine(Is(:,:,:,i),pts(1:2)-fliplr(M)+wind,pts(3:4)-fliplr(M)+wind ,[0,0,1]);
%             else
%                 tmp(pts(3)-M(2)+wind,pts(4)-M(1)+wind,1) = 1;
%             end
%         end
        img = imshow(tmp,[]);

        set(framenum,'String',i);
    end

    function wbmFcn(src,evt)
        pt = get(gca,'Currentpoint');
        crd = round([pt(1,1), pt(1,2)]);
        L = CL(crd(2),crd(1),i);
        fprintf('Label %i\n', L);
    end
    function keyPrsFcn(src,evt)
        ch = get(gcf,'CurrentCharacter');
        switch ch
            case {' ' , 29 }
                if i < size(Is,2)
                    i = i+1;
                end
                set(slider,'Value', i);
                Update();
            case {'b' , 28}
                if i > 1
                    i = i-1;
                end
                set(slider,'Value', i);
                Update();
        end
    end

    function im = DrawLine(im, pt1,pt2,col)
        % from http://stackoverflow.com/questions/2464637/matlab-drawing-a-line-over-a-black-and-white-image/14308558#14308558
        x1 = pt1(1); y1 = pt1(2);
        x2 = pt2(1); y2 = pt2(2);
        
        xn = abs(x2-x1);
        yn = abs(y2-y1);
        
        if (xn > yn)
            xc = x1 : sign(x2-x1) : x2;
            yc = round( interp1([x1 x2], [y1 y2], xc, 'linear') );
        else
            yc = y1 : sign(y2-y1) : y2;
            xc = round( interp1([y1 y2], [x1 x2], yc, 'linear') );
        end
        
        ind = sub2ind( size(im), yc, xc );
        
        for j=1:3
            tmp = im(:,:,j);  tmp(ind) = col(j); im(:,:,j) = tmp;
        end
    end


end