function DataSpecificsPath = InspectData( DataDirec )
%InspectData Inspects the input images and outputs their details to the
%user

AnaDirec = [DataDirec,'/Analysis'];
DataSpecificsPath = [AnaDirec,'/DataSpecifics'];

if(exist([DataSpecificsPath,'.mat'],'file'))
    fprintf('Found previous DataSet GUI Configuration File:\n%s\n',DataSpecificsPath)
else

    % create directory where to store results of analysis
    mkdir(AnaDirec)

    %Filemask = 'frame_085b_525e963c9e3a7_hrm.tif'; %same for 028 and 068, 089
    %because of bright spot correction
    Filemask = '.tif';

    lst = dir(DataDirec);


    %Find the index of the first image in the directory list
    first_index = 0;
    for i =1:length(lst)

        if isempty(strfind(lst(i).name,Filemask)); 
            continue; 
        else
            first_index = i;
            break;
        end;

    end

    FullDataFile = [DataDirec,'/',lst(first_index).name];
    Series = 1;
    res = ReadMicroscopyData(FullDataFile, Series);

    %print content of the first image
    fprintf('First Data Point:\t%s\nDimensions(XYZTC):\t%d,%d,%d,%d,%d\n',...
        FullDataFile,...
        res.NX,res.NY,res.NZ,res.NT,res.NC);

    %Save details
    save(DataSpecificsPath,...
        'DataDirec','AnaDirec','lst','Filemask','Series','FullDataFile')
end
end

