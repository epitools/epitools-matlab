
cmplength = [];
cmpstarts = [];

for idxtime=1:size(Itracks,3)
    [x,y] = find(Itracks(:,:,idxtime));
    for idx=1:numel(x)

        track_uid = Itracks(x(idx),y(idx),idxtime);
        cmpstarts(idxtime,idx) = trackstarts(track_uid);
        cmplength(idxtime,idx) = tracklength(track_uid);


    end
end