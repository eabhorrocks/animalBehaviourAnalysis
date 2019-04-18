function [trialID,trialDuration,dotSize,dotCol1,dotCol2,numDots1,numDots2,dotLifeBool,dotLifetime,contrast1,velXLeft,velYLeft,cohLeft,velXRight,velYRight,cohRight,response,paramTimes] = importParamsFile(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [TRIALID,TRIALDURATION,DOTSIZE,DOTCOL1,DOTCOL2,NUMDOTS1,NUMDOTS2,DOTLIFEBOOL,DOTLIFETIME,CONTRAST1,VELXLEFT,VELYLEFT,COHLEFT,VELXRIGHT,VELYRIGHT,COHRIGHT,RESPONSE,PARAMTIMES]
%   = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   [TRIALID,TRIALDURATION,DOTSIZE,DOTCOL1,DOTCOL2,NUMDOTS1,NUMDOTS2,DOTLIFEBOOL,DOTLIFETIME,CONTRAST1,VELXLEFT,VELYLEFT,COHLEFT,VELXRIGHT,VELYRIGHT,COHRIGHT,RESPONSE,PARAMTIMES]
%   = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [trialID,trialDuration,dotSize,dotCol1,dotCol2,numDots1,numDots2,dotLifeBool,dotLifetime,contrast1,velXLeft,velYLeft,cohLeft,velXRight,velYRight,cohRight,response,paramTimes] = importfile('TrialParams2019-04-16T18_48_07.csv',1, 237);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2019/04/17 15:17:28

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end

% Convert the contents of columns with dates to MATLAB datetimes using the
% specified date format.
try
    dates{18} = datetime(dataArray{18}, 'Format', 'HH:mm:ss.SSSSSSS', 'InputFormat', 'HH:mm:ss.SSSSSSS');
catch
    try
        % Handle dates surrounded by quotes
        dataArray{18} = cellfun(@(x) x(2:end-1), dataArray{18}, 'UniformOutput', false);
        dates{18} = datetime(dataArray{18}, 'Format', 'HH:mm:ss.SSSSSSS', 'InputFormat', 'HH:mm:ss.SSSSSSS');
    catch
        dates{18} = repmat(datetime([NaN NaN NaN]), size(dataArray{18}));
    end
end

dates = dates(:,18);

%% Split data into numeric and string columns.
rawNumericColumns = raw(:, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
trialID = cell2mat(rawNumericColumns(:, 1));
trialDuration = cell2mat(rawNumericColumns(:, 2));
dotSize = cell2mat(rawNumericColumns(:, 3));
dotCol1 = cell2mat(rawNumericColumns(:, 4));
dotCol2 = cell2mat(rawNumericColumns(:, 5));
numDots1 = cell2mat(rawNumericColumns(:, 6));
numDots2 = cell2mat(rawNumericColumns(:, 7));
dotLifeBool = cell2mat(rawNumericColumns(:, 8));
dotLifetime = cell2mat(rawNumericColumns(:, 9));
contrast1 = cell2mat(rawNumericColumns(:, 10));
velXLeft = cell2mat(rawNumericColumns(:, 11));
velYLeft = cell2mat(rawNumericColumns(:, 12));
cohLeft = cell2mat(rawNumericColumns(:, 13));
velXRight = cell2mat(rawNumericColumns(:, 14));
velYRight = cell2mat(rawNumericColumns(:, 15));
cohRight = cell2mat(rawNumericColumns(:, 16));
response = cell2mat(rawNumericColumns(:, 17));
paramTimes = dates{:, 1};

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% paramTimes=datenum(paramTimes);


