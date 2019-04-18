%% Import data from text file.
% Script for importing data from the following text file:
%
%    C:\Users\edward.horrocks\Documents\GitHub\MouseBehaviourAnalysis\160419\Events2019-04-16T18_48_07.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2019/04/17 15:07:12

%% Initialize variables.
filename = 'C:\Users\edward.horrocks\Documents\GitHub\MouseBehaviourAnalysis\160419\Events2019-04-16T18_48_07.csv';
delimiter = ',';

%% Format for each line of text:
%   column1: text (%s)
%	column2: datetimes (%{HH:mm:ss.SSSSSSS}D)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%{HH:mm:ss.SSSSSSS}D%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
eventNames = dataArray{:, 1};
eventTimes = dataArray{:, 2};

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% eventTimes=datenum(eventTimes);


%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;