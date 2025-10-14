% plotData - Plot raw unemployment and vacancy data
%
% Description:
% This script plots the US unemployment and vacancy rates from April 1929 to
% August 2025 on a logarithmic scale. Recession periods are shaded in gray.
% The figure and underlying data are saved to the output folder.
%
% Requirements:
% * outputFolder - string or char, path to output folder (defined in main.m)
% * timeline - column vector, date vector in decimal year format
% * uRaw - column vector, unemployment rate (as decimals)
% * vRaw - column vector, vacancy rate (as decimals)
% * startRecession - column vector, recession start dates in decimal years
% * endRecession - column vector, recession end dates in decimal years
% * dataAxis - cell array, x-axis properties (defined in formatFigure.m)
% * purpleLine - cell array, line properties (defined in formatFigure.m)
% * orangeLine - cell array, line properties (defined in formatFigure.m)
% * grayArea - cell array, area properties (defined in formatFigure.m)
%
% Output:
% * figureData.pdf - PDF file with unemployment and vacancy rate plot
% * figureData.csv - CSV file with data underlying figure
%
% Notes:
% * Y-axis uses logarithmic scale to accommodate wide range of values
% * Unemployment rate is plotted in purple
% * Vacancy rate is plotted in orange
% * Recession periods are indicated by gray shaded regions

%% Specify figure ID
figureId = 'data';

%% Produce figure
% Set up figure window
figure('NumberTitle', 'off', 'Name', ['Figure ', figureId])
hold on

% Format x-axis
ax = gca; 
set(ax, dataAxis{:})

% Format y-axis with logarithmic scale
ax.YLim = log([0.005, 0.3]);
ax.YTick = log([0.005, 0.01, 0.02, 0.04, 0.08, 0.15, 0.3]);
ax.YTickLabel = ["0.5%"; "1%"; "2%"; "4%"; "8%"; "15%"; "30%"];
ax.YLabel.String = 'Share of labor force (log scale)';

% Shade NBER recessions
xregion(startNber, endNber, grayArea{:});

% Plot unemployment rate in purple
plot(timeline, log(uRaw), purpleLine{:})

% Plot vacancy rate in orange
plot(timeline, log(vRaw), orangeLine{:})

% Save figure as PDF
print('-dpdf', fullfile(outputFolder, ['figure_', figureId, '.pdf']))

%% Save figure data
% Define column headers
header = {'Year', 'Unemployment rate (%)', 'Vacancy rate (%)'};

% Combine data into matrix
data = [timeline, uRaw, vRaw];

% Write data to CSV file
writetable(array2table(data, 'VariableNames', header), fullfile(outputFolder, ['figure_', figureId, '.csv']))