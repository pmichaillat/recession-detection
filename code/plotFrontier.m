% plotFrontier - Plot anticipation-precision frontier for recession classifiers
%
% Description:
% This script plots all perfect classifiers in the anticipation-precision plane,
% highlighting those on the Pareto frontier. The x-axis shows the standard
% deviation of detection errors (precision), and the y-axis shows the mean
% detection error (anticipation). Classifiers on the frontier represent optimal
% tradeoffs between precision and anticipation.
%
% Requirements:
% * outputFolder - string or char, path to output folder (defined in main.m)
% * formatFigure.m - script to predefine figure properties (run in main.m)
% * stdError - row vector, standard deviation of errors for all perfect classifiers
% * meanError - row vector, mean errors for all perfect classifiers (in months)
% * indexFrontier - row vector, indices of classifiers on the frontier
% * purple - string, color code (defined in formatFigure.m)
% * orange - string, color code (defined in formatFigure.m)
% * medium - scalar, line width (defined in formatFigure.m)
%
% Output:
% * figureFrontier.pdf - PDF file with anticipation-precision frontier plot
%
% Notes:
% * Purple circles show all perfect classifiers
% * Orange circles connected by line show frontier classifiers
% * Positive mean error indicates early detection (anticipation)
% * Negative mean error indicates late detection (delay)
% * Lower standard deviation indicates more consistent detection timing

%% Specify figure ID
figureId = 'Frontier';

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

% Plot all perfect classifiers in anticipation-precision plane
h1 = plot(stdError, meanError);

% Format scatter plot for all perfect classifiers
h1.Color = purple;
h1.MarkerSize = 7;
h1.MarkerFaceColor = purple;
h1.LineStyle = 'none';
h1.Marker = 'o';

% Plot anticipation-precision frontier
stdErrorFrontier = stdError(indexFrontier);
meanErrorFrontier = meanError(indexFrontier);
h2 = plot(stdErrorFrontier, meanErrorFrontier);

% Format line plot for frontier classifiers
h2.Color = orange;
h2.MarkerSize = 7;
h2.MarkerFaceColor = orange;
h2.LineStyle = '-';
h2.LineWidth = medium;
h2.Marker = 'o';

% Save figure as PDF
print('-dpdf', fullfile(outputFolder, ['figure', figureId, '.pdf']))