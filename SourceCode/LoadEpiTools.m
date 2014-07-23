function out = LoadEpiTools()
%SetWorkingDirectory Tells Matlab where to find EpiTools

%obtain absolute location on system
current_script_path = mfilename('fullpath');
[file_path,~,~] = fileparts(current_script_path);

%define current working directory!
cd(file_path)

% set epitool script location
%addpath([fileparts(file_path),'/MatlabScripts'])
%addpath([fileparts(file_path),'/EpitoolComponents/'])
%addpath([fileparts(file_path),'/SettingsComponents/'])
%addpath([fileparts(file_path),'/DataManagingComponents/']);
%addpath([fileparts(file_path),'/matlab_imageJ_interface/']);
%javaaddpath([fileparts(file_path),'/OME_LOCI_TOOLS/loci_tools.jar'])
%addpath([fileparts(file_path),'/OME_LOCI_TOOLS'])

addpath([file_path,'/src_analysis']);
addpath([file_path,'/src_analysis/src_scripts']);
addpath([file_path,'/src_gui']);
addpath([file_path,'/src_support']);
addpath([file_path,'/src_support/module_settings']);
addpath([file_path,'/src_support/module_xml']);
addpath([file_path,'/src_support/module_logs']);
addpath([file_path,'/src_tools']);
addpath([file_path,'/src_tools/ImageJ_interface']);
%javaaddpath([file_path,'/src_tools/OME_LOCI_TOOLS/loci_tools.jar'])
%javaaddpath([file_path,'/src_tools/OME_LOCI_TOOLS/bioformats_package.jar'])
addpath([file_path,'/src_tools/OME_LOCI_TOOLS']);



out = sprintf('Successfully loaded EpiTool functions from: %s\n',fileparts(file_path));

end

