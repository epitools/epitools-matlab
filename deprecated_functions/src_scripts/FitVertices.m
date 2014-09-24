function [LabelContactmap , Vertices , Cell2Vertices , VerticesConnects , Vertices2Cells ,im1] = FitVertices(Clabel,I1)

Labels = unique(Clabel);
Labels = Labels(Labels~=0);
NLabels = size(Labels,1);
s = size(Clabel); 

% figure(1)
im1 = I1/max(I1(:))*255;
im1 = gray2rgb(im1);
% imshow(im1,[])

% 1st find neighbours
SE = strel('rectangle', [3,3]);
LabelContactmap = containers.Map('KeyType','int32','ValueType','any');
IncompleteCells = [];
for i = 1: NLabels
    l = Labels(i);
    Cl1 = Clabel;
    Cl1(Cl1~=l) = 0;
    Cl1 = imdilate(Cl1,SE);
    ls = unique(Clabel(Cl1>0));
    if sum(ismember(ls,0)) > 0    % ok catching some background here so cell not properly defined on all sides
        IncompleteCells = [IncompleteCells , l];
    end
    
    ls = ls(ls~=l); 
    ls = ls(ls~=0);
%     ls = ls(ls>l);
    LabelContactmap(l) = ls;
end
% save('temp','LabelContactmap');
% load('temp');


% try to get vertex directly from original label
Vertices = [];
NVertices = 0;
Cell2Vertices = containers.Map('KeyType','int32','ValueType','any');
for i1 = 1: NLabels
    l1 = Labels(i1);
    Cell2Vertices(l1) = [];
end
Vertices2Cells = containers.Map('KeyType','int32','ValueType','any');
for i1 = 1: NLabels
    l1 = Labels(i1);
    ls = LabelContactmap(l1);
    Cl1 = Clabel;
    Cl1(Cl1~=l1) = 0;
    Cl1 = imdilate(Cl1>0,SE);
    for i2=1:size(ls,1)
        l2 = ls(i2);
        if l2 < l1 continue; end
        ls2 = LabelContactmap(l2);
        Cl2 = Clabel;
        Cl2(Cl2~=l2) = 0;
        Cl2 = imdilate(Cl2>0,SE);
        for i3 = 1:size(ls2,1)
            l3 = ls2(i3);
            if l3 < l2 continue; end
            if isempty(find(ls==l3)) continue; end
            % l1,l2,l3 now define a vertex!
            Cl3 = Clabel;
            Cl3(Cl3~=l3) = 0;
            Cl3 = imdilate(Cl3>0,SE);
            
            m = Cl1+Cl2+Cl3;
            
            if max(m(:)) < 3 % not a proper vertex
                continue;
            end
            
            Vpatch = unique(Clabel(m==3));
                        
            Vpatch = Vpatch(Vpatch~=0);
            if size(Vpatch,1)==4  % this is a 4-vertex!
                l4 = Vpatch(~ismember(Vpatch,[l1,l2,l3]));
                if l4 < l3 continue; end  % make sure we don't multilple declarations of 4-Vs
                disp('4-vertex');
            end
            
            [cpy , cpx] = find(m==3);
%             im1(cpy-1:cpy+1 , cpx-1:cpx+1) = 255;
%             figure(99), imshow(im1,[]); drawnow
            pt = round([mean(cpy) , mean(cpx)]);
            

            % now check that vertex does not link ONLY to incomplete cells
            if sum(ismember(IncompleteCells,Vpatch)) == size(Vpatch,1) 
                disp('throwing this vertex away: not defining any complete cell')
                continue; 
            end 
               
            
            im1 = DrawPt(im1,pt ,[1,0,0]);
            if size(Vpatch,1)==4  
%                 pt
%                 [l1,l2,l3,l4]
                im1 = DrawPt(im1,pt ,[0,1,0]);
            end
            
            if isnan(pt(1))
                disp('sdf')
            end
            

            
            
            Vertices = [Vertices ; pt];
            NVertices = NVertices + 1;
            
            for c=1:size(Vpatch,1)
                l = Vpatch(c);
                Cell2Vertices(l) = [Cell2Vertices(l) NVertices];
            end
            Vertices2Cells(NVertices) = Vpatch';
            
        end
    end
end

% save('tmp2', 'Cell2Vertices','Vertices2Cells','im1','Vertices','NVertices');
% load('tmp2')
% figure(99), imshow(im1,[]); drawnow



% draw lines
VerticesConnects = containers.Map('KeyType','int32','ValueType','any');
for v1 = 1:NVertices
    VerticesConnects(v1) = [];
end


for i = 1: NLabels
    l1 = Labels(i);
    ls1 = LabelContactmap(l1);
    vs1 = Cell2Vertices(l1);
%     disp(ls1)
    for li=1:size(ls1,1)
        l2 = ls1(li);
%         fprintf('cell %i -- ' ,l2);
        vs2 = Cell2Vertices(l2);
        vs = intersect(vs1,vs2);
        if size(vs,2) ~= 2 
            continue; 
            size(vs,2) 
        end
        pt1 = Vertices(vs(1),:);
        pt2 = Vertices(vs(2),:);
        
        if sum(pt1 == pt2)~=2
            try
%                 im1 = zeros(size(im1));
                im1 = DrawLine(im1,fliplr(pt1),fliplr(pt2),[1,1,0]);
%                 imshow(im1(300:600,300:600,:),[]); drawnow
%                 fprintf('cell %i - %i\n', l1,l2)
%                 input('-','s')
            catch
                disp('fsd')
            end
        end
        
        VerticesConnects(vs(1)) = unique([VerticesConnects(vs(1)) , vs(2)]);
        VerticesConnects(vs(2)) = unique([VerticesConnects(vs(2)) , vs(1)]);
    end
end
% imshow(im1,[]); drawnow

    function im = DrawPt(im, pt,col)
        for i=1:3
            im(pt(1)-1:pt(1)+1 , pt(2)-1:pt(2)+1,i) = col(i);
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
        
        for i=1:3
            tmp = im(:,:,i);  tmp(ind) = col(i); im(:,:,i) = tmp;
        end
    end


end