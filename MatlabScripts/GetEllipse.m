function BW = GetEllipse(ImProj)

fig = figure;
imshow(ImProj,[]);
ell = imellipse();
set(fig,'KeyPressFcn',@keyPrsFcn)
uiwait(fig);

    function keyPrsFcn(src,evt)
        ch = get(gcf,'CurrentCharacter');
        if ch == 13 % == ENTER
            BW = createMask(ell);
            close(fig)
        end
    end


end