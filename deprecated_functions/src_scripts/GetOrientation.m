function Orient = GetOrientation(ImProj)
s=size(ImProj);
disp('Click on center of disk')
fig = figure;
img = imshow(ImProj,[]);
set(img,'ButtonDownFcn',@wbmFcn)

set(fig,'KeyPressFcn',@keyPrsFcn)
getPoint = 'c';

uiwait(fig);

    function keyPrsFcn(src,evt)
        ch = get(gcf,'CurrentCharacter');
        if ch == 13 % == ENTER
            if getPoint == 'b'
                disp('Got Boundary points');
                close(fig)
            end
        end
    end


    function wbmFcn(src,evt)
        pt = get(gca,'Currentpoint');
        pt = round([pt(1,1), pt(1,2)]);
        if pt(1,1) > s(2) || pt(1,2) > s(1)
            return
        end
        switch getPoint
            case 'c'
                Orient.Center = [pt(1) pt(2)];
                disp('centre is set');
                getPoint = 'bb';
            case 'bb'
                Orient.BoundaryPt = [pt(1) pt(2)];
                disp('Boundary pt is set');
                getPoint = 'd';
            case 'd'
                Orient.DirectionPt = [pt(1) pt(2)];
                disp('Direction pt is set, please now click Boundary points and then press <ENTER>');
                getPoint = 'b';
                Orient.BoundaryPts = [];
            case 'b'
                Pt = [pt(1) pt(2)];
                Orient.BoundaryPts = [Orient.BoundaryPts ; Pt];                
        end
    end

end