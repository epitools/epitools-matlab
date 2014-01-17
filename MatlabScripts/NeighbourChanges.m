function [NeighbrsIm,Hist,HistT1s] =   NeighbourChanges(Itracks,LabelContactmaps,ColLabels,CLabels,Cell2VerticesList,Vertices2CellsList,VerticesList)


disp('Looking at neighbour changes')

NLabels = max(Itracks(:));

s = size(Itracks);

NeighbrsIm = zeros(s(1),s(2),3,s(3));
NeighbrsIm(:,:,:,1) = ColLabels(:,:,:,1);

Hist = {};
HistT1s = {};

for f=2:size(Itracks,3)
    disp(f)
    Cf = CLabels(:,:,f);
    Cfm = CLabels(:,:,f-1);
    Hist{f} = containers.Map('KeyType','int32','ValueType','any');
    ls = unique(Itracks(:,:,f));
    ls = ls(ls~=0);
    for i = 1:size(ls)
        l = ls(i);
        mCs0 = LabelContactmaps{f-1};
        if isKey(mCs0,l)
            Cs0 = sort(LabelContactmaps{f-1}(l));
        else
            Cs0 = [];
            disp('no previous cell, new cell!')
        end
        
        mCs1 = LabelContactmaps{f};
        if isKey(mCs1,l)
            Cs1 = sort(LabelContactmaps{f}(l));
        else
            disp('weird mismatch between Itracks and contact maps! TBS')
            Cs1 = [];
            continue
        end
        
        if size(Cs0,1) == size(Cs1,1) && sum(Cs0 ~= Cs1)
            disp('rare event: list of neighbours is different but same nber of them!')
            %input('press <enter> to continue','s')
        end
        
        if size(Cs0,1) ~= size(Cs1,1) || sum(Cs0 ~= Cs1)
            % got one
            if size(Cs0,1) > size(Cs1,1) % lost a neighbour
                lost = setdiff(Cs0,Cs1);
                for c=1:size(lost,1)
                    [pt1 , pt2 , u] = FindCommonVertices(lost(c),l,f-1);
                    if isempty(pt2) || sum(pt2 ~= [-1, -1]) == 0 continue; end
                    try
                        fprintf('- %i<->%i (%i %i)\n',lost(c),l,u(1),u(2));
                    catch
                        disp('fsd')
                    end
                    Hist{f}(-Hkey(lost(c),l)) = [min(lost(c),l) , max(lost(c),l) , min(u(1),u(2)),max(u(1),u(2)) ];
                    try
                        DrawPerpLine(pt1,pt2,[1,1,0]);
                    catch
                        disp('coudn''t draw line')
                    end
                end
            end
            
            if size(Cs0,1) < size(Cs1,1) % gained a neighbour
                gained = setdiff(Cs1,Cs0);
                for g=1:size(gained,1)
                    [pt1 , pt2 , u] = FindCommonVertices(gained(g),l,f);
                    if isempty(pt2) continue; end
                    if pt1 == pt2 disp('same Vertices coming out here!!!'); continue; end
                    try
                        fprintf('+ %i<->%i (%i %i)\n',gained(g),l,u(1),u(2));
                    catch
                        disp('fsd')
                    end
                    try
                        Hist{f}(Hkey(gained(g),l)) = [min(gained(g),l) , max(gained(g),l) , min(u(1),u(2)),max(u(1),u(2)) ];
                    catch
                        disp('not taking it into account')
                    end
                    DrawPerpLine(pt1,pt2,[0,1,0]);
                end
%                 imshow(ColLabels(:,:,:,f),[]); drawnow
            end
            
        end
    end
    NeighbrsIm(:,:,:,f) = ColLabels(:,:,:,f);
    
    HistT1s{f} = containers.Map('KeyType','int32','ValueType','any');
    ks = cell2mat(Hist{f}.keys);
    for k=1:length(ks)
        key = ks(k); 
        if key > 0 break; end
        vs = Hist{f}(key);
        k2 = Hkey(vs(3),vs(4));
        if ismember(k2, ks) % ok got a t1 transition!
            fprintf('got T1 transition - %i<->%i / + %i<->%i\n', vs(1),vs(2),vs(3),vs(4));
            HistT1s{f}(Hkey(vs(1),vs(2))) = [vs(1),vs(2),vs(3),vs(4)];
        end
    end
    
end


    function k = Hkey(x,y)
        k = 10000*min(x,y)+max(x,y);
    end
        

    function [pt1 , pt2, u] = FindCommonVertices(C1,C2,f)
        Va = Cell2VerticesList{f}(C1);
        Vb = Cell2VerticesList{f}(C2);
        Vs = intersect(Va,Vb);
        if numel(Vs) == 0
            pt1 = []; 
            pt2 = []; 
            u = [];
            return
        end
        if size(Vs,2) ~= 0
            pt1 = VerticesList{f}( Vs(1), : );
            a = Vertices2CellsList{f}(Vs(1));
            if size(Vs,2) == 2
                pt2 = VerticesList{f}( Vs(2), : );
                b = Vertices2CellsList{f}(Vs(2));
            else
                pt2 = [-1, -1]; b = [];
            end
        else
            pt1 = []; a=[];
            pt2 = []; b = [];
        end
        u = [a b];
        u = u(~ismember(u,[C1,C2]));
        if size(u,2) == 1       % not a T1 transition
            u(2) = -1;
        end
    end

    function DrawPerpLine(pt1,pt2,col)
        C = mean([pt1 ; pt2]);
        V = pt2-pt1;
        Vp = [V(2) , -V(1)];
        pta = round(C-Vp/2./norm(Vp)*10);
        ptb = round(C+Vp/2./norm(Vp)*10);
        ColLabels(:,:,:,f) = DrawLine( ColLabels(:,:,:,f), fliplr(pta),fliplr(ptb), col );
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
        
        for i=1:3
            tmp = im(:,:,i);  tmp(ind) = col(i); im(:,:,i) = tmp;
        end
    end
end

    