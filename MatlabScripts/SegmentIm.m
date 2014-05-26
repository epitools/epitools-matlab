function [Ilabel ,Clabel,ColIm] = SegmentIm(data,debug, params,Ilabel)
% SegmentIm segments a single frame extracting the cell outlines
%
% IN: 
%   data -                                                                 % change name!
%   debug - 
%   params - 
%   Ilabel -
%
% OUT: 
%   Ilabel - 
%   Clabel - 
%   ColIm - 
%
% Author:
% Copyright:

if nargin < 2
    debug = false;
    %initial seeding
    mincellsize=100;
    sigma1=3.0;
    %mergeseeds:
    maxDistance=200;
    maxGradient=10;
    iterations=7;
    sigma2=6;
    % grow cells
    sigma3 = 5;
    IBoundMax = 30;
else
    mincellsize=params.mincellsize;
    sigma1=params.sigma1;
    %mergeseeds:
%     maxDistance=params.maxDistance;
%     maxGradient=params.maxGradient;
%     iterations=params.iterations;
%     sigma2=params.sigma2;
    % grow cells
    sigma3=params.sigma3;
    IBoundMax = params.IBoundMax;
end

s=size(data);
s(3) = 1;

if nargin > 3 % ok got seeds to start from!
    disp('using Labels provided');
    GotStartingSeeds = true;
else
    GotStartingSeeds = false;
    Ilabel = zeros(s,'uint8');
end

data = double(data);
data = data*(252/max(max(data(:))));

Clabel = zeros(s,'uint16');

se = strel('disk',2);   


%Operations
if ~GotStartingSeeds
    DoInitialSeeding();
    
    if debug  figure; imshow(Ilabel(:,:,1)); input('press <enter> to continue','s');  end

    MergeSeedsFromLabels(1)
    if debug  figure; imshow(Ilabel(:,:,1),[]); input('press <enter> to continue','s');  end
end


GrowCellsInFrame(1)
if debug CreateColorBoundaries(); figure; imshow(ColIm,[]);  end

DelabelFlatBackground(1)
if debug CreateColorBoundaries(); figure; imshow(ColIm,[]);  end

UnlabelPoorSeedsInFrame(1)
if debug CreateColorBoundaries(); figure; imshow(ColIm,[]);  end

NeutralisePtsNotUnderLabelInFrame(1);


CreateColorBoundaries()
if debug  figure; imshow(ColIm,[]);  end

    function CreateColorBoundaries()
        cellBoundaries = zeros(s,'uint8');
        ColIm = zeros([s(1) s(2) 3],'double');
        f = 1;
        fs=fspecial('laplacian',0.9);
        cellBoundaries(:,:,f) = filter2(fs,Clabel(:,:,1)) >.5;
        f1=fspecial( 'gaussian', [s(1) s(2)], sigma3);
        bw=double(Ilabel(:,:,f) > 252); % find labels
        I1 = real(fftshift(ifft2(fft2(data(:,:,1)).*fft2(f1))));
        Il = double(I1).*(1-bw)+255*bw; % mark labels on image
        ColIm(:,:,1) = double(Il)/255.;
        ColIm(:,:,2) = double(Il)/255.;
        ColIm(:,:,3) = double(Il)/255.;
        ColIm(:,:,1) = .7*double(cellBoundaries(:,:,f)) + ColIm(:,:,1).*(1-double(cellBoundaries(:,:,f)));
        ColIm(:,:,2) = .2*double(cellBoundaries(:,:,f)) + ColIm(:,:,2).*(1-double(cellBoundaries(:,:,f)));
        ColIm(:,:,3) = .2*double(cellBoundaries(:,:,f)) + ColIm(:,:,3).*(1-double(cellBoundaries(:,:,f)));
    end

    function DoInitialSeeding()
        f1=fspecial( 'gaussian', [s(1) s(2)], sigma1);
        f2=fspecial( 'gaussian', [s(1) s(2)], 10);
        
        fprintf('Initial seeding in frame \nmincellsize=%i sigma1=%f\n',mincellsize,sigma1);
        
        for f=1:s(3),
            fprintf('%i ',f);
            % Gaussian smoothing for the segmentation of individual cells
            I2 = real(fftshift(ifft2(fft2(data(:,:,f)).*fft2(f1))));
            if debug figure; imshow(I2(:,:,1),[]); input('press <enter> to continue','s');  end
            I2 = I2/max(max(I2))*252.;
            
            %Ilab=celllabel2dark(I2, 1, mincellsize);
            Ilab = findcellsfromregiongrowing( I2 , params.mincellsize, params.threshold);

            if debug  figure; imshow(Ilab(:,:,1),[]); input('press <enter> to continue','s');  end
            
            Ilab(Ilab==1) = 0;  % set unallocated pixels to 0
            
            Clabel(:,:,f) = Ilab;
            
            DelabelVeryLargeAreas(f);
            DelabelFlatBackground(f);
            
            centroids = round(calculateCellPositions(I2,Clabel(:,:,f), false));
            centroids = centroids(~isnan(centroids(:,1)),:);
            for n=1:length(centroids);
                I2(centroids(n,2),centroids(n,1))=255;
            end
            
            Ilabel(:,:,f) = uint8(I2);
        end
    end

