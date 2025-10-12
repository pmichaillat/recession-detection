% plotUIndicator - Plot unemployment indicators
%
% Description:
% This script plots all unemployment indicators constructed from the raw
% unemployment rate data. Each indicator represents a different combination of
% smoothing, curvature, and turning point detection parameters. Recession
% periods are shaded in gray.
%
% Requirements:
% * outputFolder - string or char, path to output folder (defined in main.m)
% * timeline - column vector, date vector in decimal year format
% * uIndicator - matrix [nMonth x nIndicators], unemployment indicators from buildIndicator
% * startRecession - column vector, recession start dates in decimal years
% * endRecession - column vector, recession end dates in decimal years
% * dataAxis - cell array, x-axis properties (defined in formatFigure.m)
% * purpleTransparentBand - cell array, line properties (defined in formatFigure.m)
% * grayArea - cell array, area properties (defined in formatFigure.m)
%
% Output:
% * figureUIndicator.pdf - PDF file with unemployment indicator plot (rasterized)
%
% Notes:
% * All 3,146 unemployment indicator variations are plotted simultaneously
% * Semi-transparent purple lines allow visualization of indicator density
% * Y-axis shows normalized indicator values (distance from turning point)
% * Figure is rasterized at 450 DPI using OpenGL renderer to reduce file size

%% Specify figure ID
figureId = 'UIndicator';

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
ax.YLabel.String = 'Unemployment indicator';

% Paint recession areas
xregion(startNber, endNber, grayArea{:});

% Plot all unemployment indicators with transparent purple lines
plot(timeline, uIndicator, purpleTransparentBand{:})

% Save figure as rasterized PDF
print('-dpdf', '-opengl', '-r450', fullfile(outputFolder, ['figure', figureId, '.pdf']))