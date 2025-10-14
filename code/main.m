% main.m - Main script for recession forecasting using labor market indicators
%
% Description:
% This script implements a machine learning approach to real-time recession
% detection using unemployment and vacancy data. It constructs thousands of
% recession indicators through systematic transformations (smoothing, curvature
% adjustment, turning point detection, and mixing), then identifies optimal
% classifiers on the anticipation-precision frontier. The script performs
% training, testing, placebo tests, and multiple backtests to validate the
% approach.
%
% Workflow:
% 1. Data preparation: Load unemployment and vacancy rates from FRED and other sources
% 2. Indicator construction: Build 69,212 mixed indicators from raw data
% 3. Classifier selection: Identify perfect classifiers on training set (1929-2021)
% 4. Frontier analysis: Select classifiers on anticipation-precision Pareto frontier
% 5. Ensemble construction: Build high-precision ensemble from frontier classifiers
% 6. Probability computation: Calculate recession probabilities for full sample
% 7. Placebo test: Validate approach using non-recession events (First Ladies deaths)
% 8. Backtests: Test robustness across multiple training periods (1940-2015)
%
% Output:
% * Figures: Raw data, indicators, frontier, ensemble classifiers, probabilities
% * Tables: Ensemble classifier parameters and performance metrics
% * Data files: CSV files with all plotted data, MAT files with training results
%
% Requirements:
% * Input data files in ../../data/current/input/
% * MATLAB R2019b or later (for certain functions)
% * Sufficient memory for large matrix operations (recommend 16GB+ RAM)
%
% Notes:
% * selectPerfectClassifier() is computationally intensive (several hours)
% * Intermediate results saved to ../../data/current/intermediate/
% * Uncomment load() lines to skip recomputing expensive operations
% * All figures use formatFigure.m for consistent styling

%% Clear MATLAB

% Close figure windows
close all

% Clear workspace
clear

% Clear command window
clc

%% Prepare analysis

% Specify folder with raw data
inputFolder = fullfile('..', '..', 'data', 'current', 'input');

% Specify folder with intermediate MATLAB results
intermediateFolder = fullfile('..', '..', 'data', 'current', 'intermediate');

% Specify folder with figures and numerical results
outputFolder = fullfile('..', '..', 'data', 'current', 'output');

% Set analysis dates and parameters
beginDate = 1929 + 3/12;
endDate = 2025 + 7/12;
timeline = [beginDate : 1/12 : endDate]';

% Format default figure and predefine plot properties
formatFigure

%% Build recession indicators

% Collect raw labor market data
uRaw = getUnemployment(inputFolder, beginDate, endDate);
vRaw = getVacancy(inputFolder, beginDate, endDate);

% Build pure indicators from unemployment (countercyclical) and vacancy (procyclical)
[uIndicator, uParameters] = buildIndicator(uRaw, 0);
[vIndicator, vParameters] = buildIndicator(vRaw, 1);

% Verify that parameter structures are identical
assert(isequal(uParameters, vParameters), 'Parameter structures from unemployment and vacancy indicators do not match');

% Build mixed indicators from pure indicators (combines u and v information)
[indicator, parameters] = mixIndicator(uIndicator, vIndicator, uParameters);

%% Plot intermediate building results

% Plot raw unemployment and vacancy data
plotData

% Plot pure indicators (unemployment and vacancy)
plotIndicator

%% Select perfect recession classifiers over 1929-2021

% Set training period
beginTraining = beginDate;
endTraining = 2021 + 11/12;

% Collect and count actual recession starts on training set
[startNber, ~] = getNber(inputFolder, beginTraining, endTraining);
nNber = numel(startNber);

% Select perfect classifiers (detect exactly nNber events over training period ; comment to use results saved in intermediateFolder)
[indexPerfect, thresholdPerfect, startPerfect] = selectPerfectClassifier(indicator, timeline, beginTraining, endTraining, nNber);

% Save intermediate training results (require a few hours to obtain; comment to use results saved in intermediateFolder)
save(fullfile(intermediateFolder, 'ensemble.mat'), 'indexPerfect', 'thresholdPerfect', 'startPerfect', '-v7.3')

% Recall saved data to skip selectPerfectClassifier() (uncomment to use after commenting the two lines above)
% load(fullfile(intermediateFolder, 'ensemble.mat'))

%% Select frontier classifiers and construct high-precision ensemble

% Select classifiers on the anticipation-precision Pareto frontier
[indexFrontier, errors] = selectFrontierClassifier(startPerfect, startNber);

% Set high-precision threshold (maximum acceptable standard deviation of errors)
stdErrorMax = 3;

% Select frontier classifiers with standard deviation below threshold
indexEnsemble = indexFrontier(errors(1, indexFrontier) < stdErrorMax);

% Plot anticipation-precision frontier with zoom on high-precision segment
plotFrontier(errors, indexFrontier, 'frontier', format, outputFolder, stdErrorMax)

% Tabulate ensemble classifiers (parameters and performance metrics)
parametersEnsemble = parameters(:, indexPerfect(indexEnsemble));
thresholdEnsemble = thresholdPerfect(indexEnsemble);
errorsEnsemble = errors(:, indexEnsemble);
tabulateEnsemble(parametersEnsemble, thresholdEnsemble, errorsEnsemble, 'ensemble', outputFolder) 

% Plot ensemble classifiers (individual indicators and thresholds)
indicatorEnsemble = indicator(:, indexPerfect(indexEnsemble));
plotEnsemble(indicatorEnsemble, timeline, thresholdEnsemble, 'ensemble', format, outputFolder)