%     function MergeSeeds()
%         tic
%         fprintf('Merging points in frame \n');
%         for f=1:s(3)
%             MergeSeedsInFrm(f)
%         end
%         toc
%     end
% 
%     function MergeSeedsInFrm(f)
%         Ilabel2 = double(Ilabel(:,:,f));
%         f1=fspecial( 'gaussian', [s(1) s(2)], sigma2);
%         
%         % Gaussian smoothing for the segmentation of individual cells
%         I2 = real(fftshift(ifft2(fft2(data(:,:,f)).*fft2(f1))));
%         
%         for n=1:iterations,
%             Ilabel2=mergePositions1(I2,Ilabel2, maxDistance, maxGradient);
%         end
%         if debug  figure; imshow(Ilabel2,[]); input('press <enter> to continue','s');  end
%         Ilabel(:,:,f)=Ilabel2;
%     end
    
    function GrowCells()
        % first regrow and clean labels
        tic
        fprintf('Growing cells!\n');
        for  f = 1 : s(3)
            fprintf('%i ',f);
            GrowCellsInFrame(f);
        end
        toc
    end

    function GrowCellsInFrame(f)
        f1=fspecial( 'gaussian', [s(1) s(2)], sigma3);
        bw=double(Ilabel(:,:,f) > 252); % find labels
        I1 = real(fftshift(ifft2(fft2(data(:,:,f)).*fft2(f1))));
        Il = double(I1).*(1-bw)+255*bw; % mark labels on image
        Ilabel2=growcellsfromseeds3(Il,253);
        Clabel(:,:,f) = Ilabel2;
    end

    function UnlabelPoorSeeds()
        tic
        fprintf('Removing poor seeds!');
        for f = 1: s(3)
            fprintf('%i ',f);
            UnlabelPoorSeedsInFrame(f);
            NeutralisePtsNotUnderLabelInFrame(f);
        end
        toc
    end

    function UnlabelPoorSeedsInFrame(f)
        L = Clabel(:,:,f);
        Il = Ilabel(:,:,f);
        f1=fspecial( 'gaussian', [s(1) s(2)], sigma3);
        F = real(fftshift(ifft2(fft2(data(:,:,f)).*fft2(f1))));
        Clist = unique(L);
        Clist = Clist(Clist~=0);
        R = [];
        IBounds = [];
        for c = 1:length(Clist)
            m = L==Clist(c);
            l = Clist(c);
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
            H = F1(Fr>0);
            IEr = F1(Er>0);
            IBound = mean(IFr);
            IBounds = [IBounds IBound];
            ICentre = mean(IEr);
            
            F2 = Il;
            F2(~m) = 0;
            [cpy cpx]=find(F2 > 252);
            ICentre = F(cpy , cpx);
            
            stdB = std(double(IEr));
%             sbck = sum(IFr < ICentre+stdB);
%             sbound = sum(IFr > ICentre+stdB);
%             ratio = sbck/sbound;
%             R = [R ratio];
%             if isnan(ratio)
%                     disp('sdf')
%             end
                
%             if ratio > 1 || ratio < 0.2
            try
            if ( IBound < IBoundMax && IBound/ICentre < 1.2 ) ...
                    || IBound < IBoundMax *25./30. ...
                    || min(IFr)==0 ...
                    || sum(H<20)/length(H) > 0.1
