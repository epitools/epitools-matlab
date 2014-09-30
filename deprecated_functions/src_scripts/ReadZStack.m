function stack = ReadZStack(r,C,T)
% 
% NX = r.getSizeX();
% NY = r.getSizeY();
% NZ = r.getSizeZ();
% NC = r.getSizeC();
% NT = r.getSizeT();
% metadata = r.getMetadataStore();
% PixelType = metadata.getPixelsType(0).getValue().toCharArray()';
PixelType = 'uint16';

% frameoffset =  (T-1)*NC*NZ + (C-1)*NZ;
frameoffset = (T-1)*34;
NX = 829;
NY = 1000;
NZ = 34;

stack = zeros([NY,NX,NZ],PixelType);
for z = 1:NZ
    arr = bfGetPlane(r,frameoffset + z );
    stack(:,:,z) = arr;
end
fprintf('\n');
