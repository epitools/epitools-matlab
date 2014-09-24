function trajectories_statistics()

cmplength = [];
cmpstarts = [];
cmphists = [];

for idxtime=1:size(Itracks,3)
    [x,y] = find(Itracks(:,:,idxtime));
    for idx=1:numel(x)

        track_uid = Itracks(x(idx),y(idx),idxtime);
        cmpstarts(idxtime,idx) = trackstarts(track_uid);
        cmplength(idxtime,idx) = tracklength(track_uid);
        
        
    end
    cmphists(idxtime,:) = hist(cmplength(idxtime,:),size(Itracks,3))/sum(hist(cmplength(idxtime,:)));
end


track_uids = Itracks(x,y,idxtime);
track_uids = track_uids(track_uids~=0);

cmpstarts(idxtime,:) = trackstarts(track_uids);
cmplength(idxtime,:) = tracklength(track_uids);

% Histograms to include in update image function passing time id


% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,...
            'YColor',[0.501960813999176 0.501960813999176 0.501960813999176],...
            'XGrid','on',...
            'XColor',[0.501960813999176 0.501960813999176 0.501960813999176],...
            'Position',[0.10 0.10 0.775 0.40],...
            'FontName','Tahoma',...
            'Color',[0 0 0],...
            'Ylim', [0.5 1.7],...
            'YTick',1);
box(axes1,'on');
hold(axes1,'all');

data = sort([cmphists(1,:);NaN(size(cmphists,2),1)'],2,'descend');
data(data == 0) = NaN
% per each frame represent track length distribution in percentage 
hDataSeries = barh(data,...
                'Stacked',...
                'EdgeColor',[0.831372559070587 0.815686285495758 0.7843137383461],...
                'Parent',axes1);

hPatches = get(hDataSeries,'Children');
try hPatches = cell2mat(hPatches); catch, end  % no need in case of single patch
yData = get(hPatches(1),'YData');
yPos = yData(end,:) - 0.40;
xData = get(hPatches,'XData');
try xData = cell2mat(xData); catch, end
barXs = xData(2:4:end,:);
barValues = diff([zeros(1,size(barXs,2)); barXs]);
barValues(bsxfun(@minus,barValues,sum(barValues))==0) = 0;  % no sub-total for bars having only a single sub-total
xPos = xData(1:4:end,:) + barValues/3;
yPos = yPos(ones(1,size(xPos,1)),:);


yPos(barValues==0)      = [];  % remove entries for empty bars patches
xPos(barValues==0)      = [];  % remove entries for empty bars patches
barValues(barValues==0) = [];  % remove entries for empty bars patches
barValues = round(barValues * 100);
labels = strcat(' ', arrayfun(@(x) num2str(x,'%0.2f'),barValues(:),'uniform',false), '%');
hText = text(xPos(:), yPos(:), labels);
set(hText, 'FontSize',9, 'Color', 'white', 'FontName', 'Tahoma');

legend1 = legend(axes1,'show');
set(legend1,...
    'TextColor',[0.800000011920929 0.800000011920929 0.800000011920929],...
    'Orientation','horizontal',...
    'Location','NorthOutside');

end
