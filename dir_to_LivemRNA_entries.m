function [data_folder_paths, prefix_names, ...
          prefix_name_strings, ...
          prefix_datastatus_strings] = ...
                            dir_to_LivemRNA_entries(raw_data_path, dates)

% function [data_folder_paths, prefix_names, prefix_name_strings,...
%           prefix_datastatus_strings] = ...
%                            dir_to_LivemRNA_entries(raw_data_path, date)
%
% DESCRIPTION
% This function interfaces with the directory structure expected by the
% Garcia Lab's LivemRNA pipeline. It takes a dated experiment directory and
% returns the prefixes in multiple string formats
%
%
% INPUT ARGUMENTS
% raw_data_path: RawDynamicsData path 
%                e.g. 'X:\ProjectName\Data\RawDynamicsData\'
%
% dates: Single date passed as a char array, or multiple dates passed as 
%        strings stored in a cell array. Specifies the subfolders to
%        collect prefixes from.
%
%
% OPTIONS
% None
%
%
% OUTPUT
% data_folder_paths: experiment name formatted for the DataFolder column of
%                    MovieDatabase.csv
%                    e.g. YYYY-MM-DD\this-prefix-name
%
% prefix_names: data_folder_paths with the '\' replaced to generate the
%               "prefix" expected by the LivemRNA code
%               e.g. YYYY-MM-DD-this-prefix-name
%
% prefix_name_strings: prefix_names in single apostrophes
%                      e.g. 'YYYY-MM-DD-this-prefix-name'
%
% prefix_datastatus_strings: prefixes in the specific string format 
%                            expected by "Prefix" row in DataStatus.csv
%                            e.g. 'Prefix = 'YYYY-MM-DD-this-prefix-name'
% 
% In command window: Prints out all prefixes in each of the formats above
%                    for easy copy+paste into relevant LivemRNA CSV files
%
%
% Author (contact): Meghan Turner (meghanaturner1@gmail.com)
% Created: 02/18/2021
% Last Updated: 07/25/2022

%% Process user inputs
% handle all possible 'dates' data types 
if isa(dates, 'char')
    dates = {dates};
elseif isa(dates,'cell')
    % date is likely fine as is, do nothing
else
    error('The input argument ''date'' must be either a single date passed as a char, or multiple dates passed as a cell array.')
end

%% Grab all experiment sub folders for the given dates
raw_data_names = {};
raw_data_dates = {};
for d = 1:length(dates)
    curr_raw_data_dir = dir([raw_data_path, filesep, dates{d}]);
    for f = 1:length(curr_raw_data_dir)
        % clean-up, only grab real subfolders not files
        if curr_raw_data_dir(f).isdir && ~contains(curr_raw_data_dir(f).name, '.')
           raw_data_names = [raw_data_names, curr_raw_data_dir(f).name]; %#ok<AGROW> 
           raw_data_dates = [raw_data_dates, dates{d}]; %#ok<AGROW> 
        end
    end
end

%% Generate file paths, prefixes and prefix MATLAB strings for all datasets
data_folder_paths = cell(length(raw_data_names), 1);
prefix_names = cell(length(raw_data_names), 1);
prefix_name_strings = cell(length(raw_data_names), 1);
prefix_datastatus_strings = cell(length(raw_data_names), 1);
for i = 1:length(raw_data_names)
    exp_name = raw_data_names{i};

    file_path_name = [raw_data_dates{i}, '\', exp_name];
    data_folder_paths(i) = {file_path_name};
    prefix_name = [raw_data_dates{i}, '-', exp_name];
    prefix_names(i) = {prefix_name};
    prefix_name_strings(i) = {['''', prefix_name, '''']};
    prefix_datastatus_strings(i) = {['''Prefix = ''', prefix_name, '''']};
end

%% Print to command window 
% so user can copy and paste into MovieDatabase, DataStatus, etc.
disp('File paths:')
fprintf('%s\n', data_folder_paths{:})
disp('Prefixes:')
fprintf('%s\n', prefix_names{:})
disp('Prefixes as strings:')
fprintf('%s\n', prefix_name_strings{:})
disp('Prefixes as DataStatus prefix entries:')
fprintf('%s\n', prefix_datastatus_strings{:})

% Also returns all prefix formats as variables