function [polygonal_mask, cropped_CellLabelIm] = PolygonCrop(imStack, CellLabelIm, polygonal_mask)
%POLYGONCROP provides an interactive polygon crop to reduce the segmented
%area of the image in case of extended wrong signal. Aim is to preserve the
%cell geometry and include all cells touched by the selection.
%
%IN:
%   imStack     - image stack on which to draw the polygonal mask
%   CellLabelIm - image stack which contains the cell labels to crop
%   polygonal_mask - (optional) pre-existent mask to use for cropping
%
% OUT:
%   polygonal_mask - mask used for cropping the cell labels
%   cropped_CellLabelIm -> cropped cell lables (i.e. within the mask)
%
%source:
%- original code snipped by Alexandre Tournier
%- http://www.mathworks.com/matlabcentral/answers/99870-how-can-i-extract-a-portion-of-an-image-specified-by-mask-generated-from-a-roi-in-image-processing-t

%Check if a pre-existent mask was supplied
if nargin < 3
    %% Creating the mask for the first time
    %Show the first time point and wait for the user to insert the polygon
    %mask. This can be done by clicking on the image and confirming at the
    %end with a right click on the mask -> create Mask
    try
        fig = figure('name','Draw polygon and confirm by rightclick->create mask');
        imshow(imStack(:,:,1),[]);
        polygonal_mask = roipoly;
        close(fig);
    catch
        %user closed the figure without completing the procedure
        polygonal_mask = 0;
        cropped_CellLabelIm = 0;
        return
    end
end

%% Produce the cropped image stack
cropped_CellLabelIm = zeros(size(CellLabelIm));
frame_no = size(CellLabelIm,3);

%apply the mask frame by frame
for f = 1 : frame_no
    
    %set everything in the outer region to 0
    ROI = CellLabelIm(:,:,f);
    ROI(polygonal_mask == 0) = 0;
    
    %find which cells labels have not been set to 0
    cell_labels_to_keep = unique(ROI);
    
    %apply the selection of Id's
    cropped_frame = CellLabelIm(:,:,f);
    cell_labels_to_discard = ~ismember(cropped_frame,cell_labels_to_keep);
    cropped_frame(cell_labels_to_discard) = 0;
    
    %insert the cropped frame in the final stack
    cropped_CellLabelIm(:,:,f) = cropped_frame;
end

end

