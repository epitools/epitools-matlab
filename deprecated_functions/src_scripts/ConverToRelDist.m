function NDist = ConverToRelDist(Orient, Centers)

K = convhull(Orient.BoundaryPts(:,1),Orient.BoundaryPts(:,2));
B = Orient.BoundaryPts(K,:);

% construct XY2 for fast intersection calculations
XY2 = [];
for i = 1:size(B,1)-1
    XY2(i,:) = [B(i,1),B(i,2),B(i+1,1),B(i+1,2)];
end
N = size(B,1);
XY2(N,:) = [B(1,1),B(1,2),B(N,1),B(N,2)];

Centers = Centers(~isnan(Centers(:,1)),:);

% construct XY1
XY1 = [];
SizeDat = size(Centers,1);
for i = 1:SizeDat
    Crd = Orient.Center + (Centers(i,:) - Orient.Center)*1000;
    XY1(i,:) = [Orient.Center(1) Orient.Center(2) Crd(1) Crd(2)];
end
    
Intersecs = lineSegmentIntersect(XY1,XY2);
I = Intersecs.intAdjacencyMatrix;

NDist = [];
for i = 1:SizeDat
    NInter = find(I(i,:),1);
    Cinter = [Intersecs.intMatrixX(i,NInter) Intersecs.intMatrixY(i,NInter)];
    V1 = Cinter - Orient.Center;
    V2 = Centers(i,:) - Orient.Center;
    NDist(i) = norm(V2)/norm(V1);
end

end
