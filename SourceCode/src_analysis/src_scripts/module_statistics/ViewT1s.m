function fig = ViewT1s(DsList,ShowLine, resX, resT)

if nargin == 1
    ShowLine = true;
end
if nargin < 3
    resX = 1;
    resT = 1;
end


fig = figure;
i = 1;

slider = uicontrol( fig ...
    ,'style'    ,'slider'   ...
    ,'units'    ,'normalized' ...
    ,'position' ,[0.17 0.0 0.80 0.04] ...
    );

% if version == '7.9.0.529 (R2009b)'
    %sliderListener = addlistener(slider,'Action',@sliderActionEventCb);
    sliderListener = addlistener(slider,'ContinuousValueChange',@sliderActionEventCb);
% else
%     set(slider,'Callback',@sliderActionEventCb);
% end


set(slider,'max', length(DsList));

set(slider,'min', 1);
set(slider,'Value', i);

% 
% uicontrol(fig ...
%     ,'style'    ,'text' ...
%     ,'units'    ,'normalized' ...
%     ,'position' ,[0.04 0.1 0.1 0.04] ...
%     ,'string'   ,'Frame ' ...
% );

framenum = uicontrol(fig ...
    ,'style'    ,'edit' ...
    ,'units'    ,'normalized' ...
    ,'position' ,[0.04 0.0 0.1 0.04] ...
    ,'string'   ,1 ...
);


Update();
% 
% set(img,'ButtonDownFcn',@wbmFcn)

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

    function Update()
        figure(fig);
        Dat = DsList{i};
        Ds = Dat{1};     mdl = Dat{2}; 
        Ds(:,1) = Ds(:,1)*resT;
        Ds(:,2) = Ds(:,2)*resX;
        plot(Ds(:,1),Ds(:,2),'-*')
        line([0,max(Ds(:,1))],[0,0])
        if ShowLine
            ypred = predict(mdl,Ds(:,1)/resT);
            hold on
            plot(Ds(:,1),ypred*resX,'r')
            hold off
        end
        set(framenum,'String',i);
    end

    function wbmFcn(src,evt)
        pt = get(gca,'Currentpoint');
        crd = [pt(1,1), pt(1,2)]
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
            case {'m'}
                MakeMovie()
        end
    end

    function MakeMovie()
        clear('M');
        for i = 1:length(DsList)
            CurrentFrame = i;
            Update();
            M(i) = getframe(fig);
            set(slider,'Value', i);
        end
        
        movie2avi(M, 'Movietmp.avi', 'quality', 95,'fps',2);
        system('ffmpeg -i Movietmp.avi -qscale 0  Movie.avi');
        system('rm Movietmp.avi');

    end



end