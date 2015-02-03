function [CellSeeds ,CellLabels,ColIm] = SegmentIm(Im, params,CellSeeds)
% SegmentIm segments a single frame extracting the cell outlines
%
% IN: 
%   Im          - Image with high intensity membrane signal and low intensity cell background                                                               
%   params      - mincellsize  : size of smallest cell expected
%               - sigma1       : size of gaussian for smoothing image
%               - sigma3       : size of gaussian for smoothing image
%               - IBoundMax    : boundary parameter for merging
%               - debug        : show more info for debugging
%   Ilabel      - if you have a guess for the seeds, it goes here
%
% OUT: 
%   Ilabel -> CellSeeds (uint8 - Rescaled Image to fit the range [0,252]
%                        253/254/255 are used for seed information)
%   Clabel -> CellLables (uint16 - bitmap of cells colored with 16bit id)
%   ColIm  -> Colored image to store tracking information 
%
% Author: Alexandre Tournier, Andreas Hoppe.
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
    % -------------------------------------------------------------------------
    % Log current application status
    log2dev('Initial seeding file found! ', 'DEBUG');
    % -------------------------------------------------------------------------
    GotStartingSeeds = true;
else
    
    % -------------------------------------------------------------------------
    % Log current application status
    log2dev('Initial seeding file not found! *** Creating a new seeding file ', 'DEBUG');
    % -------------------------------------------------------------------------
    
    GotStartingSeeds = false; 
    
    % Preallocating space for cell seeds 
    CellSeeds = zeros(ImSize,'uint8');

end

%%
Im = double(Im);
Im = Im*(252/max(max(Im(:))));
Im = cast(Im,'uint8');                                                      %todo: check casting

CellLabels = zeros(ImSize,'uint16');                                        %todo: check casting: why using 16 bit for labels?

%structuring element, SE, used for morphological operations
se = strel('disk',2);   


%% Operations

% [0] Create starting seeds if not provide
if ~GotStartingSeeds
    
    % Find the initial cell seeds (parameters: sigma1, threshold)
    DoInitialSeeding();
    if show  figure('Name','First seeding'); imshow(CellSeeds(:,:),[]);  end

    % Remove initial cell regions which touch & whose boundary is insufficient
    % (parameters: params.MergeCriteria)
    MergeSeedsFromLabels() 
    if show  figure('Name','Seeding after merging'); imshow(CellSeeds(:,:),[]); end
end


% [1] Growing cells from seeds (parameter: sigma3) TODO: add paramters in Name description!
GrowCellsInFrame()
if show CreateColorBoundaries(); figure('Name','First cell boundaries'); imshow(ColIm,[]);  end

% [2] Eliminate labels from seeds which have poor boundary intensity
UnlabelPoorSeedsInFrame()
if show CreateColorBoundaries(); figure('Name','Boundaries after poor cell removal'); imshow(ColIm,[]);  end

% [3] Seeds whose label has been eliminated are converted to NeutralSeeds (value=253)
NeutralisePtsNotUnderLabelInFrame();

% [4] Generate final colored image (RGB) to represent the segmentation results
CreateColorBoundaries()
%if show  figure('Name','Final cell boundaries'); imshow(ColIm,[]);  end



%% helper functions

    function CreateColorBoundaries()
        % create nice pic with colors for cells
        
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev(sprintf('Generating color boundaries in current frame'), 'INFO');
        % -------------------------------------------------------------------------

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
        %ColIm = cast(ColIm*255, 'uint8');                 %todo: typecasting
    end

    function DoInitialSeeding()
        
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev('Generating initial seeding in current frame', 'INFO');
        log2dev(sprintf('Minimal cell size = %i | Sigma 1 = %f',mincellsize,sigma1), 'DEBUG');
        % -------------------------------------------------------------------------
 
        % Create gaussian filter
        f1=fspecial( 'gaussian', [ImSize(1) ImSize(2)], sigma1);
         
        % Gaussian smoothing for the segmentation of individual cells
        SmoothedIm = real(fftshift(ifft2(fft2(Im(:,:)).*fft2(f1))));
        %if show figure; imshow(SmoothedIm(:,:,1),[]); input('press <enter> to continue','s');  end
        
        SmoothedIm = SmoothedIm/max(max(SmoothedIm))*252.;
        
        % Use external c-code to find initial seeds
        InitialLabelling = findcellsfromregiongrowing(SmoothedIm , params.mincellsize, params.threshold);
        %if show  figure; imshow(InitialLabelling(:,:),[]); input('press <enter> to continue','s');  end
        
        InitialLabelling(InitialLabelling==1) = 0;  % set unallocated pixels to 0
        
        % Generate CellLabels from InitalLabelling
        CellLabels(:,:) = uint16(InitialLabelling);
        
        % eliminate very large areas
        DelabelVeryLargeAreas();
        % DelabelFlatBackground()
        
        % Use true centre of cells as labels
        centroids = round(calculateCellPositions(SmoothedIm,CellLabels(:,:), false));
        centroids = centroids(~isnan(centroids(:,1)),:);
        for n=1:length(centroids);
            SmoothedIm(centroids(n,2),centroids(n,1))=255;
        end
        
        % CellSeeds contains the position of the true cell center. 
        CellSeeds(:,:) = uint8(SmoothedIm);
        
    end


