function [ VerticesList, LabelContactmaps, Cell2VerticesList ,Vertices2CellsList, VerticesConnectsList,ContactIms ] = FitVerticesInFrames( RegIm , CLabels )

s = size(RegIm);
ContactIms = zeros(s(1),s(2),3,s(3),'uint8');

disp('Fitting vertices to data')

t1 = tic;
for t = 1:s(3)
    disp(t)
    [LabelContactmap ,Vertices, Cell2Vertices, VerticesConnects,Vertices2Cells,im1] = FitVertices(CLabels(:,:,t) ,RegIm(:,:,t));
    
    LabelContactmaps{t} = LabelContactmap;
    Cell2VerticesList{t} = Cell2Vertices;
    VerticesConnectsList{t} = VerticesConnects;
    Vertices2CellsList{t} = Vertices2Cells;
    VerticesList{t} = Vertices;
    ContactIms(:,:,:,t) = im1*255.;
    
    elapsedTime = toc(t1);
    minsleft = elapsedTime/t*(s(3)-t)/60;
    fprintf('elapsted time %i mins (%i frames) - estimated %ih%02im left (%i/%i frames to go)\n', round(elapsedTime/60) ,t, round(minsleft/60) , mod(round(minsleft),60),s(3)-t,s(3) );

end

