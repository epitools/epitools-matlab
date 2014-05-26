function Projection(DataSpecificsPath,params)

%SurfaceProjection Discover the surface of the highest intensity signal in
%the image stack and selectively project the signal lying on that surface
%
%   DataSpecificsPath - Path Data to analyze (See InspectData function)
%   SmoothingRadius - how much smoothing to apply to original data (1-5)
%   SurfSmoothness1 - 1st surface fitting, surface stiffness ~100
%   SurfSmoothness2 - 2nd surface fitting, stiffness ~50
%   ProjectionDepthThreshold - how much up/down to gather data from surface

%initialize progressbar
progressbar('Projecting images...');

load(DataSpecificsPath);
Data = ReadMicroscopyData(FullDataFile, Series);
% todo: need to convert to int8 in a rational way here!
% can use 95 or 99% quantile of the data and then scale

Surfaces = zeros(Data.NY,Data.NX,Data.NT,'uint8');
ProjIm = zeros(Data.NY,Data.NX,Data.NT, Data.PixelType);

d = 0;

% For loop for all files in the folder (lst) and second parfor for all timepoints
fprintf('Started projection at %s',datestr(now));
for i =1:length(lst)
    if isempty(strfind(lst(i).name,Filemask)); continue; end;
    FullDataFile = [DataDirec,'/',lst(i).name];
    Data = ReadMicroscopyData(FullDataFile, Series);
    Data.images = squeeze(Data.images); % get rid of empty 
    fprintf('Working on %s\n', lst(i).name);
   
    %information seems to not be transmitted correctly 10 time points
    %appear to be presente while there are only 3, CHECK [ ] 
    for f = 1:Data.NT 
        ImStack = Data.images(:,:,:,f);
        [im,Surf] = createProjection(ImStack,params.SmoothingRadius,params.ProjectionDepthThreshold,params.SurfSmoothness1,params.SurfSmoothness2,params.InspectResults);
        ProjIm(:,:,f+d) = im;
        Surfaces(:,:,f+d) = Surf;
        progressbar(((i-1)*Data.NT+f)/length(lst)/Data.NT);
    end
    d=d+Data.NT;
end

save([AnaDirec,'/ProjIm'],'ProjIm')
save([AnaDirec,'/Surfaces'],'Surfaces')

progressbar(1);
fprintf('Finished projection at %s\n',datestr(now));

if params.InspectResults
    StackView(ProjIm);
end

end

