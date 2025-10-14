% plotIndicator - Plot unemployment and vacancy indicators
%
% Description:
% This script plots all unemployment and vacancy indicators constructed from
% the raw data. Each indicator represents a different combination of smoothing,
% curvature, and turning point detection parameters. Recession periods are
% shaded in gray. Two separate figures are produced.
%
% Requirements:
% * outputFolder - string or char, path to output folder (defined in main.m)
% * formatFigure.m - script to predefine figure properties (run in main.m)
% * timeline - column vector, date vector in decimal year format
% * uIndicator - matrix [nMonth x nIndicators], unemployment indicators from buildIndicator
% * vIndicator - matrix [nMonth x nIndicators], vacancy indicators from buildIndicator
% * startNber - column vector, NBER recession start dates in decimal years
% * endNber - column vector, NBER recession end dates in decimal years
% * dataAxis - cell array, x-axis properties (defined in formatFigure.m)
% * purpleTransparentBand - cell array, line properties (defined in formatFigure.m)
% * orangeTransparentBand - cell array, line properties (defined in formatFigure.m)
% * grayArea - cell array, area properties (defined in formatFigure.m)
%
% Output:
% * figureUIndicator.pdf - PDF file with unemployment indicator plot (rasterized)
% * figureVIndicator.pdf - PDF file with vacancy indicator plot (rasterized)
%
% Notes:
% * All 4,356 indicator variations per series are plotted simultaneously
% * Semi-transparent lines allow visualization of indicator density
% * Unemployment indicators plotted in purple, vacancy indicators in orange
% * Y-axis shows normalized indicator values (distance from turning point)
% * Figures are rasterized at 450 DPI using OpenGL renderer to reduce file size

%% Specify figure ID for unemployment indicators
figureId = 'unemployment';

%% Produce unemployment indicator figure
% Set up figure window
figure('NumberTitle', 'off', 'Name', ['Figure ', figureId])
hold on

% Format x-axis
ax = gca; 
set(ax, dataAxis{:})

% Format y-axis
ax.YLim = [0, 2.1];
ax.YTick = 0 : 0.3 : 2.1;
ax.YLabel.String = 'Unemployment indicator';

% Shade NBER recessions
xregion(startNber, endNber, grayArea{:});

% Plot all unemployment indicators with transparent purple lines
plot(timeline, uIndicator, purpleTransparentBand{:})

% Save figure as rasterized PDF
print('-dpdf', '-opengl', '-r450', fullfile(outputFolder, ['figure_', figureId, '.pdf']))

%% Specify figure ID for vacancy indicators
figureId = 'vacancy';

%% Produce vacancy indicator figure
% Set up figure window
figure('NumberTitle', 'off', 'Name', ['Figure ', figureId])
hold on

% Format x-axis
ax = gca; 
set(ax, dataAxis{:})

% Format y-axis
ax.YLim = [0, 2.1];
ax.YTick = 0 : 0.3 : 2.1;
ax.YLabel.String = 'Vacancy indicator';

% Shade NBER recessions
xregion(startNber, endNber, grayArea{:});

% Plot all vacancy indicators with transparent orange lines
plot(timeline, vIndicator, orangeTransparentBand{:})

% Save figure as rasterized PDF
print('-dpdf', '-opengl', '-r450', fullfile(outputFolder, ['figure_', figureId, '.pdf']))