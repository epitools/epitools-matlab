function out = LoadEpiTools()
%SetWorkingDirectory Tells Matlab where to find EpiTools

%obtain absolute location on system
current_script_path = mfilename('fullpath');
[file_path,~,~] = fileparts(current_script_path);

%define current working directory!
cd(file_path)

contents = dir();

for i=1:numel(contents)
    
    % Avoid considering file in the current directory
    if (contents(i).isdir ~= 1);continue;end
    
    if (strfind(contents(i).name,'src_'))
        % Add path and subfolders
        addpath(genpath([file_path,'/',contents(i).name]));
        
        submodules = strsplit(genpath([file_path,'/',contents(i).name]),':');
        for o=1:numel(submodules)
            if(isempty(submodules{o}));continue;end
            fprintf('Successfully loaded module: %s\n', submodules{o});
        end
        
    end
    
end


if ~ispc
    % WARN: The following two commands do not work under win systems
    system(['touch ', strcat(prefdir, '/javaclasspath.txt')]);
    system(['echo  "', [file_path,'/src_support/module_progressbars/'] ,'" > ', prefdir, '/javaclasspath.txt']);
else
    % WARN: The following two commands work only under win systems
    system(['echo $null >> ', strcat(prefdir, '/javaclasspath.txt')]);
    system(['echo  "', [file_path,'/src_support/module_progressbars/'] ,'" >> ', prefdir, '/javaclasspath.txt']);
end


javaaddpath([file_path,'/src_tools/OME_LOCI_TOOLS/bioformats_package.jar']);

out = sprintf('Successfully loaded EpiTool functions from: %s\n',fileparts(file_path));

end

