function [result] = ReadOMEMetadata(id)
autoloadBioFormats = 1;
% load the Bio-Formats library into the MATLAB environment
status = bfCheckJavaPath(autoloadBioFormats);
assert(status, ['Missing Bio-Formats library. Either add loci_tools.jar '...
    'to the static Java path or add it to the Matlab path.']);

% initialize logging
loci.common.DebugTools.enableLogging('OFF');

r = bfGetReader(id);

metadata = r.getMetadataStore();
PixelType = metadata.getPixelsType(0).getValue().toCharArray()';


result.NX = r.getSizeX();
result.NY = r.getSizeY();
result.NZ = r.getSizeZ();
result.NC = r.getSizeC();
result.NT = r.getSizeT();
result.PixelType = PixelType;


end

