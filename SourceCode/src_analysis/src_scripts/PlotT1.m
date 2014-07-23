function [Ds, mdl, Pts] = PlotT1(T1,VerticesList,Ims,Cell2VerticesList,Vertices2CellsList,ResT,ResX,LabelContactmaps,DataSource)



phase = 0;
N = length(VerticesList);
totheend = false;
stop = 0;

Ds = []; Ds2 = [];
f = 1;

Pts = [];

% Ims2 = zeros(size(Ims),'uint8');
Ims2 = Ims;

T = T1(1,:);
C1 = T(1);     C2 = T(2);
C3 = T(3);     C4 = T(4);
while f < N
    try
        [pt1 , pt2, u] = FindCommonVertices(C1,C2,f);
        phase =0;
    catch
        disp('prob')
        f =f +1 ;
        Pts = [Pts ; [[] , []] ];
        continue
    end
    if  isempty(pt1)
        try
            [pt1 , pt2, u] = FindCommonVertices(C3,C4,f);
            phase = 1;
        catch
            disp('prob')
            f =f +1 ;
            Pts = [Pts ; [[] , []] ];
            continue
        end
    end
    
%     if f >= stop
%         if ~totheend
%             phase = phase + 1 ;
%             if phase <= size(T1,1)
%                 T = T1(phase,:);
%                 C1 = T(1);     C2 = T(2);
%                 C3 = T(3);     C4 = T(4);
%                 stop = T(5);
%             else
%                 totheend = true;
%                 C1 = T(3);     C2 = T(4);
%             end
%         else
%             C1 = T(3);     C2 = T(4);
%         end
%     end
    
%     try
%         [pt1 , pt2, u] = FindCommonVertices(C1,C2,f);
%     catch
%         fprintf('incomplete trajectory f=%i\n',f)
%         f =f +1 ;
%         continue
%     end
    
    if  isempty(pt1)
        fprintf('-')  %no common vertex!!
        disp('prob2')
        f =f +1 ;
        Pts = [Pts ; [[] , []] ];
        continue
        
        [pt1 , pt2, u, c13] =  FindCommonVertices(C1,C3,f);
        [pt1 , pt2, u, c14] =  FindCommonVertices(C1,C4,f);
        [pt1 , pt2, u, c23] =  FindCommonVertices(C2,C3,f);
        [pt1 , pt2, u, c24] =  FindCommonVertices(C2,C4,f);
        vs = unique([c13,c14,c23,c24]);
        VCoords = VerticesList{f}( vs, : );
        try
            lastpt = Pts(end,:);
        catch
            disp('prob') 
            f =f +1 ;
            Pts = [Pts ; [[] , []] ];
            continue
        end
        M = [mean([lastpt(1),lastpt(3)]) , mean([lastpt(2) , lastpt(4)])];
        VCoords(:,1) = VCoords(:,1)- M(1);
        VCoords(:,2) = VCoords(:,2)- M(2);
        Dss = sqrt(sum(VCoords.^2,2));
        [B,IX] = sort(Dss);
        vs = vs(IX(1:2));  % good vertices!
        a = Vertices2CellsList{f}(vs(1));
        b = Vertices2CellsList{f}(vs(2));
        l = [a,b];
        touching = intersect(a,b);
        nottouching = l(~ismember(l,touching));
        if length(touching) == 2 
            C1 = touching(1); C2 = touching(2);
        else
            disp('4-vertex')
            C1 = touching(1);
        end
        try
        C3 = nottouching(1); C4 = nottouching(2);
        catch
            disp('fsd')
        end
        
        % now restart frame with these cells!
        continue
    end
    
    
    
    d = norm(pt1-pt2);
    if(pt2(1) == -1) % 4-vertex
        d = 0;
    end
    if mod(phase,2)==0 
        Ds = [Ds ; [f,d]];
    else 
        Ds= [Ds ; [f,-d]];
    end
    
    
%     im = Ims(:,:,:,f);
%     tmp = DrawLine(Ims(:,:,:,f),fliplr(pt1),fliplr(pt2) ,[0,0,1]);
% %     Ims2(:,:,:,f) = uint8(tmp/max(tmp(:))*255);
%     Ims2(:,:,:,f) = tmp;
    
    
    Pts = [Pts ; [pt1 , pt2]];
    
    f = f +1;
end

Ds(:,1) =Ds(:,1) * ResT; 
Ds(:,2) =Ds(:,2) * ResX;            % conversion to microns / minute


% plot(Ds(:,1),Ds(:,2),'-*')
% line([0,max(Ds(:,1))],[0,0])
% 
try
    mdl = LinearModel.fit(Ds(:,1),Ds(:,2),'linear','RobustOpts','on');
catch
    plot(Ds(:,1),Ds(:,2),'*b')
    mdl = [];
end
% mdl.RMSE;
% ypred = predict(mdl,Ds(:,1));
% hold on
% plot(Ds(:,1),ypred,'r')
% hold off


% hold on
% plot(Ds2(:,1),Ds2(:,2),'*b')
% hold off

if strcmp(DataSource , 'Simulation')
    t = Ds(:,2)>0;
    t = t*2 -1;
    tt = t(1:end-1).*-t(2:end);
    f = find(tt==1);
    try
        mdl = LinearModel.fit(Ds(f:f+1,1),Ds(f:f+1,2),'linear');
    catch
        figure, plot(Ds(:,1),Ds(:,2),'*b')
        mdl = [];
    end
end
    

function [pt1 , pt2, u, Vs] = FindCommonVertices(C1,C2,f)
        Va = Cell2VerticesList{f}(C1);
        Vb = Cell2VerticesList{f}(C2);
        Vs = intersect(Va,Vb);
        if size(Vs,2) ~= 0
            pt1 = VerticesList{f}( Vs(1), : );
            a = Vertices2CellsList{f}(Vs(1));
            if size(Vs,2) == 2
                pt2 = VerticesList{f}( Vs(2), : );
                b = Vertices2CellsList{f}(Vs(2));
            else
                pt2 = [-1, -1]; b = [];
                fprintf('4-vertex\n',f)
            end
        else
            pt1 = []; a = [];
            pt2 = []; b = [];
        end
        
        u = [a b];
        u = u(~ismember(u,[C1,C2]));
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