%% Compute and plot recession probabilities

% Compute recession probabilities from ensemble classifiers
[recessionProbability] = computeRecessionProbability(indicatorEnsemble, thresholdEnsemble, errorsEnsemble);

% Plot individual and aggregate recession probabilities for training and testing periods
plotProbability(recessionProbability, timeline, beginTraining, endTraining, endDate, 'probability', format, outputFolder)

%% Placebo test: validate approach using non-recession events

% Enter placebo dates: deaths of US first ladies (15 events to match 15 recessions)
placebo = [
    2018, 4;   % Barbara Bush
    2016, 3;   % Nancy Reagan
    2011, 7;   % Betty Ford
    2007, 7;   % Lady Bird Johnson
    1994, 5;   % Jacqueline Kennedy
    1993, 6;   % Pat Nixon
    1982, 10;  % Bess Truman
    1979, 11;  % Mamie Eisenhower
    1962, 11;  % Eleanor Roosevelt
    1961, 12;  % Edith Wilson
    1957, 7;   % Grace Coolidge
    1948, 9;   % Edith Roosevelt
    1947, 10;  % Frances Cleveland
    1944, 1;   % Lou Hoover
    1943, 5;   % Helen Taft
];
startPlacebo = placebo(:, 1) + (placebo(:, 2) - 1) ./ 12;
nPlacebo = numel(startPlacebo);
assert(isequal(nNber, nPlacebo), 'Improper placebo event: number of events must match number of recessions');

% Rebuild anticipation-precision frontier for placebo test
% Same perfect classifiers (detect nPlacebo events) but different performance
[indexFrontierPlacebo, errorsPlacebo] = selectFrontierClassifier(startPerfect, startPlacebo);

% Plot frontier for placebo test
plotFrontier(errorsPlacebo, indexFrontierPlacebo, 'frontier_placebo', format, outputFolder)

% Tabulate top 10 classifiers on placebo frontier
indexEnsemblePlacebo = indexFrontierPlacebo(1 : min(10, end));
parametersEnsemblePlacebo = parameters(:, indexPerfect(indexEnsemblePlacebo));
thresholdEnsemblePlacebo = thresholdPerfect(indexEnsemblePlacebo);
errorsEnsemblePlacebo = errorsPlacebo(:, indexEnsemblePlacebo);
tabulateEnsemble(parametersEnsemblePlacebo, thresholdEnsemblePlacebo, errorsEnsemblePlacebo, 'ensemble_placebo', outputFolder) 

%% Series of backtests: test robustness across different training periods

for backtest = [2015, 2005, 1995, 1985, 1965, 1940]

	% Set training period end date
	endTrainingBacktest = backtest - 1/12;

	% Collect and count actual recession starts on backtest training set
	[startNberBacktest, ~] = getNber(inputFolder, beginTraining, endTrainingBacktest);
	nNberBacktest = numel(startNberBacktest);

	% Select perfect classifiers for backtest training period (comment to use results saved in intermediateFolder)
	[indexPerfectBacktest, thresholdPerfectBacktest, startPerfectBacktest] = selectPerfectClassifier(indicator, timeline, beginTraining, endTrainingBacktest, nNberBacktest);

	% Save intermediate backtest results (comment to use results saved in intermediateFolder)
	save(fullfile(intermediateFolder, ['ensemble_', int2str(backtest), '.mat']), 'indexPerfectBacktest', 'thresholdPerfectBacktest', 'startPerfectBacktest', '-v7.3')

	% Recall saved data to skip selectPerfectClassifier() (uncomment to use after commenting the two lines above)
	% load(fullfile(intermediateFolder, ['ensemble_', int2str(backtest), '.mat']))

	% Select classifiers on the anticipation-precision frontier
	[indexFrontierBacktest, errorsBacktest] = selectFrontierClassifier(startPerfectBacktest, startNberBacktest);

	% Select frontier classifiers with standard deviation below threshold
	indexEnsembleBacktest = indexFrontierBacktest(errorsBacktest(1, indexFrontierBacktest) < stdErrorMax);

	% Plot anticipation-precision frontier for backtest
	plotFrontier(errorsBacktest, indexFrontierBacktest, ['frontier_', int2str(backtest)], format, outputFolder, stdErrorMax)

	% Tabulate backtest ensemble classifiers
	parametersEnsembleBacktest = parameters(:, indexPerfectBacktest(indexEnsembleBacktest));
	thresholdEnsembleBacktest = thresholdPerfectBacktest(indexEnsembleBacktest);
	errorsEnsembleBacktest = errorsBacktest(:, indexEnsembleBacktest);
	tabulateEnsemble(parametersEnsembleBacktest, thresholdEnsembleBacktest, errorsEnsembleBacktest, ['ensemble_', int2str(backtest)], outputFolder) 

	% Plot backtest ensemble classifiers
	indicatorEnsembleBacktest = indicator(:, indexPerfectBacktest(indexEnsembleBacktest));
	plotEnsemble(indicatorEnsembleBacktest, timeline, thresholdEnsembleBacktest, ['ensemble_', int2str(backtest)], format, outputFolder)

	% Compute recession probabilities for backtest
	[recessionProbabilityBacktest] = computeRecessionProbability(indicatorEnsembleBacktest, thresholdEnsembleBacktest, errorsEnsembleBacktest);

	% Plot recession probabilities for backtest training and testing periods
	plotProbability(recessionProbabilityBacktest, timeline, beginTraining, endTrainingBacktest, endDate, ['probability_', int2str(backtest)], format, outputFolder)

end