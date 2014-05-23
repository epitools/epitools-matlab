function Projection(DataSpecificsPath,...
    SmoothingRadius,SurfSmoothness1,SurfSmoothness2,ProjectionDepthThreshold)
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
res = ReadMicroscopyData(FullDataFile, Series);

%Number of time points to be analyzed
NT = res.NT;

Surfaces = zeros(res.NY,res.NX,NT);
ProjIm = zeros(res.NY,res.NX,NT);

InspectResults = false;         % show fit or not

%matlabpool 2
d = 0;

% For loop for all files in the folder (lst) and second parfor for all timepoints
fprintf('Started projection at %s',datestr(now));
for i =1:length(lst)
    if isempty(strfind(lst(i).name,Filemask)); continue; end;
    FullDataFile = [DataDirec,'/',lst(i).name];
    res = ReadMicroscopyData(FullDataFile, Series);
    res.images = squeeze(res.images); % get rid of empty 
    fprintf('Working on %s\n', lst(i).name);
   
    %information seems to not be transmitted correctly 10 time points
    %appear to be presente while there are only 3, CHECK [ ] 
    for f = 1:res.NT 
        ImStack = res.images(:,:,:,f);
        [im,Surf] = createProjection(ImStack,SmoothingRadius,ProjectionDepthThreshold,SurfSmoothness1,SurfSmoothness2,InspectResults);
        ProjIm(:,:,f+d) = im;
        Surfaces(:,:,f+d) = Surf;
        progressbar(((i-1)*res.NT+f)/length(lst)/res.NT);
    end
    d=d+res.NT;
end

save([AnaDirec,'/ProjIm'],'ProjIm')
save([AnaDirec,'/Surfaces'],'Surfaces')

progressbar(1);
fprintf('Finished projection at %s',datestr(now));

StackView(ProjIm);

end