%     % Initial specification was encoding background pixels as zero values in cell images.
%     % DelabelFlatBackground() removes such background pixels from the cell label image,
%     % i.e. it is applying a mask.     
%     function DelabelFlatBackground()                                       
%         L = CellLabels;
%         D = Im(:,:);
%         L(D==0) = 0;
%         CellLabels = L;
%     end

    function GrowCellsInFrame()
        
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev(sprintf('Growing in-frame-cells in current frame'), 'INFO');
        % -------------------------------------------------------------------------

        f1=fspecial( 'gaussian', [ImSize(1) ImSize(2)], sigma3);
        bw=double(CellSeeds(:,:) > 252); % find labels
        SmoothedIm = real(fftshift(ifft2(fft2(Im(:,:)).*fft2(f1))));
        ImWithSeeds = double(SmoothedIm).*(1-bw)+255*bw; % mark labels on image
        CellLabels = uint16(growcellsfromseeds3(ImWithSeeds,253));
    
    end

    function UnlabelPoorSeedsInFrame()
        
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev(sprintf('Eliminating cell labels with insufficient boundary intensity'), 'INFO');
        % -------------------------------------------------------------------------
        
        L = CellLabels;
        f1=fspecial( 'gaussian', [ImSize(1) ImSize(2)], sigma3);
        smoothedIm = real(fftshift(ifft2(fft2(Im(:,:)).*fft2(f1))));
        labelList = unique(L); %i.e. every cell is marked by one unique integer label 
        labelList = labelList(labelList~=0);
        IBounds = zeros(length(labelList),1);
        
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev(sprintf('Found %i cells to anlayze', length(labelList)), 'DEBUG');
        % -------------------------------------------------------------------------
        
        for c = 1:length(labelList)
            mask = L==labelList(c);
            [cpy cpx]=find(mask > 0);
            % find region of that label
            minx = min(cpx); maxx = max(cpx);
            miny = min(cpy); maxy = max(cpy);
            minx = max(minx-5,1); miny = max(miny-5,1);
            maxx = min(maxx+5,ImSize(2)); maxy = min(maxy+5,ImSize(1));
            % reduced to region of the boundary
            reducedMask = mask(miny:maxy, minx:maxx);
            reducedIm = smoothedIm(miny:maxy, minx:maxx);
            dilatedMask = imdilate(reducedMask, se);
            erodedMask = imerode(reducedMask, se);
            boundaryMask = dilatedMask - erodedMask;
            boundaryIntensities = reducedIm(boundaryMask>0);
            H = reducedIm(boundaryMask>0);
            IEr = reducedIm(erodedMask>0);
            IBound = mean(boundaryIntensities);
            IBounds(c) = IBound;
            
            % cell seed information is retrieved as comparison
            F2 = CellSeeds;
            F2(~mask) = 0;
            [cpy cpx]=find(F2 > 252);
            ICentre = smoothedIm(cpy , cpx);
            
            %Figure out which conditions make the label invalid
            %1. IBoundMax, gives the Lower bound to the mean intensity
            %   1.b condition upon that the cell seed has less than 20% intensity difference to the mean
            %   => If the cell boundary is low and not very different from the seed, cancel the region
            first_condition = (IBound < IBoundMax && IBound/ICentre < 1.2);
            %2. W/o (1.b) the lower bound is reduced by ~17% (1 - 0.833) to be decisive
            second_condition = (IBound < IBoundMax *25./30.);
            %3. If the minimum retrieved in the boundary mask is 0 (dangerous!)
            third_condition = (min(boundaryIntensities)==0);
            %4. If the amount of low intensity signal (i.e. < 20) is more than 10% 
            fourth_condition = (sum(H<20)/length(H) > 0.1);
            if  first_condition...
                    || second_condition ...
                    || third_condition...
                    || fourth_condition
                
                %The label is cancelled (inverted mask multiplication.)
                CellLabels = CellLabels.*uint16(mask==0);
            end
            
        end
        %The following debug figure shows the distribution of mean cell boundary intensity
        %if the threshold parameter IBoundMax is too high, valid cells might be delabeled
        if show  
            figure('Name','Histogram of cell boundary intensity');
            hist(IBounds,100); 
            xlabel('mean boundary intensity');
            ylabel('percentage of cells');
            input('press <enter> to continue','s');  
        end
    end

    function DelabelVeryLargeAreas()
        
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev(sprintf('Eliminating cell exceding the threshold radius dimension'), 'INFO');
        % -------------------------------------------------------------------------
        
        % remove cells which are bigger than LargeCellSizeThres
        L = CellLabels;
        dimInitL = length(L);
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
        dimFinalL = length(L);
        
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev(sprintf('Radius = %0.2f | Initial cells = %i | Final cells = %i |',...
                        params.LargeCellSizeThres, dimInitL, dimFinalL),...
               'DEBUG');
        % -------------------------------------------------------------------------

        CellLabels = L;
    end

    function MergeSeedsFromLabels()
        % smoothing
        f1=fspecial( 'gaussian', [ImSize(1) ImSize(2)], sigma3);
        smoothedIm = real(fftshift(ifft2(fft2(Im(:,:)).*fft2(f1))));
        
        labelList = unique(CellLabels);
        labelList = labelList(labelList~=0);
        c = 1;
        % loop over labels
        while 1==1         
            labelMask = CellLabels==labelList(c);
            label = labelList(c);
            
            % -------------------------------------------------------------------------
            % Log current application status
            log2dev(sprintf('Processing label %i',label), 'VERBOSE');
            % -------------------------------------------------------------------------
  
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
                        
            background_std = std(double(centralIntensity));
            
            % get labels of surrounding cells (neighbours)
            neighbourLabels = unique(reducedLabels( dilatedMask > 0 ));
            neighbourLabels = neighbourLabels(neighbourLabels~=label);
            
            low_intensity_ratios = [];
            for i = 1:size(neighbourLabels)
                neighbLabel = neighbourLabels(i);
                neighbor_border = dilatedMask;
                neighbor_border(reducedLabels~=neighbLabel)=0;             % slice of neighbour around cell
                cell_border = imdilate(neighbor_border,se);
                cell_border(reducedLabels~=label) = 0;                     % slice of cell closest to neighbour
                
                joint_border = ...
                    (cell_border + neighbor_border) > 0;                   % combination of both creating boundary region
                border_intensities = reducedIm;
                border_intensities(~joint_border) = 0;                     % intensities at boundary
                
                % average number of points in boundary where intensity is 
                % of low quality (dodgy)
                low_intensity_threshold = ICentre + (background_std/2.);
                low_intensity_pixels = ...
                    border_intensities(joint_border) < low_intensity_threshold;
                
                low_intensity_ratio = ...
                    sum(low_intensity_pixels)/size(border_intensities(joint_border),1);
                
                low_intensity_ratios = [low_intensity_ratios low_intensity_ratio];
            end
               
            
            %Find out which is border with the lowest intensity ratio
            [worst_intensity_ratio,worst_neighbor_index] = max(low_intensity_ratios);
            neighbLabel = neighbourLabels(worst_neighbor_index);
            
            
            % if the label value is of poor quality, then recursively check
            % the merge criteria in order to add it as a potential label in
            % the label set. 
            
            if ...
                    worst_intensity_ratio > params.MergeCriteria && ...
                    label~=0 && ...
                    neighbLabel~=0              
                
                % -------------------------------------------------------------------------
                % Log current application status
                log2dev(sprintf('Trying to merge label %i with value of %0.2f | ABOVE threshold of %0.2f',label,worst_intensity_ratio,params.MergeCriteria), 'DEBUG');
                % -------------------------------------------------------------------------
                
                MergeLabels(label,neighbLabel);
                labelList = unique(CellLabels);
                labelList = labelList(labelList~=0);
                c = c-1;                                                   % reanalyze the same cell for more 
                                                                           % possible mergings
            
            end
            
            c = c+1;
            
            % Condition to break the while cycle -> as soon as all the
            % labels are processed, then exit
            if c > length(labelList);  break;  end
        end
        
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
        
        CellSeeds(cpy1,cpx1) = 20;                                          %background level
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
        % the idea here is to set seeds not labelled to 253
        % ie invisible to retracking (and to growing, caution!)
        L = CellLabels;
        F = CellSeeds;
        F2 = F;
        F2(L~=0) = 0;
        F(F2 > 252) = 253;
%         if(~all(F2 < 252))
%             frpintf('There is a cell seed that has an unlabled region');
%         end
        CellSeeds(:,:) = F;
    end
    
end