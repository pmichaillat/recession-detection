% getNber - Load NBER recession dates and return relevant subset
%
% Syntax:
%   [startNber, endNber] = getNber(inputFolder, beginDate, endDate)
%
% Description:
% This functio reads NBER business cycle peak and trough dates, converts them to recession start and end dates, and returns those with start dates within the requested range.
%
% Input arguments:
% * inputFolder - string or char, path to folder containing data files
% * beginDate   - numeric, start date in decimal year format (e.g., 1920.0 for Jan 1920)
% * endDate     - numeric, end date in decimal year format (e.g., 1930.917 for Dec 1930)
%
% Output arguments:
% * startNber - column vector, recession start dates in decimal year format
% * endNber   - column vector, recession end dates in decimal year format
%
% Data files required:
% * 20210719_cycle_dates_pasted.csv: NBER business cycle peak and trough dates
%
% Notes:
% * Recession starts are defined as one month after the business cycle peak.
% * Recession ends are defined as the business cycle trough month.
% * Only recessions with start dates within the requested range are returned.
%
% Example:
%   [starts, ends] = getNber('./data', 1920.0, 1930.0);

function [startNber, endNber] = getNber(inputFolder, beginDate, endDate)

%% Read dates for cycle peaks and troughs
% Read peak dates (column A) from NBER cycle dates file
peakArray = table2array(readtable(fullfile(inputFolder, '20210719_cycle_dates_pasted.csv'), 'Range', 'A3:A36'));

% Read trough dates (column B) from NBER cycle dates file
troughArray = table2array(readtable(fullfile(inputFolder, '20210719_cycle_dates_pasted.csv'), 'Range', 'B3:B36'));

%% Translate cycle peaks and troughs into recession starts and ends
% Recession starts one month after peak
startArray = peakArray + calmonths(1);

% Recession ends at trough
endArray = troughArray;

%% Translate dates into decimal year format
startMat = year(startArray) + (month(startArray) - 1) ./ 12; 
endMat = year(endArray) + (month(endArray) - 1) ./ 12;

%% Return subset of data
% Filter for recessions with start dates within requested range
recessionIndex = startMat >= beginDate & startMat <= endDate;
startNber = startMat(recessionIndex);
endNber = endMat(recessionIndex);

end