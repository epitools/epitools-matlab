function fig = ProcessGUI()

%setting up some things
addpath('/farm/home/tourni01/Projects/2-ImageAnalysis/MatlabScripts');
addpath('/farm/home/tourni01/Projects/2-ImageAnalysis/MatlabScripts/MiniScripts');
addpath('/farm/home/tourni01/Projects/2-ImageAnalysis/MatlabScripts/ExternalMatlabScripts');
addpath('/farm/home/tourni01/Projects/2-ImageAnalysis/13-OME/OMERO.matlab-4.3.3')
addpath('/farm/home/tourni01/Projects/2-ImageAnalysis/13-OME')

%turn off some useless warnings 
warning('off', 'MATLAB:fileparts:VersionToBeRemoved');
warning('off', 'Images:initSize:adjustingMag');
warning('off', 'MATLAB:fftn:uint16Obsolete');

icefile = 'ice.config'

AnalysisSetName = 'Stills'

%% open up OMERO

[client, session, proxy] = myLoadOmero(icefile);
clientAlive = omeroKeepAlive(client); 

OMERO.client = client;
OMERO.proxy = proxy;
OMERO.session = session;

%ListAll(session)

AnalysisSetId = DatasetExists(OMERO.session,AnalysisSetName);
if ~AnalysisSetId
    %AnalysisSetId = CreateNewDataset(session,AnalysisSetName , ProjectId);
    AnalysisSetId = CreateNewDataset(session,AnalysisSetName , 354);
else
    disp('Analysis dataset already exists');
end
OMERO.AnalysisSetId = AnalysisSetId;

%% GUI controls

fig = figure();
BWidth = 0.25;
BHeight = 0.06;


uicontrol(fig,'Style','text',...
                'Units','normalized',...
                'String','Project ID',...
                'Position',[0.06 0.93 0.15 0.04]);
                  
ProjectIDbox = uicontrol(fig,'Style','edit',...
                'Units','normalized',...
                'String','353',...
                'Position',[0.20 0.93 0.1 0.04]);
            
uicontrol(fig,'Style','text',...
                'Units','normalized',...
                'String','Dataset ID',...
                'Position',[0.4 0.93 0.15 0.04]);
                  
DatasetIDbox= uicontrol(fig,'Style','edit',...
                'Units','normalized',...
                'String','353',...
                'Position',[0.54 0.93 0.1 0.04]); 
            
            
uicontrol(fig,'Style','text',...
                'Units','normalized',...
                'String','Image ID',...
                'Position',[0.7 0.93 0.15 0.04]);
                  
ImageIDbox = uicontrol(fig,'Style','edit',...
                'Units','normalized',...
                'String','10478',...
                'Position',[0.84 0.93 0.1 0.04]);
            

uicontrol(fig,'Style','text',...
                'Units','normalized',...
                'String','Image match',...
                'Position',[0.7 0.85 0.15 0.04]);
                  
ImageMatchBox = uicontrol(fig,'Style','edit',...
                'Units','normalized',...
                'String','48h1_',...
                'Position',[0.84 0.85 0.1 0.04]);
            
          
uicontrol(fig,'Style','text',...
                'Units','normalized',...
                'String','Version',...
                'Position',[0.7 0.77 0.15 0.04]);
                  
VersionBox = uicontrol(fig,'Style','edit',...
                'Units','normalized',...
                'String','',...
                'Position',[0.84 0.77 0.1 0.04]);
            
           


uicontrol(fig,'Style','PushButton',...
                'Units','normalized',...
                'String','do Projection',...
                'Position',[0.06 0.8 BWidth BHeight],...
                'Callback', @DoProjection);   
                       
            
uicontrol(fig,'Style','PushButton',...
                'Units','normalized',...
                'String','Segmentation',...
                'Position',[0.06 0.7 BWidth BHeight],...
                'Callback', @DoCrop);
            
% uicontrol(fig,'Style','PushButton',...
%                 'Units','normalized',...
%                 'String','Segmentation',...
%                 'Position',[0.06 0.6 BWidth BHeight],...
%                 'Callback', @DoSegmentation);
%             
            
uicontrol(fig,'Style','PushButton',...
                'Units','normalized',...
                'String','Analysis',...
                'Position',[0.06 0.6 BWidth BHeight],...
                'Callback', @DoAnalysis);
            
            
