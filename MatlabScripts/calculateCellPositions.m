function pos=calculateCellPositions(I1, labelledcells, type)
%  This function calculates the min intensity position of each labelled cell 
%  or the centroid position of each labelled region

no_cells=max(labelledcells(:));

pos=zeros(no_cells,2);

I2=255-I1;

for n=1:no_cells,
    
 [sy , sx]=find(labelledcells==n);
 
 if (type == 1) % looking for the lowest intensity
     
     PlaceAtLowestInt(n)
     
 else % calculating the centroid from intensities
     
     PlaceAtCentroid(n)
     
     if ~isnan(pos(n,2)) && labelledcells(pos(n,2),pos(n,1)) ~= n
         % every so often the centroid is actually not in the label!
         PlaceAtLowestInt(n)
     end
     
 end
 
end
 
 


 function PlaceAtLowestInt(n)
 val=255;
 for m=1:length(sy),
     
     if (I1(sy(m),sx(m)) < val)
         
         val=I1(sy(m),sx(m));
         pos(n,2)=sy(m);
         pos(n,1)=sx(m);
         
     end
     
 end
 end
 
 function PlaceAtCentroid(n)
 sumX=0; sumY=0; sumI=0;
 
 for m=1:length(sy),
     
     sumX=sumX+sx(m)*I2(sy(m),sx(m));
     sumY=sumY+sy(m)*I2(sy(m),sx(m));
     sumI=sumI+I2(sy(m),sx(m));
 end
 
 pos(n,2)=round(sumY/sumI);
 pos(n,1)=round(sumX/sumI);
 end
  
 
  
    
end




