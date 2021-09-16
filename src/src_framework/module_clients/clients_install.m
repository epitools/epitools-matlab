function clients_install(zip_file)
%CLIENTS_INSTALL This function explodes a zip file containing EpiTools
%analysis modules in src_analysis

unzip(zip_file,'src_analysis')
clients_load();

end

