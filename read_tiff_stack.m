function tiff3DArray = read_tiff_stack_parfor(tiffStackPath)
%
% function tiff3DArray = read_tiff_stack(tiffStackPath)
%
% DESCRIPTION
% This function reads in a multi-page (i.e. 3D) TIFF stack (which is the 
% current file format for the mRNADynamics pipeline) and outputs it 
% as a 3D uint16 array, which is an easier format to use for image
% processing and analysis. Note, this is 10x faster than the BioFormats
% bfOpen3DVolume function.
%
% INPUT ARGUMENTS
% tiffStackPath: full path to a single 3D TIFF stack
% 
% OPTIONS
% N/A
%
% OUTPUT
% tiff3DArray: 3D (xyz) array containing the image from the TIFF stack
%
% Author (contact): Meghan Turner (meghan_turner@berkeley.edu)
% Created: 08/12/2020
% Last Updated: N/A
%

%% Get TIFF
if ~exist(tiffStackPath,'file')
    error(['Cannot find file: ' tiffStackPath])
elseif ~(contains(tiffStackPath,'tif','IgnoreCase',true) || ...
            contains(tiffStackPath,'tiff','IgnoreCase',true))
    error('Input argument tiffStackPath must point to a TIF or TIFF file')
else
    imInfo = imfinfo(tiffStackPath);
end

%% Read in each z slice individually 
% Strangely, it's faster to save to a cell structure and then convert to a
% matrix, than it is to just save straight to a matrix
% The parfor loop saves some time, but not a lot
zDim = numel(imInfo);
im3DCellArray = cell(zDim,1);
parfor i = 1:zDim
    currZSlice = imread(tiffStackPath,i);
    im3DCellArray{i} = currZSlice;
end

% Convert to matrix
xDim = imInfo(1).Width;
yDim = imInfo(1).Height;
im3DMat = NaN(xDim,yDim,zDim);
for i = 1:size(im3DCellArray,1)
    im3DMat(:,:,i) = im3DCellArray{i};
end

% Cast back to uint16 (changed to double in the process of adding to array)
tiff3DArray = uint16(im3DMat);


