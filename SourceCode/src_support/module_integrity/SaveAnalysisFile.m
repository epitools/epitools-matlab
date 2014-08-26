function argout = SaveAnalysisFile(hObject, handles, intForce)
hMainGui = getappdata(0, 'hMainGui');
strRootPath = getappdata(hMainGui,'settings_rootpath');
stgObj = getappdata(hMainGui,'settings_objectname');

if nargin < 3
    
    intForce = 0;
    
end


if (intForce == 1)
    
    
    tmp = struct();
    tmp.main = struct(stgObj);
    
    
    intNumRows = size(stgObj.analysis_modules.Main.data,1);
    fieldsFile = {'name';'dim_x';'dim_y';'dim_z';'num_channels';'num_timepoints';'pixel_type';'exec';'exec_dim_z';'exec_channels';'exec_num_timepoints';};
    tmpFileStruct = struct();

    for r=1:intNumRows
        
        tmpFileStruct.(strcat('file',num2str(r))) =  cell2struct(stgObj.analysis_modules.Main.data(r,:)',fieldsFile);
        
    end
    
    tmp.main.analysis_modules.Main.data = tmpFileStruct;
    if(sum(strcmp(fields(stgObj.analysis_modules.Main), 'indices')) == 1)
        tmp.main.analysis_modules.Main = rmfield(tmp.main.analysis_modules.Main,'indices');
    end
    struct2xml(tmp, strcat(stgObj.data_fullpath,'/',stgObj.analysis_name,'.',num2str(stgObj.analysis_version),'.xml'));
    argout = 1;
else
    
    
    out = questdlg('Would you like to save the current analysis?', 'Save analysis','Yes', 'No','Abort', 'Abort');
    
    switch out
        case 'Yes'
            
            tmp = struct();
            tmp.main = struct(stgObj);
            
            intNumRows = size(stgObj.analysis_modules.Main.data,1);
            fieldsFile = {'name';'dim_x';'dim_y';'dim_z';'num_channels';'num_timepoints';'pixel_type';'exec';'exec_dim_z';'exec_channels';'exec_num_timepoints';};
            tmpFileStruct = struct();

            for r=1:intNumRows

                
                tmpFileStruct.(strcat('file',num2str(r))) =  cell2struct(stgObj.analysis_modules.Main.data(r,:)',fieldsFile);
                

            end
            
            tmp.main.analysis_modules.Main.data = tmpFileStruct;
            if(sum(strcmp(fields(stgObj.analysis_modules.Main), 'indices')) == 1)
                tmp.main.analysis_modules.Main = rmfield(tmp.main.analysis_modules.Main,'indices');
            end
            struct2xml(tmp, strcat(stgObj.data_fullpath,'/',stgObj.analysis_name,'.',num2str(stgObj.analysis_version),'.xml'));
            
            argout = 0;
        case 'No'
            
            %msgbox('Changes have been discarded');
            argout = 0;
        case 'Abort'
            argout = 1;
    end
end