%                 F2 = Il;
%                 F2(~m) = 0;
%                 [cpy cpx]=find(F2 > 252);
%                 Ilabel(cpy,cpx,f) = 253;
%                 Ilabel(cpy,cpx,f) = 0;
                Clabel(:,:,f) = Clabel(:,:,f).*uint16(m==0);
            end
            catch
                disp('sdf')
            end
        end
        if debug  figure, hist(IBounds,100); input('press <enter> to continue','s');  end
        if debug  figure, hist(IBounds,100); end
    end

    function DelabelVeryLargeAreas(f)
        L = Clabel(:,:,f);
        A  = regionprops(L, 'area');
        As = cat(1, A.Area);
        ls = unique(L);
        for i = 1:size(ls);
            l = ls(i);
            if l == 0 
                continue;
            end
            A = As(l);
            if A > params.LargeCellSizeThres
                L(L==l) = 0;
            end
        end
        Clabel(:,:,f) = L;
    end

    function DelabelFlatBackground(f)
        L = Clabel(:,:,f);
        D = data(:,:,f);
        L(D==0) = 0;
        Clabel(:,:,f) = L;
    end

    function MergeSeedsFromLabels(f)
        L = Clabel(:,:,f);
        I = Ilabel(:,:,f);
        f1=fspecial( 'gaussian', [s(1) s(2)], sigma3);
        F = real(fftshift(ifft2(fft2(data(:,:,f)).*fft2(f1))));
        Clist = unique(L);
        Clist = Clist(Clist~=0);
        R = [];
        IBs = []; Bratios = []; Bratios2 = [];Bratios3 = [];
        c = 1;
        while 1==1
            m = L==Clist(c);
            l = Clist(c);
            [cpy cpx]=find(m > 0);
            minx = min(cpx); maxx = max(cpx);
            miny = min(cpy); maxy = max(cpy);
            minx = max(minx-5,1); miny = max(miny-5,1);
            maxx = min(maxx+5,s(2)); maxy = min(maxy+5,s(1));
            m1 = m(miny:maxy, minx:maxx);
            F1 = F(miny:maxy, minx:maxx);
            L1 = L(miny:maxy, minx:maxx);
            Di = imdilate(m1, se);
            Er = imerode(m1, se);
            Fr = Di - Er;
            IFr = F1(Fr>0);
            H = F1(Fr>0);
            IEr = F1(Er>0);
            IBound = mean(IFr);
            ICentre = mean(IEr);
            
            F2 = I;
            F2(~m) = 0;
            [cpy cpx]=find(F2 > 253);
            ICentre = F(cpy , cpx);
            try
            ICentre2 = mean(mean(F(max(cpy-1):cpy+1 , max(cpx-1,1):cpx+1)));
            catch
                fprintf('-'); 
                c = c+1;  if c > length(Clist); break;  end
                continue
            end
            
            stdB = std(double(IEr));
            try
                sbck = sum(IFr < ICentre+stdB);
            catch
                fprintf('+')
                continue
            end

            sbound = sum(IFr > ICentre+stdB);
            ratio = sbck/sbound;
            R = [R ratio];
            

            
            % get labels of surrounding cells
            ls = unique(L1(Di>0));
            ls = ls(ls~=l);
            
            
            Bs = [];
            lls = [];
            R3s = [];
            Bounds = {};
            for i = 1:size(ls)
                ll = ls(i);
                B = Di;
                B(L1~=ll)=0;
                B2 = imdilate(B,se);
                B3 = B2;
                B3(L1~=l) = 0;
                B3 = (B3 + B) > 0;
                B4 = F1;
                B4(~B3) = 0;
                IB = mean(B4(:));
                Bratio2 = IB/ICentre2;
                
                R3 = sum(B4(B3) < ICentre+stdB/2.)/size(B4(B3),1);
                
                IBs = [IBs IB];
                Bratios2 = [Bratios2 Bratio2];
                Bratios3 = [Bratios3 R3];
                Bs = [Bs IB/ICentre2];
                R3s = [R3s R3];
                Bounds{i} = B3;
            end
            [Br1,mC] = min(Bs);
            
            R2 = Br1/mean(Bs(Bs~=mC));
            Bratios = [Bratios R2];
            
            [Br2,mC] = max(R3s);
            ll = ls(mC);
            
            if l == 257 || l == 486 || l == 487
                disp('sdf')
            end
              
            if Br2 > params.MergeCriteria && l~=0 && ll~=0              % better criteria is proportion of boundary which is 'background' using above criteria
                fprintf('.');
                tmp = F1;
                tmp(~Bounds{mC}) = 0;
                MergeLabels(l,ll,f);
                L = Clabel(:,:,f);
                I = Ilabel(:,:,f);
                Clist = unique(L);
                Clist = Clist(Clist~=0);
                c = c-1;
            end
            
            

           c = c+1;
           if c > length(Clist)
               break
           end
        end
        fprintf('\n');
    end

    function MergeLabels(l1,l2,f)
        Cl = Clabel(:,:,f);
        Il = Ilabel(:,:,f);
        m1 = Cl==l1;
        m2 = Cl==l2;
        Il1 = Il; Il1(~m1) = 0;
        Il2 = Il; Il2(~m2) = 0;
        [cpy1 cpx1]=find( Il1 > 253);
        [cpy2 cpx2]=find( Il2 > 253); 
        cpx = round((cpx1+cpx2)/2); 
        cpy = round((cpy1+cpy2)/2);
        
        Ilabel(cpy1,cpx1,f) = 20;       %background level
        Ilabel(cpy2,cpx2,f) = 20; 
        if Clabel(cpy,cpx,f)==l1 || Clabel(cpy,cpx,f)==l2
            Ilabel(cpy,cpx,f) = 255;
        else
            % center is not actually under any of the previous labels ...
           if sum(m1(:)) > sum(m2(:)) 
               Ilabel(cpy1,cpx1,f) = 255;
           else
               Ilabel(cpy2,cpx2,f) = 255;
           end
        end
        Cl(m2) = l1;
        Clabel(:,:,f) = Cl;
    end

    function NeutralisePtsNotUnderLabelInFrame(f)
        % the idea here is to set seeds not labelled to 253 ie invisible to retracking (and to growing, caution!)
        L = Clabel(:,:,f);
        F = Ilabel(:,:,f);
        F2 = F;
        F2(L~=0) = 0;
        F(F2 > 252) = 253;
        Ilabel(:,:,f) = F;
    end
    
end