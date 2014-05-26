function [CellSeeds ,CellLabels,ColIm] = SegmentIm(Im, params,CellSeeds)
% SegmentIm segments a single frame extracting the cell outlines
%
% IN: 
%   Im        -                                                                
%   params      - mincellsize  : size of smallest cell expected
%               - sigma1       : size of gaussian for smoothing image
%               - sigma3       : size of gaussian for smoothing image
%               - IBoundMax    : boundary parameter for merging
%               - debug        : show more info for debugging
%   Ilabel      - if you have a guess for the seeds, it goes here
%
% OUT: 
%   Ilabel - 
%   Clabel - 
%   ColIm - 
%
% Author:
% Copyright:

if nargin < 2    % default parameters
    show = false;
    mincellsize=100;
    sigma1=3.0;
    sigma3 = 5;
    IBoundMax = 30;
else
    show = params.debug;
    mincellsize=params.mincellsize;
    sigma1=params.sigma1;
    sigma3=params.sigma3;
    IBoundMax = params.IBoundMax;
end

ImSize=size(Im);

%% Do we have initial seeding?
if nargin > 2 % ok got seeds to start from!
    disp('using Labels provided');
    GotStartingSeeds = true;
else
    GotStartingSeeds = false;
    CellSeeds = zeros(ImSize,'uint8');
end

%%
Im = double(Im);
Im = Im*(252/max(max(Im(:))));
Im = cast(Im,'uint8');                      %todo: check casting

CellLabels = zeros(ImSize,'uint16');            %todo: check casting

se = strel('disk',2);   


%% Operations
if ~GotStartingSeeds
    DoInitialSeeding();

    if show  figure; imshow(CellSeeds(:,:)); input('press <enter> to continue','s');  end

    MergeSeedsFromLabels()
    if show  figure; imshow(CellSeeds(:,:),[]); input('press <enter> to continue','s');  end
end


GrowCellsInFrame()
if show CreateColorBoundaries(); figure; imshow(ColIm,[]);  end

DelabelFlatBackground()
if show CreateColorBoundaries(); figure; imshow(ColIm,[]);  end

UnlabelPoorSeedsInFrame()
if show CreateColorBoundaries(); figure; imshow(ColIm,[]);  end

NeutralisePtsNotUnderLabelInFrame();


CreateColorBoundaries()
if show  figure; imshow(ColIm,[]);  end



%% helper functions

    function CreateColorBoundaries()
        % create nice pic with colors for cells
        
        cellBoundaries = zeros(ImSize,'uint8');
        ColIm = zeros([ImSize(1) ImSize(2) 3],'double');
        fs=fspecial('laplacian',0.9);
        cellBoundaries(:,:) = filter2(fs,CellLabels(:,:,1)) >.5;
        f1=fspecial( 'gaussian', [ImSize(1) ImSize(2)], sigma3);
        bw=double(CellSeeds(:,:) > 252); % find labels
        I1 = real(fftshift(ifft2(fft2(Im(:,:,1)).*fft2(f1))));
        Il = double(I1).*(1-bw)+255*bw; % mark labels on image
        ColIm(:,:,1) = double(Il)/255.;
        ColIm(:,:,2) = double(Il)/255.;
        ColIm(:,:,3) = double(Il)/255.;
        ColIm(:,:,1) = .7*double(cellBoundaries(:,:)) + ColIm(:,:,1).*(1-double(cellBoundaries(:,:)));
        ColIm(:,:,2) = .2*double(cellBoundaries(:,:)) + ColIm(:,:,2).*(1-double(cellBoundaries(:,:)));
        ColIm(:,:,3) = .2*double(cellBoundaries(:,:)) + ColIm(:,:,3).*(1-double(cellBoundaries(:,:)));
