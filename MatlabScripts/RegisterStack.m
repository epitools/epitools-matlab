function RegIm = RegisterStack(ImSeries)
% Registration of the images in the stacks
% the process uses 2 steps: one coarse and one fine
%

% Parameters for the coarse registration step
Ang = [-5:1:5];             % angle differences to explore
X = [-150:10:150];          % Delta X to explore
Y = [-150:10:150];          % Delta Y to explore

% Parameters for the fine registration step (finer steps)
FAng = -1.5:.1:1.5;
FX = [-15:1:15];
FY = [-15:1:15];

%%

NImages = size(ImSeries,3);
s = size(ImSeries);
ImSize = s(1:2);

%%
f1=fspecial( 'gaussian', ImSize, .1);
se = strel('disk',10);

fprintf('Building coarse view of stack ...')

% building a coarse view of the stack
Coarse = zeros([ImSize,NImages]);
for i = 1:NImages           
    T = ImSeries(:,:,i);
    T(T<.4) = 0;                %todo: check this out!! uint8 / uint16 problem
    closeBW = imclose(T,se);
    Ifill = imfill(closeBW,'holes');
    Im2 = imopen(Ifill,se);
    Coarse(:,:,i ) = Im2;
end

% building a finer view of the stack
se = strel('disk',5);
Coarse2 = zeros([ImSize,NImages]);
parfor i = 1:NImages
    T = ImSeries(:,:,i);
    T = real(fftshift(ifft2(fft2(T).*fft2(f1))));
    closeBW = imclose(T,se);    
    Ifill = imfill(closeBW,'holes');    
    Im2 = imopen(Ifill,se);
    Coarse2(:,:,i ) = Im2;
end
fprintf('done\n');

%%

fprintf('Registering projected images ...\n');

RegRes = {};
RegRes2 = {};

parfor i = 2:NImages
    fprintf('%i/%i\n', i,NImages);
    RegRes = Register(Coarse(:,:,i),Coarse(:,:,i-1),Ang,X,Y,'opt');
    %finer, 2nd go!
    RegRes2{i} = Register(Coarse2(:,:,i),Coarse2(:,:,i-1),FAng + RegRes.Ang ,FX +RegRes.x ,FY + RegRes.y ,'opt');
end

%%

RegRes2{1}.CumX = 0;
RegRes2{1}.CumY = 0;
RegRes2{1}.CumAng = 0;

for i = 2:NImages    
    RegRes2{i}.CumX = RegRes2{i-1}.CumX + RegRes2{i}.x ;
    RegRes2{i}.CumY = RegRes2{i-1}.CumY + RegRes2{i}.y;
    RegRes2{i}.CumAng = RegRes2{i-1}.CumAng + RegRes2{i}.Ang;
end



%% new projIm
fprintf('Saving registered images ...\n');
RegIm = zeros(size(ImSeries));
RegIm(:,:,1) = ImSeries(:,:,1);

parfor i = 2:NImages
    im = ApplyReg(RegRes2{i},ImSeries(:,:,i));
    RegIm(:,:,i) = im;
end

%%
end

