function [Speeds,DsList,PtsList,Crosses,Sizes] = PrepPlots(T1s,VerticesList, ColLabels,Cell2VerticesList,  Vertices2CellsList, ResT,ResX,LabelContactmaps,DataSource )

DsList = {};            % length of the edge over time and fit
PtsList = {};           % list of 2D pts of the trajectory of the tracked edge
Speeds = [];            % slope of linear fit to edge length
Sizes = [];             % amount of points retrieved for this transition
Crosses = [];           % does the fit cross the x-axis, i.e. is it a 'true' transition


if nargin < 9
    DataSource = '';
    disp('Assuming standard data source')
end

sizeT = size(ColLabels,4);

for i = 1:length(T1s)
    T1 = T1s{i};
    [Ds , mdl,Pts] = PlotT1(T1,VerticesList,ColLabels,Cell2VerticesList,Vertices2CellsList,ResT,ResX,LabelContactmaps,DataSource);
    
    DsList{i} = {Ds , mdl};
    PtsList{i} = Pts;
    Sizes(i) = size(Ds,1);
    Crosses(i) = 0;
    if size(Ds,1) > sizeT * 3/4. && ~isempty(mdl)
        p = mdl.Coefficients.Estimate;
        Speeds(i) = p(2);
        ypred = predict(mdl,Ds(:,1));
        if ypred(1)*ypred(end) < 0  % does it cross the zero line i.e. is it a real transition in the timeframe of the movie?!
            Crosses(i) = 1;
        end
    else
        Speeds(i) = 0;
        Crosses(i) = 0;
    end
end

