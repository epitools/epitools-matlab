function [status, argout] = RetrieveData2Load(varargin)
%RETRIEVEDATA2LOAD Retrieve data to be passed to the calling function
% ------------------------------------------------------------------------------
% PREAMBLE
%
% This function load data structures required by the calling function. It
% checks the active pool, it looks for the required tag in the pool and it
% load the linked file. 
%
% INPUT 
%   1. input_args:  variable containing the analysis object
%   2. varargin:    variable containing extra parameters for ref association 
%                   during output formatting (might not be implemented)
%
% OUTPUT
%   1. status:  status elaboration (0  executed correctly; > 0 fatal error)
%   2. argout:  variable containing a structure with output objects, description 
%               and ref association
%
% REFERENCES
%
% AUTHOR:   Lorenzo Gatti (lorenzo.gatti@alumni.ethz.ch)
%
% DATE:     26.02.15 V0.1 for EpiTools 2.0 beta
% 
% LICENCE:
% License to use and modify this code is granted freely without warranty to all, as long as the 
% original author is referenced and attributed as such. The original author maintains the right 
% to be solely associated with this work.
% 
% Copyright by A. Tournier, A. Hoppe, D. Heller, L. Gatti
% ------------------------------------------------------------------------------
%% Procedure
status = 0;
argout = [];
% Get pool reference and open active pool on graphic tag passed on module dependence
% Get pool handles
pool_instances = getappdata(getappdata(0, 'hMainGui'), 'pool_instances');
% Elaboration
% Storing execution variables into memory and retrieve tag from pool
for idxTag = 1:numel(varargin{:})
    for idxPool = 2:size(pool_instances,2)
        % if pool is not active, skip it and move to the next
        if (~pool_instances(idxPool).ref.active); continue; end
        % Check if the parsed tag is found in the pool, otherwise skip to
        % the next one
        if ~pool_instances(idxPool).ref.existsTag(varargin{:}{idxTag}); break; end
        % Retrieve tag description from pool
        o = pool_instances(idxPool).ref.getTag(varargin{:}{idxTag});
        % if the tag is of class data or graphic, then explore the inner
        % structure
        if (strcmp(o.class,'data') || strcmp(o.class,'graphics'))
            switch o.attributes.attribute.class
                case 'variable'
                    argout = makeStack();
                case 'file'
                % If mat, then check content and select for integer matrix
                if regexp(o.attributes.attribute.path, '.mat')>0
                    s = load(o.attributes.attribute.path);
                    s_fields = fieldnames(s);
                    for idxFields = 1:numel(s_fields)
                        argout = s.(char(s_fields(idxFields))); 
                    end
                end
            end
        end
        
    end
end
status = 1;
end

function Data = makeStack()
stgObj = getappdata(getappdata(0, 'hMainGui'), 'settings_objectname');
Indices     = stgObj.analysis_modules.Indexing.results.indices;
SourceData  = stgObj.analysis_modules.Main.data;
SourcePath  = stgObj.data_imagepath;
% Status operations
minv = 0; maxv=numel(Indices.I)+1; value=1;
log2dev('Preparing image files to load...','INFO',0,'hMainGui', 'statusbar',{minv,maxv,value});
% Initialize global time variable
global_time_index = 0;
% Variable indicating the number of processed files
intProcessedFiles = 0;
% For each file selected to be loaded
for idxFiles=1:numel(Indices.I)
    % Retrieve the current IMG ID from the list
    intCurImgIdx = Indices.I(idxFiles);
    % Retrieve the current IMG absolute path
    strCurFileName = char(SourceData(intCurImgIdx,1));
    strFullPathFile = [SourcePath,'/',strCurFileName];
    % -------------------------------------------------------------------------
    % Log status of current application status
    % log2dev(sprintf('Currently merging %s',strCurFileName), 'INFO');
    % -------------------------------------------------------------------------
    % If the first file is being processed, then initialize variables
    % Data
    if(intProcessedFiles == 0)
        x = cell2mat(SourceData(intCurImgIdx,3));
        y = cell2mat(SourceData(intCurImgIdx,2));
        %if isa(Indices.Z,'cell')
        z = max(cellfun(@max,Indices.Z));
        %else
            %z = max(arrayfun(@max,Indices.Z));
        %end
        %if isa(Indices.T,'cell')
        t = sum(cellfun(@numel,Indices.T));
        %else
            %t = sum(arrayfun(@numel,Indices.T));
        %end
        intclass = char(SourceData(intCurImgIdx,7));
        Data = zeros(x,y,z,t,intclass);
    end
    % Load Data considering the specifics passed by stgObj.analysis_modules.Main.indices
    % Warning: the dimensions of ImagesPreStack are given by the number
    % of planes in output from LoadImgData. If channels num is 1, then
    % dim = 4
    [~,rawdata] = LoadImgData(strFullPathFile,intCurImgIdx,Indices);
    % Project data
    for local_time_index = 1:length(Indices.T{intCurImgIdx})
        ImStack = rawdata(:,:,:,Indices.T{intCurImgIdx}(local_time_index));
        Data(:,:,:,local_time_index+global_time_index) = ImStack;
    end
    global_time_index=global_time_index+length(Indices.T{intCurImgIdx});
    intProcessedFiles = intProcessedFiles+1;
    log2dev(sprintf('Preparing image files to load: %s',strCurFileName),'INFO',0,'hMainGui', 'statusbar',{minv,maxv,intProcessedFiles+1});
end
end


