function saveas_imagej_tif_xyz(im_stack, save_dir, filename, bit_depth)
%
% saveas_imagej_tif_xyz(im_stack, save_dir, filename, bit_depth)
%
% DESCRIPTION
% This function saves a 3D XYZ image stack as a TIFF file with the
% appropriate associated ImageJ/FIJI-compatible metadata.
%
% ARGUMENTS
% im_series: 3D array that represents an XYZ image stack
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
% ImageJ/FIJI-compatible XYZ TIFF file saved to specified folder.
%
%
% Author (contact): Meghan Turner (meghanaturner1@gmail.com)
% Created: 08/06/2022
% Last Updated: 
%

%% Set variables
%set default bit depth for image, if not specified by user    
if nargin < 4
    bit_depth = 16; 
end

%% Make a new Tiff object
tiff_obj = Tiff([save_dir, filesep, filename],'w');

% Generate a FIJI file description based on image stack features
fiji_descr = ['ImageJ=1.52u', newline, ...
              'images=', num2str(size(im_stack,3)), newline,... 
              'slices=', num2str(size(im_stack,3)), newline,...
              'loop=false', newline,...  
              'min=0.0', newline,...      
              'max=', num2str(max(im_stack(:)))];
%               'channels=', '1', newline,...
%               'frames=', '1', newline,...
%               'hyperstack=true', newline...
%               'mode=grayscale'


% Add the ImageJ/FIJI metadats to the Tiff tag structure
tagstruct.ImageDescription = fiji_descr;
% 7 other mandatory tags per the Tiff class documentation:
tagstruct.ImageLength = size(im_stack,1);
tagstruct.ImageWidth = size(im_stack,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = bit_depth;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = Tiff.Compression.LZW; % DO NOT use None - it circularly permutes the pixels in xy space
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
% optional tag:
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;


%% Now write the image stack to the new Tiff object
for slice = 1:size(im_stack,3)
    tiff_obj.setTag(tagstruct)
    tiff_obj.write(uint16(im_stack(:,:,slice)));
    tiff_obj.writeDirectory(); % saves a new page in the tiff file
end
tiff_obj.close()
    