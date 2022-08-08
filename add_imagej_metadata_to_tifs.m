function add_imagej_metadata_to_tifs(preproc_data_folder, experiment_prefix)
%
% function add_imagej_metadata_to_tifs(preproc_data_folder, experiment_prefix)
%
% DESCRIPTION
% This function generates new versions of the PreProcessedData tiff stacks
% which will have FIJI-specific metadata associated with them. This change 
% makes the tiffs more widely compatible with things such as 
% Python's tifffile package, which expects to find FIJI metadata.
%
% ARGUMENTS
% preproc_data_folder: Path to your PreProcessedData folder
% experiment_prefix: Prefix for the specific dataset
%
% OPTIONS
% none
%
% OUTPUT
% Replaces all PreProcessedData tiffs with identical tiffs that now have
% FIJI metadata associated with them
%
% Author (contact): Meghan Turner (meghanaturner1@gmail.com)
% Created: 04/19/2022
% Last Updated: 08/06/2022

%%
% Set defaults
bit_depth = 16; %we take most of our data at 16 bit depth

curr_dir = [preproc_data_folder, filesep, experiment_prefix];
all_tifs = dir([curr_dir, filesep, '*_ch0*tif']);

% Re-save all PreProcessed TIF files in folder
wbar = waitbar(0, ['Adding ImageJ metadata to ' experiment_prefix ' PreProc tiffs']);
for i = 1:length(all_tifs)
    waitbar(i/length(all_tifs), wbar);

    tifffile_name = all_tifs(i).name;
    % custom function for older MATLAB versions:
    curr_tif = read_tiff_stack([curr_dir, filesep, tifffile_name]); 
%     % Newer versions of MATLAB have a built-in function to read 3D tiffs:
%     curr_tif = tiffreadVolume([curr_dir, filesep, tifffile_name]);
    im_stack = curr_tif;
    
    % Save as a Tiff object with FIJI metadata included
    saveas_imagej_tif_xyz(im_stack, curr_dir, tifffile_name, bit_depth)
    
end
close(wbar)
disp('Done!')