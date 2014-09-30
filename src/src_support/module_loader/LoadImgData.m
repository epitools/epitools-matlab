function [ImgStack] = LoadImgData(strFullPathFile, imgIDX, arrayIndices)

% initialize logging
loci.common.DebugTools.enableLogging('INFO');

Z = cell2mat(arrayIndices.Z(imgIDX)) - 1 ;
C = cell2mat(arrayIndices.C(imgIDX)) - 1 ;
T = cell2mat(arrayIndices.T(imgIDX)) - 1 ;

if(size(C)>1)
    C = 0;
end

% Read image file data
reader = bfGetReader(strFullPathFile);

for z=1:numel(Z)
    for c=1:numel(C)
        for t=1:numel(T)
            
            intPlaneIdx = reader.getIndex(Z(z),C(c),T(t));
            ImgStack(:,:,Z(z)+1,C(c)+1,T(t)+1) = bfGetPlane(reader, intPlaneIdx+1);
            
        end
    end
end

% Get rid of empty
ImgStack = squeeze(ImgStack);

reader.close();
end