% plotProbability - Plot recession probabilities for training and testing periods
%
% Syntax:
%   plotProbability(recessionProbability, timeline, beginTraining, endTraining, endDate, figureId, format, outputFolder)
%
% Description:
% This function creates two plots showing recession probabilities: one for the
% training period and one for the testing period. Individual classifier
% probabilities are shown in orange, with the ensemble mean in purple. NBER
% recessions are shaded in gray. Data are saved to CSV.
%
% Input arguments:
% * recessionProbability - matrix [nMonth x nEnsemble], recession probabilities
% * timeline - column vector, date vector in decimal year format
% * beginTraining - scalar, beginning date of training period in decimal years
% * endTraining - scalar, end date of training period in decimal years
% * endDate - scalar, end date of full sample in decimal years
% * figureId - string or char, identifier for figure naming
% * format - structure, formatting properties from formatFigure.m
% * outputFolder - string or char, path to output folder
%
% Output:
% * figureProbabilityTraining.pdf - PDF with training period probabilities
% * figureProbabilityTesting.pdf - PDF with testing period probabilities
% * figureProbability.csv - CSV file with all probability data
%
% Notes:
% * Training plot shows period used to calibrate classifiers
% * Testing plot shows out-of-sample performance (begins after training ends)
% * Orange bands show individual classifier probabilities
% * Purple line shows ensemble mean probability
% * Y-axis shows probabilities as percentages (0-100%)
% * Requires format structure with: grayArea, orangeOpaqueBand, purpleLine, startNber, endNber
%
% Example:
%   plotProbability(probs, timeline, 1950.0, 2019.0, 2024.0, 'Probability', format, './output');

function plotProbability(recessionProbability, timeline, beginTraining, endTraining, endDate, figureId, format, outputFolder)

%% Produce training figure
% Set up figure window
figure('NumberTitle', 'off', 'Name', ['Figure ', figureId, ': training'])
hold on

% Format x-axis
ax = gca;
ax.XLim = [beginTraining, endTraining];

% Format y-axis
ax.YLim = [0, 1];
ax.YTick = [0 : 0.2 : 1];
ax.YTickLabel = ["0%"; "20%"; "40%"; "60%"; "80%"; "100%"];
ax.YLabel.String = 'Recession probability';

% Shade NBER recessions
xregion(format.startNber, format.endNber, format.grayArea{:});

% Plot individual recession probabilities in orange
plot(timeline, recessionProbability, format.orangeOpaqueBand{:})

% Calculate and plot ensemble mean recession probability in purple
recessionProbabilityMean = mean(recessionProbability, 2);
plot(timeline, recessionProbabilityMean, format.purpleLine{:})

% Save figure as PDF
print('-dpdf', fullfile(outputFolder, ['figure_', figureId, '_training.pdf']))

%% Produce testing figure
% Set up figure window
figure('NumberTitle', 'off', 'Name', ['Figure ', figureId, ': testing'])
hold on

% Format x-axis (testing period starts after training ends)
ax = gca;
beginTesting = endTraining + 1/12;
endTesting = endDate;
ax.XLim = [beginTesting, endTesting];

% Format y-axis
ax.YLim = [0, 1];
ax.YTick = [0 : 0.2 : 1];
ax.YTickLabel = ["0%"; "20%"; "40%"; "60%"; "80%"; "100%"];
ax.YLabel.String = 'Recession probability';

% Shade NBER recessions
xregion(format.startNber, format.endNber, format.grayArea{:});

% Plot individual recession probabilities in orange
plot(timeline, recessionProbability, format.orangeOpaqueBand{:})

% Plot ensemble mean recession probability in purple
plot(timeline, recessionProbabilityMean, format.purpleLine{:})

% Save figure as PDF
print('-dpdf', fullfile(outputFolder, ['figure_', figureId, '_testing.pdf']))

%% Save figure data
% Create headers for each column (year, mean, then individual classifiers)
header = [{'Year', 'Mean recession probability'}, arrayfun(@(i) ['Recession probability from classifier ', num2str(i)], [1 : size(recessionProbability, 2)], 'UniformOutput', false)];

% Combine timeline, mean probability, and individual probabilities
data = [timeline, recessionProbabilityMean, recessionProbability];

% Write data to CSV file
writetable(array2table(data, 'VariableNames', header), fullfile(outputFolder, ['figure_', figureId, '.csv']))

end