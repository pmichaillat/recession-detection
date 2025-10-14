% plotFrontier - Plot anticipation-precision frontier for recession classifiers
%
% Syntax:
%   plotFrontier(errors, indexFrontier, figureId, format, outputFolder)
%   plotFrontier(errors, indexFrontier, figureId, format, outputFolder, errorMax)
%
% Description:
% This function plots all perfect classifiers in the anticipation-precision plane,
% highlighting those on the Pareto frontier. The x-axis shows the standard
% deviation of detection errors (precision), and the y-axis shows the mean
% detection error (anticipation). Classifiers on the frontier represent optimal
% tradeoffs between precision and anticipation. Optionally produces a zoomed view
% of the high-precision segment.
%
% Input arguments:
% * errors - matrix [4 x nPerfect], detection errors for all perfect classifiers
% * indexFrontier - row vector, indices of classifiers on the frontier
% * figureId - string or char, identifier for figure naming
% * format - structure, formatting properties from formatFigure.m
% * outputFolder - string or char, path to output folder
% * errorMax - scalar (optional), maximum standard error for zoomed plot x-axis
%
% Output:
% * figureFrontier.pdf - PDF file with full anticipation-precision frontier plot
% * figureFrontierHighPrecision.pdf - PDF file with zoomed view (only if errorMax provided)
%
% Notes:
% * Purple circles show all perfect classifiers
% * Orange circles connected by line show frontier classifiers
% * Positive mean error indicates early detection (anticipation)
% * Negative mean error indicates late detection (delay)
% * Lower standard deviation indicates more consistent detection timing
% * Zoomed version shows x-axis from minimum std error (rounded down) to errorMax
% * Requires format structure with: purple, orange, medium
%
% Example:
%   plotFrontier(errors, indexFrontier, 'Frontier', format, './output');
%   plotFrontier(errors, indexFrontier, 'Frontier', format, './output', 6);

function plotFrontier(errors, indexFrontier, figureId, format, outputFolder, errorMax)

%% Produce figure
% Set up figure window
figure('NumberTitle', 'off', 'Name', ['Figure ', figureId])
hold on

% Format x-axis
ax = gca;
ax.XGrid = 'on';
ax.TickLength = [0 0];
ax.XLabel.String = 'Standard deviation of error (months)';

% Format y-axis
ax.YLabel.String = 'Mean of error (months)';

% Extract error statistics from errors matrix
stdError = errors(1, :);
meanError = errors(2, :);

% Plot all perfect classifiers in anticipation-precision plane
h1 = plot(stdError, meanError);

% Format scatter plot for all perfect classifiers
h1.Color = format.purple;
h1.MarkerSize = 7;
h1.MarkerFaceColor = format.purple;
h1.LineStyle = 'none';
h1.Marker = 'o';

% Plot anticipation-precision frontier
stdErrorFrontier = stdError(indexFrontier);
meanErrorFrontier = meanError(indexFrontier);
h2 = plot(stdErrorFrontier, meanErrorFrontier);

% Format line plot for frontier classifiers
h2.Color = format.orange;
h2.MarkerSize = 7;
h2.MarkerFaceColor = format.orange;
h2.LineStyle = '-';
h2.LineWidth = format.medium;
h2.Marker = 'o';

% Save figure as PDF
print('-dpdf', fullfile(outputFolder, ['figure_', figureId, '.pdf']))

%% Produce zoomed version if errorMax parameter is provided
if nargin == 6
    % Set x-axis limits from minimum frontier std error (rounded down) to errorMax
    lowError = floor(stdErrorFrontier(1));
    ax.XLim = [lowError, errorMax];
    
    % Save zoomed figure as PDF
    print('-dpdf', fullfile(outputFolder, ['figure_', figureId, '_precision.pdf']))
end

end