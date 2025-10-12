% getIp - Load industrial production index data
%
% Syntax:
%   ip = getIp(inputFolder, beginDate, endDate)
%
% Description:
% This function loads the industrial production index from FRED and returns
% the requested date range.
%
% Input arguments:
% * inputFolder - string or char, path to folder containing data files
% * beginDate   - numeric, start date in decimal year format (e.g., 1919.0 for Jan 1919)
% * endDate     - numeric, end date in decimal year format (e.g., 1919.917 for Dec 1919)
%
% Output arguments:
% * ip - column vector, industrial production index values
%
% Data files required:
% * INDPRO.csv: Industrial production index from FRED (1919-present)
%
% Example:
%   ip = getIp('./data', 1920.0, 1930.0);

function ip = getIp(inputFolder, beginDate, endDate)

%% Get IP index since 1919M1
% Read industrial production index from FRED data file
ipLong = readmatrix(fullfile(inputFolder, 'INDPRO.csv'), 'Range', 'B2');

%% Create date vector for entire series
% Read dates from IP file to determine date range
dateArray = table2array(readtable(fullfile(inputFolder, 'INDPRO.csv'), 'Range', 'A:A'));

% Convert dates to decimal year format
dateMat = round(year(dateArray) + (month(dateArray) - 1) ./ 12, 2);

%% Return subset of data
% Extract and return requested date range
ip = ipLong(dateMat >= beginDate & dateMat <= endDate);

end
