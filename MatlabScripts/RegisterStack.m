function RegIm = RegisterStack(ProjIm)
% RegisterStack Register a time series to reduce sample movement 
%
% IN: 
%   ProjIm - Projected Image time series                                   (substitute with ImStack?)
% 
% OUT: 
%   RegIm - 
%
% Author:
% Copyright:

%% parameters (quite robust so far!)                                       

Ang = [-5:1:5];                                                            % what are these parameters?
X = [-150:10:150];
Y = [-150:10:150];

FAng = -1.5:.1:1.5;
FX = [-15:1:15];
FY = [-15:1:15];
%%                                                                         % add section title/comment

NImages = size(ProjIm,3);
s = size(ProjIm);
ImSize = s(1:2);

%%                                                                         % add section title/comment
f1=fspecial( 'gaussian', ImSize, .1);
se = strel('disk',10);

fprintf('Building coarse view of stack ...')


Coarse = zeros([ImSize,NImages]);                                          % explain Coarse matrix
parfor i = 1:NImages
    T = ProjIm(:,:,i);
    T(T<.4) = 0;
    closeBW = imclose(T,se);
    Ifill = imfill(closeBW,'holes');
    Im2 = imopen(Ifill,se);
    Coarse(:,:,i ) = Im2;
end

se = strel('disk',5);
Coarse2 = zeros([ImSize,NImages]);
parfor i = 1:NImages
    T = ProjIm(:,:,i);
    T = real(fftshift(ifft2(fft2(T).*fft2(f1))));
    closeBW = imclose(T,se);    
    Ifill = imfill(closeBW,'holes');    
    Im2 = imopen(Ifill,se);
    Coarse2(:,:,i ) = Im2;
end
fprintf('done\n');

%%                                                                         % add section title/comment

fprintf('Registering projected images ...\n');

RegRes = {};
RegRes2 = {};

parfor i = 2:NImages                                                       % why 2 iterations?
    fprintf('%i/%i\n', i,NImages);
    RegRes = Register(Coarse(:,:,i),Coarse(:,:,i-1),Ang,X,Y,'opt');        
    %finer, 2nd go!
    RegRes2{i} = Register(Coarse2(:,:,i),Coarse2(:,:,i-1),FAng + RegRes.Ang ,FX +RegRes.x ,FY + RegRes.y ,'opt');
end

%%                                                                         % add section title/comment

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
RegIm = zeros(size(ProjIm));
RegIm(:,:,1) = ProjIm(:,:,1);

parfor i = 2:NImages
    im = ApplyReg(RegRes2{i},ProjIm(:,:,i));
    RegIm(:,:,i) = im;
end

%%
end

