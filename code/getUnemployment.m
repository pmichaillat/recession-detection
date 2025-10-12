% getUnemployment - Load and splice historical US unemployment rate data
%
% Syntax:
%   u = getUnemployment(inputFolder, beginDate, endDate)
%
% Description:
% This function loads unemployment rate data from two sources (1890-1947 and 1948-present), splices them into a continuous series, and returns the requested date range.
%
% Input arguments:
% * inputFolder - string or char, path to folder containing data files
% * beginDate   - numeric, start date in decimal year format (e.g., 1890.0 for Jan 1890)
% * endDate     - numeric, end date in decimal year format (e.g., 1890.917 for Dec 1890)
%
% Output arguments:
% * u - column vector, unemployment rates (as decimals, not percentages)
%
% Data files required:
% * HistoricalSeries_JME_2020January.csv: Historical unemployment data (1890-1947)
% * UNEMPLOY.csv: Unemployment level from FRED (1948-present)
% * CLF16OV.csv: Civilian labor force level from FRED (1948-present)
%
% Notes:
% * Historical data (1890-1947) are read as rates and converted from percentages.
% * Modern data (1948-present) are computed as unemployment level / labor force.
%
% Example:
%   u = getUnemployment('./data', 1920.0, 1930.0);

function u = getUnemployment(inputFolder, beginDate, endDate)

%% Get unemployment rate for 1890M1–1947M12
% Read historical unemployment rates from JME 2020 data file
% Data are in percentage form, so divide by 100
uRate1890 = readmatrix(fullfile(inputFolder, 'HistoricalSeries_JME_2020January.csv'), 'Range', 'B6:B701')./100;

%% Get unemployment rate since 1948M1
% Read unemployment level (number of unemployed persons)
uLevel1948 = readmatrix(fullfile(inputFolder, 'UNEMPLOY.csv'), 'Range', 'B2');

% Read monthly labor-force level (total civilian labor force)
laborforce = readmatrix(fullfile(inputFolder, 'CLF16OV.csv'), 'Range', 'B2');

% Compute unemployment rate as ratio of unemployed to labor force
uRate1948 = uLevel1948 ./ laborforce;

%% Splice two series into a long series
% Concatenate historical and modern data into single time series
uLong = [uRate1890; uRate1948];

%% Create date vector for entire series
% Read dates from labor force file to determine end date
dateArray = table2array(readtable(fullfile(inputFolder, 'CLF16OV.csv'), 'Range', 'A:A'));

% Calculate end date in decimal year format
dateEnd = max(year(dateArray) + (month(dateArray) - 1) ./ 12); 

% Create monthly date vector from 1890M1 to present in decimal years
% (e.g., 1890.0 = Jan 1890, 1890.083 = Feb 1890, etc.)
dateMat = round([1890 : 1/12 : dateEnd], 2);

%% Return subset of data
% Extract and return requested date range
u = uLong(dateMat >= beginDate & dateMat <= endDate);

end