function CreateGraphs(P)
Nbins = 10;

Dmax = max(P.D);
BinSize = Dmax/Nbins;
Dbin = ceil(P.D/BinSize);
%RDbinNN = ceil(RDists*Nbins);               % bin over relative distances!
RDbinNN = round((P.RDists+.5/Nbins)*Nbins); 


COrient = atan(P.DD(:,2)./P.DD(:,1)) / pi * 180;
ROrient = P.Orient' + COrient;
ROrient(ROrient>90) = ROrient(ROrient>90) - 180;
ROrient(ROrient<-90) = ROrient(ROrient<-90) + 180;


CreateARadialGraph()
CreateERRadialGraph()
CreateOGraphs()
CreateORadialGraph()
CreateARegisteredGraph()
CreateERRegisteredGraph()
CreateOLinePlts(10, 12, 4)

    function CreateOLinePlts(NX , NY, ScaleFactor)
        Xmin = min(P.Centers(:,1))*1.2; Xmax = max(P.Centers(:,1))*1.2;
        Ymin = min(P.Centers(:,2))*1.2; Ymax = max(P.Centers(:,2))*1.2;
        
        % get rid of Weights on non-existant ERs
        M = and(~isnan(P.Orient) , isnan(P.ERs));
        P.Orient(M) = nan;
        
        [Xrge,Yrge,MWeight,N] = BinData5(P.Centers,P.ERs - 1, Xmin,Xmax,Ymin,Ymax,NX,NY);
        [Xrge,Yrge,MOrient,N] = BinData5(P.Centers,P.Orient, Xmin,Xmax,Ymin,Ymax,NX,NY);
        
        
        [dataO, datae] = CreateGraphCircular(MOrient,MWeight,NX,NY);
        

        [Xrge,Yrge,MERs,N] = BinData4(P.Centers,P.ERs, Xmin,Xmax,Ymin,Ymax,NX,NY);
        [Xrge,Yrge,MAs,N] = BinData4(P.Centers,P.As, Xmin,Xmax,Ymin,Ymax,NX,NY);
                
        MERs = flipud(MERs');
        MAs  = flipud(MAs');
        dataO   = flipud(dataO');
        
        dataO(dataO==0) = nan;
        
        DX = cos(dataO/180*pi).*(MERs-1)*ScaleFactor;
        DY = sin(dataO/180*pi).*(MERs-1)*ScaleFactor;
       
        X2 = repmat(Xrge,NY,1);  Y2 = repmat(Yrge',1,NX);
        
        M = ~isnan(DX);
        X2 = X2(M); Y2 = Y2(M);
        DX = DX(M); DY = DY(M);
        
        %figure
        subplot(3,3,9);
%         contourf(Xrge,Yrge,MAs,20,'edgecolor','None');  axis equal; axis tight; colorbar
%         hold on
        q=quiver(X2,Y2,DX,DY);
        set(q,'ShowArrowHead','off', 'AutoScale','off','Color','black', 'LineWidth' , 1.5);
        q2=quiver(X2,Y2,-DX,-DY);
        set(q2,'ShowArrowHead','off','AutoScale','off' , 'Color','black' , 'LineWidth' , 1.5);
        title 'Corrected Area plot (\mum^2) w direction of longest axis superimposed';
        xlabel 'distance (\mum)';
        axis equal
        axis([Xmin Xmax Ymin Ymax])
    end


    function CreateARegisteredGraph()
       [X,Y,M,N] = BinData4(P.Centers,P.As,min(P.Centers(:,1))*1.2,max(P.Centers(:,1))*1.2,min(P.Centers(:,2))*1.2,max(P.Centers(:,2))*1.2,30,20);
       M(M==0) = min(P.As(P.As ~= 0));        
       subplot(3,3,3);  
       contourf(X,Y,flipud(M'),20,'edgecolor','None');  
       colorbar, title 'Area (\mum^2)'; xlabel 'distance (\mum)'; 
       axis equal, axis tight; %caxis([0 7])
       colormap jet
    end

    function CreateERRegisteredGraph()
       [X,Y,M,N] = BinData4(P.Centers,P.ERs,min(P.Centers(:,1))*1.2,max(P.Centers(:,1))*1.2,min(P.Centers(:,2))*1.2,max(P.Centers(:,2))*1.2,20,20);
       M(M==0) = 1;         % ER never goes below 1!
       subplot(3,3,6);
       contourf(X,Y,flipud(M'),20,'edgecolor','None');  colorbar, title ''; xlabel 'distance (\mum)'; axis equal, axis tight
       title 'ERs'
       caxis([1 2.5])
    end



    function CreateARadialGraph()
        G = [];
        stdE = [];
        Ns = [];
        for i=1:Nbins
            G(i) = mean(P.As(RDbinNN==i));
            stdE(i) = std(P.As(RDbinNN==i))/sqrt(length(P.As(RDbinNN==i)));
            Ns(i) = sum(RDbinNN==i);
        end
        X = ((1:Nbins) - .5)/Nbins;
        scrsz = get(0,'ScreenSize');
        figure, plot(X,Ns,'*')
        figure('Position',[1 0 scrsz(3) scrsz(4)])
        subplot(3,3,1); errorbar(X,G,stdE); title 'Radial Area plot'; xlabel 'relative distance'
        
        xlim([0 1])
    end

    function CreateERRadialGraph()
        G = [];
        stdE = [];
        for i=1:Nbins
            G(i) = mean(P.ERs(RDbinNN==i));
            stdE(i) = std(P.ERs(RDbinNN==i))/sqrt(length(P.ERs(RDbinNN==i)));
        end
        X = ((1:Nbins) - .5)/Nbins;
        subplot(3,3,4); errorbar(X,G,stdE); title 'Radial ER plot'; xlabel 'relative distance '
        xlim([0 1]);
    end


    function CreateOGraphs()
        G = [];
        stdE = [];

        [X,Y,N] = BinData3(abs(ROrient(Dbin > 7)),P.ERs(Dbin > 7),0,90,1,4,8,9);
        subplot(3,3,8);  contourf(X,Y,N',20,'edgecolor','None');  colorbar, title 'bins > 7 corrected'; xlabel 'angle'; caxis([0 0.07]); ylim([1 2.5]);
        colormap hot
        freezeColors;
        cbfreeze;
        
        [X,Y,N] = BinData3(abs(ROrient(Dbin > 4 & Dbin < 6)),P.ERs(Dbin > 4 & Dbin < 6),0,90,1,4,8,9);
        subplot(3,3,5);  contourf(X,Y,N',20,'edgecolor','None');  colorbar, title '4 < bins < 7 corrected'; xlabel 'angle'; caxis([0 0.07]); ylim([1 2.5]);
        colormap hot
        freezeColors; cbfreeze;
        
        [X,Y,N] = BinData3(abs(ROrient(Dbin < 5)),P.ERs(Dbin < 5),0,90,1,4,8,10);
        subplot(3,3,2);  contourf(X,Y,N',20,'edgecolor','None');  colorbar, title 'bins < 5 corrected'; xlabel 'angle'; caxis([0 0.07]); ylim([1 2.5]);
        colormap hot
        freezeColors; cbfreeze;
    end
        
    function CreateORadialGraph()
        [X,Y,N] = BinData3(P.D,abs(ROrient)',0,Dmax,0,90,6,12);
        N = N./repmat(sum(N,2),1,12);
        %figure, contourf(X,Y,N',30,'edgecolor','None');  colorbar, title 'orientation'; xlabel 'distance'; ylabel 'angle'
        subplot(3,3,7);  contourf(X,Y,N',30,'edgecolor','None');  colorbar, title 'orientation'; xlabel 'distance (\mum)'; ylabel 'angle'
    end

    function [Xrge,Yrge,N] = BinData3(X,Y,Xmin,Xmax,Ymin,Ymax,NX,NY)
        % here use different approach to span whole area of data
        % areas close to edges have only 1/2 the data as a consequence
        good = ~(isnan(X) + isnan(Y'));
        X = X(good);
        Y = Y(good);
        XBinSize = (Xmax - Xmin )/(NX-1);
        YBinSize = (Ymax - Ymin )/(NY-1);
        N = zeros([NX,NY]);
        for i = 1:length(X)
            ix = ceil((X(i)-Xmin+XBinSize/2.)/XBinSize);
            iy = ceil((Y(i)-Ymin+YBinSize/2.)/YBinSize);
            ix = min(max(ix,1),NX);
            iy = min(max(iy,1),NY);
            N(ix,iy) = N(ix,iy) + 1;
        end
        % now correct for size
        N(:,1) = N(:,1)*2;
        N(:,NY) = N(:,NY)*2;
        N(1,:) = N(1,:)*2;
        N(NX,:) = N(NX,:)*2;
        
        N = N/sum(N(:));
        
        Xrge = Xmin:XBinSize:Xmax;
        Yrge = Ymin:YBinSize:Ymax;
    end

    function [Xrge,Yrge,M,N] = BinData4(Pos,Dat, Xmin,Xmax,Ymin,Ymax,NX,NY)
        % here use different approach to span whole area of data
        % areas close to edges have only 1/2 the data as a consequence
        X = Pos(:,1);   Y = Pos(:,2);
        good = ~(isnan(X) + isnan(Y) + isnan(Dat'));
        X = X(good);
        Y = Y(good);
        Dat = Dat(good);
        XBinSize = (Xmax - Xmin )/(NX-1);
        YBinSize = (Ymax - Ymin )/(NY-1);
        N = zeros([NX,NY]);
        M = zeros([NX,NY]);
        for i = 1:length(X)
            ix = ceil((X(i)-Xmin+XBinSize/2.)/XBinSize);
            iy = ceil((Y(i)-Ymin+YBinSize/2.)/YBinSize);
            ix = min(max(ix,1),NX);
            iy = min(max(iy,1),NY);
            N(ix,iy) = N(ix,iy) + 1;
            M(ix,iy) = M(ix,iy) + Dat(i);
        end
        
        M = M ./N;
        M(isnan(M)) = 0;
        
        Xrge = Xmin:XBinSize:Xmax;
        Yrge = Ymin:YBinSize:Ymax;
    end

    function [Xrge,Yrge,M,N] = BinData5(Pos,Dat, Xmin,Xmax,Ymin,Ymax,NX,NY)
        % here use different approach to span whole area of data
        % areas close to edges have only 1/2 the data as a consequence
        X = Pos(:,1);   Y = Pos(:,2);
        good = ~(isnan(X) + isnan(Y) + isnan(Dat'));
        X = X(good);
        Y = Y(good);
        Dat = Dat(good);
        XBinSize = (Xmax - Xmin )/(NX-1);
        YBinSize = (Ymax - Ymin )/(NY-1);
        N = zeros([NX,NY]);
        M = cell([NX,NY]);
        for i = 1:length(X)
            ix = ceil((X(i)-Xmin+XBinSize/2.)/XBinSize);
            iy = ceil((Y(i)-Ymin+YBinSize/2.)/YBinSize);
            ix = min(max(ix,1),NX);
            iy = min(max(iy,1),NY);
            N(ix,iy) = N(ix,iy) + 1;
            M{ix,iy}(length(M{ix,iy})+1) = Dat(i);
        end
        
        Xrge = Xmin:XBinSize:Xmax;
        Yrge = Ymin:YBinSize:Ymax;
    end

    function [data, datae] = CreateGraphCircular(Orient,Weight,NX,NY)
        data = zeros([NX,NY]);
        datae = zeros([NX,NY]);
        for ii=1:NX
            for j=1:NY
                % weight the contribution to bins by the ER -1
                if isempty(Orient{ii,j}), continue;     end
                if isnan(Orient{ii,j}),   continue;     end
                %[n,xout] = hist(data{i,j},20);
                [n2,xout2] = Whist(Orient{ii,j},Weight{ii,j},20);
                %figure , bar(xout2,n2)
                
                [C,I] = max(n2);
                maxi = xout2(I);         % this an approximation of the mean value of the data, refold around this
                d = Orient{ii,j};
                d= d(~isnan(d));
                m = d < maxi - 90;
                m2 = d > maxi + 90;
                d(m) = d(m) + 180;
                d(m2) = d(m2) - 180;
                data(ii,j) = mean(d);
                datae(ii,j) = std(d);
            end
        end
    end

    function [H,xout] = Whist(data,W,N)
        try
            W=W(~isnan(data));
        catch
            disp('sdf')
        end
        data = data(~isnan(data));
        dmin = min(data);
        dmax = max(data);
        if length(data) == 1
            H = [W];
            xout = data(1);
            return
        end
        w = (dmax-dmin)/N;
        d = data - dmin + w;
        d = floor(d/w);
        d(d==N+1) = N;
        try
            H = accumarray(d', W)';
        catch
            disp('fsd')
        end
        xout = dmin+w/2.:w:dmax-w/2.+w/10.;
    end
        

end