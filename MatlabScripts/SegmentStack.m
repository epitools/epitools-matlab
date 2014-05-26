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

s = size(Stack);

if nargin <4
    frs = 1:s(3);
    Clabels = zeros(s);
    ColIms = zeros([s(1),s(2),3,s(3)]);
else
    fprintf('regrowing frames:');
    disp(frs);
end

if nargin <3        % not using previous labels
    Ilabels = zeros(s);
    NoPreviousLabels = true;
else
    NoPreviousLabels = false;
end

if params.Parallel           % parallelise if we can!
    %should change from s(3) to frs but the integers in frs might not be
    %consective so it fails. Perhaps check if splitting would be an option
    
    parfor i = 1:s(3)
        fprintf('segmenting frame (P) %i\n', i);
        im = double(Stack(:,:,i));
%         im = im/max(im(:))*255;
        if NoPreviousLabels
            [Ilabel ,Clabel,ColIm] = SegmentIm(im,params.show,params);
        else
            [Ilabel ,Clabel,ColIm] = SegmentIm(im,false,params,Ilabels(:,:,i));
        end
        Ilabels(:,:,i) = Ilabel;
        Clabels(:,:,i) = Clabel;
        ColIms(:,:,:,i) = ColIm;
    end
else
    for t=1:length(frs)
        i = frs(t);
        fprintf('segmenting frame %i\n', i);
        im = double(Stack(:,:,i));
        %commented as also in parallel version
        %im = im/max(im(:))*255;
        if NoPreviousLabels
            [Ilabel ,Clabel,ColIm] = SegmentIm(im,params.show,params);
        else
            [Ilabel ,Clabel,ColIm] = SegmentIm(im,false,params,Ilabels(:,:,i));
        end
        Ilabels(:,:,i) = Ilabel;
        Clabels(:,:,i) = Clabel;
        ColIms(:,:,:,i) = ColIm;
    end
end