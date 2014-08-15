function [] = CheckInputType(ds, input_string)
%CHECKINPUTTYPE checks the type of the input object

    loaded_image = load([ds.data_analysisdir,'/',input_string]);
    
    if isa(loaded_image,'struct')
        fields = fieldnames(loaded_image);
        for i = 1:numel(fields)
            field_name = fields{i};
            fprintf('>>>>>>>>>> %s is of type %s\n',field_name,class(loaded_image.(field_name)));
        end
    else
        fprintf('>>>>>>>>>> %s is of type %s\n',input_string,class(loaded_image.(input_string)));
        
    end
    
    clearvars loaded_image;
    
end

