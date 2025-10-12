% plotVIndicator - Plot vacancy indicators
%
% Description:
% This script plots all vacancy indicators constructed from the raw vacancy
% rate data. Each indicator represents a different combination of smoothing,
% curvature, and turning point detection parameters. Recession periods are
% shaded in gray.
%
% Requirements:
% * outputFolder - string or char, path to output folder (defined in main.m)
% * formatFigure.m - script to predefine figure properties (run in main.m)
% * timeline - column vector, date vector in decimal year format
% * vIndicator - matrix [nMonth x nIndicators], vacancy indicators from buildIndicator
% * startRecession - column vector, recession start dates in decimal years
% * endRecession - column vector, recession end dates in decimal years
% * dataAxis - cell array, x-axis properties (defined in formatFigure.m)
% * orangeTransparentBand - cell array, line properties (defined in formatFigure.m)
% * grayArea - cell array, area properties (defined in formatFigure.m)
%
% Output:
% * figureVIndicator.pdf - PDF file with vacancy indicator plot (rasterized)
%
% Notes:
% * All 3,146 vacancy indicator variations are plotted simultaneously
% * Semi-transparent orange lines allow visualization of indicator density
% * Y-axis shows normalized indicator values (distance from turning point)
% * Figure is rasterized at 450 DPI using OpenGL renderer to reduce file size

%% Specify figure ID
figureId = 'VIndicator';

%% Produce figure
% Set up figure window
figure('NumberTitle', 'off', 'Name', ['Figure ', figureId])
hold on

% Format x-axis
ax = gca; 
set(ax, dataAxis{:})

% Format y-axis
ax.YLim = [0, 2.5];
ax.YTick = 0 : 0.5 : 2.5;
ax.YLabel.String = 'Vacancy indicator';

% Paint recession areas
xregion(startNber, endNber, grayArea{:});

% Plot all vacancy indicators with transparent orange lines
plot(timeline, vIndicator, orangeTransparentBand{:})

% Save figure as rasterized PDF
print('-dpdf', '-opengl', '-r450', fullfile(outputFolder, ['figure', figureId, '.pdf']))