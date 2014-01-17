function fig = StackView(Is, i)

if nargin < 2
    i = 1;
end


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

if strcmp(class(Is) , 'cell')
    disp('! Need to convert cell Stack to array - converting stack')
    s = size(Is{1});
    s(3) = length(Is);
    Im = zeros(s);
    for t = 1: length(Is)
        Im(:,:,t) = Is{t};
    end
    Is = Im;
    clear Im;
end

s = size(Is);
%set(slider,'max', s(2));
if size(s,2) > 3
    set(slider,'max', s(4));
    maxS = s(4);
else
    set(slider,'max', s(3));
    maxS = s(3);
end

set(slider,'min', 1);
set(slider,'Value', i);


uicontrol(fig ...
    ,'style'    ,'text' ...
    ,'units'    ,'normalized' ...
    ,'position' ,[0.04 0.1 0.1 0.04] ...
    ,'string'   ,'Frame ' ...
);

framenum = uicontrol(fig ...
    ,'style'    ,'edit' ...
    ,'units'    ,'normalized' ...
    ,'position' ,[0.04 0.05 0.1 0.04] ...
    ,'string'   ,1 ...
);


Update();

set(img,'ButtonDownFcn',@wbmFcn)

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
%         imshow(imadjust(Is{i}));
        %img = imshow(Is{i},[]);
        switch size(s,2)
            case 3
                im = Is(:,:,i);
                q = quantile(im(:),[.001 .999]);
                im(im<q(1))=q(1);
%                 im = im - q(1);
                im(im>q(2)) = q(2);
                img = imshow(im,[]);
            case 4
                if s(3) == 3
                    img = imshow(squeeze(Is(:,:,:,i)),[]);
                end
                if s(4) == 3
                    img = imshow(squeeze(Is(:,:,i,:)));
                end
                %             if max(max(max(max(Is(:,:,:,i))))) == 0
        end
%         set(img,'ButtonDownFcn',@wbmFcn)
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
        for i = 1:maxS
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