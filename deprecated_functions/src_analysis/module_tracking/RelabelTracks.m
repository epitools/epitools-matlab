function CLabels2 = RelabelTracks(CLabels,Ilabels,TrackingRadius)

% this function relabels the cells in the segmented frames (CLabels)
% according to the number given by the tracking algorithm so that the same
% numbers run through the stack

[Itracks, pTracks, tracklength, trackstarts, trackstartX, trackstartY]=cellTracking4(Ilabels,TrackingRadius);

disp('Re-labelling')
s = size(CLabels);
CLabels2 = zeros(s);
for f=1:size(CLabels,3)
    fprintf('.');
    C = CLabels(:,:,f);
    T = Itracks(:,:,f);
    C2 = zeros(s(1),s(2));
    ls = unique(C);
    ls = ls(ls~=0);
    u = max(T(:));
    for i=1:size(ls,1)
        l = ls(i);
        newlab = unique(T(C==l));
        newlab= newlab(newlab~=0);
        if isempty(newlab) 
            newlab = u+1;
            u = u+1;
        end
        try
            C2(C==l) = newlab;
        catch 
            fprintf('needs resegmenting!! frame %i\n',f)
        end
    end
    CLabels2(:,:,f) = C2;
end
fprintf('\n');

end
            
                
        
