function LoadEtMetaData( stgObj )
%LOADETMETADATA Loads predifined epitool_metadata xml file
% Given a settings object file with defined MAIN module this function
% populates the module with the data strucuture summarizing the images
% that will be analyzed
    
    if ~stgObj.hasModule('Main')
        errordlg('No Main Module found!');
        return
    end

    metafile_file = [stgObj.data_imagepath,'/epitool_metadata.xml'];

    if ~exist(metafile_file, 'file')
        errordlg('No Metafile found at image_path!');
        return
    end

    MetadataFIGXML = xml_read(metafile_file);
    vecFields = fields(MetadataFIGXML.files);

    for i=1:length(vecFields)

        MetadataFIGXML.files.(char(vecFields(i))).exec = logical(MetadataFIGXML.files.(char(vecFields(i))).exec);
        MetadataFIGXML.files.(char(vecFields(i))).exec_dim_z = num2str(MetadataFIGXML.files.(char(vecFields(i))).exec_dim_z);
        MetadataFIGXML.files.(char(vecFields(i))).exec_channels = num2str(MetadataFIGXML.files.(char(vecFields(i))).exec_channels);
        MetadataFIGXML.files.(char(vecFields(i))).exec_num_timepoints = num2str(MetadataFIGXML.files.(char(vecFields(i))).exec_num_timepoints);

        arrFiles(i,:) = struct2cell(MetadataFIGXML.files.(char(vecFields(i))));

    end

    %First time load, skip location path (1)
    stgObj.AddSetting('Main','data',arrFiles(:,2:end));

end

