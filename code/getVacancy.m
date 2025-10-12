% getVacancy - Load and splice historical US vacancy rate data
%
% Syntax:
%   v = getVacancy(inputFolder, beginDate, endDate)
%
% Description:
% This function loads vacancy rate data from three sources (1919-1950, 1951-2000, and 2001-present), splices them into a continuous series, and returns the requested date range.
%
% Input arguments:
% * inputFolder - string or char, path to folder containing data files
% * beginDate   - numeric, start date in decimal year format (e.g., 1919.0 for Jan 1919)
% * endDate     - numeric, end date in decimal year format (e.g., 1919.917 for Dec 1919)
%
% Output arguments:
% * v - column vector, vacancy rates (as decimals, not percentages)
%
% Data files required:
% * HistoricalSeries_JME_2020January.csv: Historical vacancy data (1919-1950)
% * CompositeHWI.xlsx - Sheet1.csv: Composite Help Wanted Index data (1951-2000)
% * JTSJOL.csv: Job openings level from FRED (2001-present)
% * CLF16OV.csv: Civilian labor force level from FRED (2001-present)
%
% Notes:
% * Historical data (1919-1950 and 1951-2000) are read as rates and converted from percentages.
% * Modern data (2001-present) are computed as vacancy level / labor force.
%
% Example:
%   v = getVacancy('./data', 1920.0, 1930.0);

function v = getVacancy(inputFolder, beginDate, endDate)

%% Get vacancy rate for 1919M1–1950M12
% Read historical vacancy rates from JME 2020 data file
% Data are in percentage form, so divide by 100
vRate1919 = readmatrix(fullfile(inputFolder, 'HistoricalSeries_JME_2020January.csv'), 'Range', 'D354:D737')./100;

%% Get vacancy rate for 1951M1–2000M12
% Read vacancy rates from Composite Help Wanted Index
% Data are in percentage form, so divide by 100
vRate1951 = readmatrix(fullfile(inputFolder, 'CompositeHWI.xlsx - Sheet1.csv'), 'Range', 'C9:C608')./100;

%% Get vacancy rate since 2001M1
% Read vacancy level (number of job openings)
vLevel2001 = readmatrix(fullfile(inputFolder, 'JTSJOL.csv'), 'Range', 'B2');

% Read labor-force level (total civilian labor force)
laborforce = readmatrix(fullfile(inputFolder, 'CLF16OV.csv'), 'Range', 'B638');

% Compute vacancy rate as ratio of vacancies to labor force
vRate2001 = vLevel2001 ./ laborforce;

%% Splice three series into a long series
% Concatenate historical and modern data into single time series
vLong = [vRate1919; vRate1951; vRate2001];

%% Create date vector for entire series
% Read dates from labor force file to determine end date
dateArray = table2array(readtable(fullfile(inputFolder, 'CLF16OV.csv'), 'Range', 'A:A'));

% Calculate end date in decimal year format
dateEnd = max(year(dateArray) + (month(dateArray) - 1) ./ 12); 

% Create monthly date vector from 1919M1 to present in decimal years
% (e.g., 1919.0 = Jan 1919, 1919.083 = Feb 1919, etc.)
dateMat = round([1919 : 1/12 : dateEnd], 2);

%% Return subset of data
% Extract and return requested date range
v = vLong(dateMat >= beginDate & dateMat <= endDate);

end