uicontrol(fig,'Style','PushButton',...
                'Units','normalized',...
                'String','Check Rotation',...
                'Position',[0.06 0.4 BWidth BHeight],...
                'Callback', @CheckRotation);
            
            

% Checks            
 uicontrol(fig,'Style','PushButton',...
                'Units','normalized',...
                'String','Check Projection',...
                'Position',[0.4 0.8 BWidth BHeight],...
                'Callback', @CheckProjection);   
                       
            
% uicontrol(fig,'Style','PushButton',...
%                 'Units','normalized',...
%                 'String','CropIt',...
%                 'Position',[0.4 0.7 BWidth BHeight],...
%                 'Callback', @CropIt);
%             


% 3D            
% uicontrol(fig,'Style','PushButton',...
%                 'Units','normalized',...
%                 'String','3D view',...
%                 'Position',[0.7 0.8 BWidth BHeight],...
%                 'Callback', @View3D);          
%             

    function ID = GetImageIDfromMatch()
        IDBox = eval(get(ImageIDbox,'String'));
        if IDBox ~= 0
            ID = IDBox;
            return
        else
            ID = 0;
        end
        MatchBox = get(ImageMatchBox,'String');
        
        [A , B ] = FindImage(OMERO.session,353,MatchBox,'Series');
        if length(A) == 0 
            disp('found no match');
            ID = -1;
        end
        if length(A) > 1
            disp('found more than one match!');
            ID = -1;
        end
        
        if ID ~= -1  
            ID = A(1);
            return
        end
        
        disp('weird naming .. trying something else');
        A = ImageFind(OMERO.session,353,MatchBox);
        zmax = 0;
        for i=1:length(A)
            [name,sizeC,sizeX,sizeY,sizeZ,sizeT] = GetImageInfo(OMERO.session,A(i));
            if zmax < sizeZ
                zmax = sizeZ;
                ID = A(i);
            end
        end
    end


    function GetAnalysisSet()
        OMERO.ProjectId = eval(get(ProjectIDbox,'String'));
        OMERO.DataSetId = eval(get(DatasetIDbox,'String'));
        %OMERO.ImageId = eval(get(ImageIDbox,'String')); 
        OMERO.ImageId = GetImageIDfromMatch();
        
        OMERO.ImageName = GetImageInfo(OMERO.session,OMERO.ImageId);
        [pathstr, name, ext] = fileparts(OMERO.ImageName);
        fprintf('Analysing: %s (short:%s)\n',char(OMERO.ImageName),name);
        
        
        OMERO.AnalysisVersion = get(VersionBox,'String');
        if ~isempty(OMERO.AnalysisVersion)
            fprintf('Version: %s\n',char(OMERO.AnalysisVersion));
            OMERO.ImageBaseName = [name, '-v',OMERO.AnalysisVersion];
        else
            OMERO.ImageBaseName = OMERO.ImageName;
        end
        
        OMERO.ProjectionName = sprintf('Projection - %s', char(OMERO.ImageBaseName));
        OMERO.SurfaceName = sprintf('Surface - %s', char(OMERO.ImageBaseName));
        OMERO.CroppedName = sprintf('Cropped - %s', char(OMERO.ImageBaseName));
        OMERO.SegmentationLabels = sprintf('Labels - %s', char(OMERO.ImageBaseName));
        OMERO.Seeds = sprintf('Seeds - %s', char(OMERO.ImageBaseName));
        OMERO.FinalSegmentationLabels = sprintf('FINAL Labels - %s', char(OMERO.ImageBaseName));
        OMERO.FinalSeeds = sprintf('FINAL Seeds - %s', char(OMERO.ImageBaseName));
        OMERO.AnalysisName = sprintf('Analysis/%s', OMERO.ImageBaseName);
        
        
        % get some parameters about the images
        image = OMERO.proxy.getImages('omero.model.Image', java.util.Arrays.asList(int64(OMERO.ImageId)), omero.sys.ParametersI()).get(0);
        pixelsList = image.copyPixels();
        
        pixels = pixelsList.get(0);             % skipping over some channel info here probably
        NImages = pixels.getSizeT().getValue(); % The number of timepoints.
        sizeX = pixels.getSizeX().getValue(); % The number of pixels along the X-axis.
        sizeY = pixels.getSizeY().getValue(); % The number of pixels along the Y-axis.
        OMERO.ImSize = [sizeX,sizeY];

    end


    function DoProjection(src,evt)
        mytic = tic;        
        GetAnalysisSet();
        
        
        DeletePrevious(OMERO.session,OMERO.AnalysisSetId,OMERO.ProjectionName);
        [ImId,handle] = CreateNewImageSet(OMERO.session,  'uint16',OMERO.ImSize(1),OMERO.ImSize(2),1, OMERO.ProjectionName, 'projection of the 3D data using fitted surface on original data', OMERO.ProjectId,OMERO.AnalysisSetId);
        
        DeletePrevious(OMERO.session,OMERO.AnalysisSetId,OMERO.SurfaceName);
        [ImId2,handle2] = CreateNewImageSet(OMERO.session,  'uint16',OMERO.ImSize(1),OMERO.ImSize(2),1, OMERO.SurfaceName, 'fitted surface on original data', OMERO.ProjectId,OMERO.AnalysisSetId);
        
        
        SurfSmoothness1 = 10;        SurfSmoothness2 = 15;
        fprintf('Using surface smoothness %i and %i\n', SurfSmoothness1, SurfSmoothness2);
        
        fprintf('Loading images ...')
        [name,sizeC,sizeX,sizeY,sizeZ,sizeT] = GetImageInfo(OMERO.session,OMERO.ImageId);
        if sizeC == 2       % check number of channels, old images save info in channel 1 whereas new ones save it in channel 0
            Ch = 1;
        else
            Ch = 0;
        end
        ImStack = GetStack(OMERO.session,OMERO.ImageId,0,Ch);
        
        ProjectionDepthThreshold = 1.2;
        [im,Surf] = createProjection(ImStack,ProjectionDepthThreshold,SurfSmoothness1,SurfSmoothness2);
        
        WriteIm2OMERO(OMERO.session,handle,im,0);
        WriteIm2OMERO(OMERO.session,handle2,Surf,0);
        
        handle.save();
        handle.close();
        handle2.save();
        handle2.close();
        
        f = toc(mytic);
        fprintf('Final Elapsed time = %ih %imin \n ', floor(f/3600) ,round(mod(f,3600)/60));
    end

    function DoSegmentation(src,evt)
        GetAnalysisSet();
        CroppedID=ImageExists(session, AnalysisSetId,OMERO.ProjectionName);
        if ~CroppedID
            disp('can''t find Registered stack');
            return
        end
        mytic = tic;
        SegmentIm(OMERO);
        f = toc(mytic);
        fprintf('Final full time series. Elapsed time = %ih %imin \n ', floor(f/3600) ,round(mod(f,3600)/60));
    end

    function DoAnalysis(src,evt)
        GetAnalysisSet();
        AnalysisGUI(OMERO);
    end
    
    function View3D(src,evt)
        View3DGUI(OMERO)
    end

    function CheckProjection(src,evt)
        GetAnalysisSet();
        CleanProjectionID=ImageExists(session, AnalysisSetId,OMERO.ProjectionName);
        if ~CleanProjectionID
            disp('can''t find Registered stack');
            return
        end
        ImStack = GetStack(OMERO.session,CleanProjectionID,0,0);
        figure, imshow(ImStack,[]);
        
    end

    function DoCrop(src,evt)
        GetAnalysisSet();
        CleanProjectionID=ImageExists(session, AnalysisSetId,OMERO.ProjectionName);
        if ~CleanProjectionID
            disp('can''t find Registered stack');
            return
        end
        OMERO.ImStack = GetStack(OMERO.session,CleanProjectionID,0,0);
        fig = figure; imshow(OMERO.ImStack,[]); OMERO.ell = imellipse();
        set(fig,'KeyPressFcn',@keyPrsFcn)
        
        function keyPrsFcn(src,evt)
            ch = get(gcf,'CurrentCharacter');
            if ch == 13 % == ENTER
                OMERO.BW = createMask(OMERO.ell);
                close(fig)
                DoSegmentation(src,evt);
                AnalysisGUI(OMERO);
            end
        end
    end


    function CheckRotation(src,evt)
        GetAnalysisSet();
        AnalysisGUI(OMERO);
        cd Analysis
        WingDiskAna(get(ImageMatchBox,'String'));
        cd ..
    end
end

