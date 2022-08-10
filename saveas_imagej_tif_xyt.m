function saveas_imagej_tif_xyt(im_series, save_dir, filename, bit_depth)
%
% function saveas_imagej_tif_xyt(im_series, save_dir, filename, bit_depth)
%
% DESCRIPTION
% This function saves a 3D XYT image series as a TIFF file with the
% appropriate associated ImageJ/FIJI-compatible metadata.
%
% ARGUMENTS
% im_series: 3D array that represents an XYT image series
%
% save_dir: Folder where the TIFF will be saved
%
% filename: Name of the TIFF file
%
% bit_depth: Number of bits per pixel
%
%
% OPTIONS
% none
%
%
% OUTPUT
% ImageJ/FIJI-compatible XYT TIFF file saved to specified folder.
%
% Author (contact): Meghan Turner (meghanaturner1@gmail.com)
% Created: 08/06/2022
% Last Updated: 
%

%% Set variables
% set default bit depth for image, if not specified by user    
if nargin < 4
    bit_depth = 16; 
end

%% Make a new Tiff object
tiff_obj = Tiff([save_dir, filename],'w');

% Generate a FIJI file description based on image stack features
fiji_descr = ['ImageJ=1.53f', newline, ...
              'images=', num2str(size(im_series,3)), newline,...
              'slices=', num2str(1), newline,...
              'channels=', num2str(1), newline,...
              'frames=' num2str(size(im_series,3)), newline...
              'loop=false', newline,...  
              'min=0.0', newline,...      
              'max=', num2str(max(im_series(:)))];
%               'hyperstack=true' newline,...
%               'mode=grayscale'


            

% Add the ImageJ/FIJI metadats to the Tiff tag structure
tagstruct.ImageDescription = fiji_descr;
% 7 other mandatory tags per the Tiff class documentation:
tagstruct.ImageLength = size(im_series,1);
tagstruct.ImageWidth = size(im_series,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = bit_depth;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = Tiff.Compression.LZW; % DO NOT use None - it circularly permutes the pixels in xy space
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
% optional tag:
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;


%% Now write the image stack to the new Tiff object
for slice = 1:size(im_series,3)
    tiff_obj.setTag(tagstruct)
    tiff_obj.write(uint16(im_series(:,:,slice)));
    tiff_obj.writeDirectory(); % saves a new page in the tiff file
end
tiff_obj.close()