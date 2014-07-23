function P = AnalyseFrame(L,O,AreaCutOff)
        Props = regionprops(L,'Area','Orientation','Majoraxislength','Minoraxislength','Centroid');
        As = [Props.Area];
        Orient = [Props.Orientation];
        Orient(As<AreaCutOff) = nan;                      % only use cells w areas larger than 10
        MajAx = [Props.MajorAxisLength];
        MinAx = [Props.MinorAxisLength];
        ERs = [Props.MajorAxisLength]./[Props.MinorAxisLength];
        Centers = reshape([Props.Centroid],2,length([Props.Area]))';
        
        D = Centers-repmat(O.Center,[size(Centers,1),1]);
        D = sqrt(sum(D.*D,2));
        DD = Centers - repmat(O.Center,[size(Centers,1),1]);

        % new coordinate system
        V1 = O.BoundaryPt - O.Center;
        V1 = V1/double(norm(V1));
        V2 = [V1(2) -V1(1)];
        V3 = O.DirectionPt-O.Center;
        V3 = V3/double(norm(V3));
        if dot(V3,V2) < 0 
            V2 = -V2;
        end        
        RCenters(:,1) = (Centers(:,1)-O.Center(1))*V1(1) + (Centers(:,2)-O.Center(2))*V1(2);
        RCenters(:,2) = (Centers(:,1)-O.Center(1))*V2(1) + (Centers(:,2)-O.Center(2))*V2(2);
        
        AngleCorrection = acos(V1(1))/pi*180;      % correction due to rotation when going to new coordinate system
        if V1(2) < 0 ,   AngleCorrection = - AngleCorrection;      end
        if AngleCorrection < 90, AngleCorrection = AngleCorrection + 180;  end
        if AngleCorrection > 90, AngleCorrection = AngleCorrection - 180;  end
        NewOrient = Orient-AngleCorrection;
        if V1(1)*V2(2) - V1(2)*V2(1) < 0, NewOrient = - NewOrient; end
        NewOrient(NewOrient > 90) = NewOrient(NewOrient > 90) - 180;
        NewOrient(NewOrient < 90) = NewOrient(NewOrient < 90) + 180;

        % calculate distances relative to edge of disk using boundary
        % points
        RDists = ConverToRelDist(O, Centers);
        

        NotNaNs = ~isnan(D);
        P = AnalysedFrame;
        P.As = As(NotNaNs);
        P.Orient = NewOrient(NotNaNs);
        P.ERs = ERs(NotNaNs);
        P.D = D(NotNaNs)';
        P.DD = DD(NotNaNs,:)';
        P.Centers = RCenters(NotNaNs,:)';   % aligned centres
        P.RDists = RDists;
end        
    