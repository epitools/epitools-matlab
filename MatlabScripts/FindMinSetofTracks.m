function [ItracksMini,CLabels3,ColIm2,Frames2Reseg,ILabels2] = FindMinSetofTracks(CLabels2,ILabels,data,TrackingRadius)


disp('Selecting best set of tracks')


[Itracks, pTracks, tracklength, trackstarts, trackstartX, trackstartY]=cellTracking4(ILabels,TrackingRadius);

s = size(CLabels2);

LgTrs = find(tracklength - s(3) +1 == 0);

ItracksMini = zeros(size(Itracks));
CLabels3 = zeros(s);
ColIm2 = zeros(s(1),s(2),3,s(3),'uint8');
Frames2Reseg = [];
ILabels2 = ILabels;

se = strel('square', 3);

for f=1:s(3)
    fprintf('.');
    C= CLabels2(:,:,f);
    ls = unique(C);   ls = ls(ls~=0);
    im = zeros(s(1),s(2));
    for i=1:length(ls)
        l = ls(i);
        if isempty(find(LgTrs == l,1)) continue; end;
        im(C==l) = l;
    end
    
    m = uint8(im > 0);
    
    % fill in centers bits
    m = imfill(m,'holes');
    m = bwlabeln(m);
    m = SelectArea(m,10000,inf);
    
    im = C;
    im(m==0) = 0 ;
    
    % filling small holes in CLabel
    holes = im;
    holes(~m) = -1;
    [cpx,cpy] = find(holes == 0);
    fprintf('%i holes\n',length(cpx));
    for h=1:length(cpx)
        n = C(cpx(h)-2:cpx(h)+2 , cpy(h)-2:cpy(h)+2);
        ll = mode(n(n~=0));
        if isnan(ll)
            disp('fsd')
        end
        im(cpx(h),cpy(h)) = ll;
    end
    
%     m2 = imdilate(~m,se);
%     dls = unique(im(m2>0));
%     dls = dls(dls~=0);
%     
%     im(ismember(im,dls)) = 0;
    
    
    Itm = Itracks(:,:,f);
    try
    Itm(~im) = 0;
    catch
        disp('sdf')
    end
    ItracksMini(:,:,f) = Itm;
    
    CLabels3(:,:,f) = im;
    ColIm2(:,:,:,f) = CreateColorBoundaries(im);
%     figure(99), imshow(ColIm2(:,:,:,f),[])
    
    Ilm = ILabels2(:,:,f); Ilm(~im) = 0;
    [cpx,cpy] = find(Ilm>253);
    
    for i=1:length(cpx)
        l = Itracks(cpx(i),cpy(i),f);
        if l==0
            fprintf('dummy pt found f=%i pos=(%i,%i), need to go back to corrections to fix\n', f , cpy(i),cpx(i));
            continue;
        end
        n = tracklength(l);
        if n == 1 && (f~=1 && f~=s(3))
            fprintf('dummy2 pt found f=%i pos=(%i,%i), need to go back to corrections to fix\n', f , cpy(i),cpx(i));
        end
    end
    
end
    
 fprintf('\n');   

    
    function ColIm = CreateColorBoundaries(CL)
        cellBoundaries = zeros(s(1),s(2),'uint8');
        colIm = zeros([s(1) s(2) 3],'double');
        fs=fspecial('laplacian',0.9);
        cellBoundaries(:,:) = filter2(fs,CL) >.5;
        f1=fspecial( 'gaussian', [s(1) s(2)], 2);
        bw=double(ILabels(:,:,f) > 253); % find labels
        D = data(:,:,f);
        D = D/max(D(:))*255;
        I1 = real(fftshift(ifft2(fft2(D).*fft2(f1))));
        Il = double(I1).*(1-bw)+255*bw; % mark labels on image
        
        colIm(:,:,1) = double(Il)/255.;
        colIm(:,:,2) = double(Il)/255.;
        colIm(:,:,3) = double(Il)/255.;
        colIm(:,:,1) = .7*double(cellBoundaries(:,:)) + colIm(:,:,1).*(1-double(cellBoundaries(:,:)));
        colIm(:,:,2) = .2*double(cellBoundaries(:,:)) + colIm(:,:,2).*(1-double(cellBoundaries(:,:)));
        colIm(:,:,3) = .2*double(cellBoundaries(:,:)) + colIm(:,:,3).*(1-double(cellBoundaries(:,:)));
        
        ColIm = uint8(255*colIm);
    end
    
end
    
    