%         ColIm = cast(ColIm*255, 'uint8');                 %todo: typecasting
    end

    function DoInitialSeeding()
        f1=fspecial( 'gaussian', [ImSize(1) ImSize(2)], sigma1);
        
        fprintf('Initial seeding in frame \nmincellsize=%i sigma1=%f\n',mincellsize,sigma1);
        
        % Gaussian smoothing for the segmentation of individual cells
        SmoothedIm = real(fftshift(ifft2(fft2(Im(:,:)).*fft2(f1))));
        if show figure; imshow(SmoothedIm(:,:,1),[]); input('press <enter> to continue','s');  end
        
        SmoothedIm = SmoothedIm/max(max(SmoothedIm))*252.;
        
        %% use external c-code to find initial seeds
        InitialLabelling = findcellsfromregiongrowing( SmoothedIm , params.mincellsize, params.threshold);
        
        if show  figure; imshow(InitialLabelling(:,:),[]); input('press <enter> to continue','s');  end
        
        InitialLabelling(InitialLabelling==1) = 0;  % set unallocated pixels to 0
        
        CellLabels(:,:) = uint16(InitialLabelling);
        
        % deal with background
        DelabelVeryLargeAreas();
        DelabelFlatBackground();
        
        % use true centre of cells as labels
        centroids = round(calculateCellPositions(SmoothedIm,CellLabels(:,:), false));
        centroids = centroids(~isnan(centroids(:,1)),:);
        for n=1:length(centroids);
            SmoothedIm(centroids(n,2),centroids(n,1))=255;
        end
        
        CellSeeds(:,:) = uint8(SmoothedIm);
        
    end

    function GrowCellsInFrame()
        f1=fspecial( 'gaussian', [ImSize(1) ImSize(2)], sigma3);
        bw=double(CellSeeds(:,:) > 252); % find labels
        SmoothedIm = real(fftshift(ifft2(fft2(Im(:,:)).*fft2(f1))));
        ImWithSeeds = double(SmoothedIm).*(1-bw)+255*bw; % mark labels on image
        CellLabels = uint16(growcellsfromseeds3(ImWithSeeds,253));
    end

    function UnlabelPoorSeedsInFrame()
        L = CellLabels;
        Il = CellSeeds;
        f1=fspecial( 'gaussian', [ImSize(1) ImSize(2)], sigma3);
        F = real(fftshift(ifft2(fft2(Im(:,:)).*fft2(f1))));
        Clist = unique(L);
        Clist = Clist(Clist~=0);
        R = [];
        IBounds = [];
        for c = 1:length(Clist)
            mask = L==Clist(c);
            [cpy cpx]=find(mask > 0);
            minx = min(cpx); maxx = max(cpx);
            miny = min(cpy); maxy = max(cpy);
            minx = max(minx-5,1); miny = max(miny-5,1);
            maxx = min(maxx+5,ImSize(2)); maxy = min(maxy+5,ImSize(1));
            m1 = mask(miny:maxy, minx:maxx);
            F1 = F(miny:maxy, minx:maxx);
            Di = imdilate(m1, se);
            Er = imerode(m1, se);
            Fr = Di - Er;
            IFr = F1(Fr>0);
            H = F1(Fr>0);
            IEr = F1(Er>0);
            IBound = mean(IFr);
            
            F2 = Il;
            F2(~mask) = 0;
            [cpy cpx]=find(F2 > 252);
            ICentre = F(cpy , cpx);
            
            if ( IBound < IBoundMax && IBound/ICentre < 1.2 ) ...
                    || IBound < IBoundMax *25./30. ...
                    || min(IFr)==0 ...
                    || sum(H<20)/length(H) > 0.1
                CellLabels = CellLabels.*uint16(mask==0);
            end
        end
        if show  figure, hist(IBounds,100); input('press <enter> to continue','s');  end
    end

    function DelabelVeryLargeAreas()
        % remove cells which are bigger than LargeCellSizeThres
        L = CellLabels;
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
        CellLabels = L;
    end

    function DelabelFlatBackground()            %todo: check this is still useful!
        L = CellLabels;
        D = Im(:,:);
        L(D==0) = 0;
        CellLabels = L;
    end

    function MergeSeedsFromLabels()
        % smoothing
        f1=fspecial( 'gaussian', [ImSize(1) ImSize(2)], sigma3);
        smoothedIm = real(fftshift(ifft2(fft2(Im(:,:)).*fft2(f1))));
        
        labelList = unique(CellLabels);
        labelList = labelList(labelList~=0);
        R = [];
        IBs = []; Bratios = []; Bratios2 = [];Bratios3 = [];
        c = 1;
        while 1==1          % loop over labels
            labelMask = CellLabels==labelList(c);
            label = labelList(c);
            [cpy cpx]=find(labelMask > 0);
            % find region of that label
            minx = min(cpx); maxx = max(cpx);
            miny = min(cpy); maxy = max(cpy);
            minx = max(minx-5,1); miny = max(miny-5,1);
            maxx = min(maxx+5,ImSize(2)); maxy = min(maxy+5,ImSize(1));
            % reduce data to that region
            reducedLabelMask = labelMask(miny:maxy, minx:maxx);
            reducedIm = smoothedIm(miny:maxy, minx:maxx);
            reducedLabels = CellLabels(miny:maxy, minx:maxx);
            % now find boundaries ...
            dilatedMask = imdilate(reducedLabelMask, se);
            erodedMask = imerode(reducedLabelMask, se);
            borderMask = dilatedMask - erodedMask;
            borderIntensities = reducedIm(borderMask>0);
            centralIntensity = reducedIm(erodedMask>0);
            
            F2 = CellSeeds;
            F2(~labelMask) = 0;
            [cpy cpx]=find(F2 > 253);
            ICentre = smoothedIm(cpy , cpx);
            try
            ICentre2 = mean(mean(smoothedIm(max(cpy-1,1):cpy+1 , max(cpx-1,1):cpx+1)));
            catch
                fprintf('-'); 
                c = c+1;  if c > length(labelList); break;  end
                continue
            end
            
            stdB = std(double(centralIntensity));
            try
                sbck = sum(borderIntensities < ICentre+stdB);
            catch
                fprintf('+')
                continue
            end

            sbound = sum(borderIntensities > ICentre+stdB);
            ratio = sbck/sbound;
            R = [R ratio];
            
            % get labels of surrounding cells
            neighLabels = unique(reducedLabels( dilatedMask > 0 ));
            neighLabels = neighLabels(neighLabels~=label);
            
            
            Bs = [];
            R3s = [];
            Bounds = {};
            for i = 1:size(neighLabels)
                ll = neighLabels(i);
                B = dilatedMask;
                B(reducedLabels~=ll)=0;
                B2 = imdilate(B,se);
                B3 = B2;
                B3(reducedLabels~=label) = 0;
                B3 = (B3 + B) > 0;
                B4 = reducedIm;
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
            ll = neighLabels(mC);
            

              
            if Br2 > params.MergeCriteria && label~=0 && ll~=0              % better criteria is proportion of boundary which is 'background' using above criteria
                fprintf('.');
                MergeLabels(label,ll);
                CellSeeds = CellSeeds(:,:);
                labelList = unique(CellLabels);
                labelList = labelList(labelList~=0);
                c = c-1;
            end
            
            

           c = c+1;
           if c > length(labelList)
               break
           end
        end
        fprintf('\n');
    end

    function MergeLabels(l1,l2)
        Cl = CellLabels;
        Il = CellSeeds;
        m1 = Cl==l1;
        m2 = Cl==l2;
        Il1 = Il; Il1(~m1) = 0;
        Il2 = Il; Il2(~m2) = 0;
        [cpy1 cpx1]=find( Il1 > 253);
        [cpy2 cpx2]=find( Il2 > 253); 
        cpx = round((cpx1+cpx2)/2); 
        cpy = round((cpy1+cpy2)/2);
        
        CellSeeds(cpy1,cpx1) = 20;       %background level
        CellSeeds(cpy2,cpx2) = 20; 
        if CellLabels(cpy,cpx)==l1 || CellLabels(cpy,cpx)==l2
            CellSeeds(cpy,cpx) = 255;
        else
            % center is not actually under any of the previous labels ...
           if sum(m1(:)) > sum(m2(:)) 
               CellSeeds(cpy1,cpx1) = 255;
           else
               CellSeeds(cpy2,cpx2) = 255;
           end
        end
        Cl(m2) = l1;
        CellLabels = Cl;
    end

    function NeutralisePtsNotUnderLabelInFrame()
        % the idea here is to set seeds not labelled to 253 ie invisible to retracking (and to growing, caution!)
        L = CellLabels;
        F = CellSeeds;
        F2 = F;
        F2(L~=0) = 0;
        F(F2 > 252) = 253;
        CellSeeds(:,:) = F;
    end
    
end