function [Ilabels , Clabels , ColIms] = SegmentStack(Stack, params,Ilabels,Clabels,ColIms, frs)
% SegmentStack segments images extracting the cell outlines
%
% IN: 
%   Stack - 
%   params - 
%   Ilabels - 
%   Clabels -
%   ColIms - 
%   frs - 
%
% OUT: 
%   Ilabels - 
%   Clabels - 
%   ColIms - 
%
% Author:
% Copyright:

% frs is an optional parameter allowing the user to decide which frames to
% segment

ImSize = size(Stack);

% check for single frame
if numel(ImSize) == 2
    SingleFrame = true;
    NFrames = 1;
else
    SingleFrame = false;
    NFrames = ImSize(3);
end

if nargin < 4                                                              % growing from previous labels
    frs = 1:NFrames;
    Clabels = zeros(ImSize, 'uint16');
    ColIms = zeros([ImSize(1),ImSize(2),3,NFrames]);
else
    fprintf('regrowing frames:');
end

if nargin < 3                                                              % not using previous labels
    Ilabels = zeros(ImSize,'uint8');
    NoPreviousLabels = true;
else
    NoPreviousLabels = false;
end

if params.Parallel           % parallelise if we can!
    % should change from s(3) to frs but the integers in frs might not be
    % consective so it fails. Perhaps check if splitting would be an option
    
    ppm = ParforProgressStarter2('Segmentation running',...
                                     NFrames,...
                                     0.1,...
                                     0,...
                                     0,...
                                     1);
    
    parfor i = 1:NFrames
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev(sprintf('Processing frame (P) %i',i), 'DEBUG');
        % -------------------------------------------------------------------------
        im = double(Stack(:,:,i));
        if NoPreviousLabels
            [Ilabel ,Clabel,ColIm] = SegmentIm(im,params);
        else
            [Ilabel ,Clabel,ColIm] = SegmentIm(im,params,Ilabels(:,:,i));
        end
        Ilabels(:,:,i) = Ilabel;
        Clabels(:,:,i) = Clabel;
        ColIms(:,:,:,i) = ColIm;
        
        ppm.increment(i)
        
    end
    
    delete(ppm)
else
    progressbar('Segmenting images... (please wait)');
    for t=1:length(frs)
        
        i = frs(t);
        
        % -------------------------------------------------------------------------
        % Log current application status
        log2dev(sprintf('Processing frame (P) %i',i), 'DEBUG');
        % -------------------------------------------------------------------------
        
        im = double(Stack(:,:,i));

        if NoPreviousLabels
            [Ilabel ,Clabel,ColIm] = SegmentIm(im,params);
        else
            [Ilabel ,Clabel,ColIm] = SegmentIm(im,params,Ilabels(:,:,i));
        end
        Ilabels(:,:,i) = Ilabel;
        Clabels(:,:,i) = Clabel;
        ColIms(:,:,:,i) = ColIm;
        progressbar(t/length(frs));
    end
    progressbar(1);
end