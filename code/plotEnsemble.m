% plotEnsemble - Plot ensemble classifiers individually and combined
%
% Syntax:
%   plotEnsemble(indicatorEnsemble, timeline, thresholdEnsemble, figureId, format, outputFolder)
%
% Description:
% This function creates individual plots for each classifier in the ensemble
% showing the indicator and its threshold, plus a combined plot showing all
% normalized indicators together. All data are saved to CSV files.
%
% Input arguments:
% * indicatorEnsemble - matrix [nMonth x nEnsemble], recession indicators
% * timeline - column vector, date vector in decimal year format
% * thresholdEnsemble - row vector [1 x nEnsemble], threshold for each classifier
% * figureId - string or char, identifier for figure naming
% * format - structure, formatting properties from formatFigure.m
% * outputFolder - string or char, path to output folder
%
% Output:
% * figure[figureId][1-N].pdf - Individual plots for each classifier
% * figure[figureId].pdf - Combined plot with all normalized classifiers
% * figure[figureId].csv - CSV with all classifier data
% * figure[figureId]Normalized.csv - CSV with all normalized classifier data
%
% Notes:
% * Each classifier is plotted with its specific threshold
% * Normalized indicators divide indicator by threshold (threshold becomes 1)
% * NBER recessions are shaded in gray on all plots
% * Requires format structure with: dataAxis, purpleLine, purpleThinLine, pinkThinLine, grayArea, startNber, endNber
%
% Example:
%   plotEnsemble(indicators, timeline, thresholds, 'Ensemble', format, './output');

function plotEnsemble(indicatorEnsemble, timeline, thresholdEnsemble, figureId, format, outputFolder)

% Set number of classifiers in ensemble
nEnsemble = size(indicatorEnsemble, 2);

% Initialize data storage
header = {'Year'};
data = [timeline];
dataNormalized = [timeline];

% Create individual plots for each classifier
for iEnsemble = 1 : nEnsemble
	panelId = int2str(iEnsemble);
	
	%% Extract classifier data
	threshold = thresholdEnsemble(iEnsemble);
	indicator = indicatorEnsemble(:, iEnsemble);
	indicatorNormalized = indicator ./ threshold;
	
	%% Produce individual figure
	% Set up figure window
	figure('NumberTitle', 'off', 'Name', ['Figure ', figureId, ' (', panelId,')'])
	hold on
	
	% Format x-axis
	ax = gca; 
	set(ax, format.dataAxis{:})
	
	% Format y-axis
	ax.YLabel.String = 'Recession indicator';
	
	% Shade NBER recessions
	xregion(format.startNber, format.endNber, format.grayArea{:});
	
	% Plot recession indicator in purple
	plot(timeline, indicator, format.purpleLine{:})
	
	% Plot threshold as horizontal line
	yline(threshold, format.pinkThinLine{:})
	
	% Save figure as PDF
	print('-dpdf', fullfile(outputFolder, ['figure_', figureId, '_' ,panelId, '.pdf']))
	
	% Accumulate data for CSV export
	header = [header, {['Classifier ', panelId]}];
	data = [data, indicator];
	dataNormalized = [dataNormalized, indicatorNormalized];
end

%% Produce combined figure with normalized classifiers
% Set up figure window
figure('NumberTitle', 'off', 'Name', ['Figure ', figureId])
hold on

% Format x-axis
ax = gca; 
set(ax, format.dataAxis{:})

% Format y-axis
ax.YLim = [0, 6];
ax.YTick = [0 : 1 : 6];
ax.YLabel.String = 'Normalized recession indicator';

% Shade NBER recessions
xregion(format.startNber, format.endNber, format.grayArea{:});

% Plot all normalized recession indicators in purple
plot(dataNormalized(:, 1), dataNormalized(:, 2 : end), format.purpleThinLine{:})

% Plot normalized threshold at 1
yline(1, format.pinkThinLine{:})

% Save figure as PDF
print('-dpdf', fullfile(outputFolder, ['figure_', figureId, '.pdf']))

%% Write all data to CSV files
% Save raw indicator data
writetable(array2table(data, 'VariableNames', header), fullfile(outputFolder, ['figure_', figureId, '.csv']))

% Save normalized indicator data
writetable(array2table(dataNormalized, 'VariableNames', header), fullfile(outputFolder, ['figure_', figureId, '_normalized.csv']))

end