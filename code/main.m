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

% Round dates for easy indexation
beginDate = round(beginDate, 2);
endDate = round(endDate, 2);
timeline = round(timeline, 2);

% Format default figure and predefine plot properties
formatFigure

% Get recessions dates
[startNber, endNber] = getNber(inputFolder, beginDate, endDate);

%% Build recession indicators

% Collect raw labor market data
uRaw = getUnemployment(inputFolder, beginDate, endDate);
vRaw = getVacancy(inputFolder, beginDate, endDate);

% Build pure indicators
[uIndicator, smoothingMethod, smoothingParameter, curvingParameter, turningParameter] = buildIndicator(uRaw, 0);
[vIndicator, smoothingMethod, smoothingParameter, curvingParameter, turningParameter] = buildIndicator(vRaw, 1);

% Build mixed indicators from pure indicators
[indicator, smoothingMethod, smoothingParameter, curvingParameter, turningParameter, mixingMethod, mixingParameter] = mixIndicator(uIndicator, vIndicator, smoothingMethod, smoothingParameter, curvingParameter, turningParameter);

% Create cell array with all parameters
parameters = [ 	smoothingMethod(1,:);
                num2cell(smoothingParameter(1,:));
                num2cell(curvingParameter(1,:));
                num2cell(turningParameter(1,:));
                mixingMethod(1,:);
                num2cell(mixingParameter(1,:))];

% Clear large arrays that are not needed any more
clear smoothingMethod mixingMethod smoothingParameter curvingParameter turningParameter mixingParameter

%% Plot intermediate building results

% Plot raw unemployment and vacancy data
plotData

% Plot pure indicators
plotUIndicator
plotVIndicator

%% Select perfect recession classifiers over 1929-2021

% Set training set
beginTraining = beginDate;
endTraining = round(2021 + 11/12, 2);

% Collect and count actual recession starts on training set
[startNber, ~] = getNber(inputFolder, beginTraining, endTraining);
nNber = numel(startNber);

% Select perfect classifiers, which detect nNber events over training period
[indexPerfect, thresholdPerfect, startPerfect] = selectPerfectClassifier(indicator, timeline, beginTraining, endTraining, nNber);

% Save intermediate training results
save(fullfile(intermediateFolder, 'perfect.mat'), '-v7.3')

%% Select perfect classifiers on the anticipation-precision frontier, and a subset of them on the high-precision segment of the anticipation-precision frontier

% Set high-precision standard
stdErrorMax = 3;

% Select classifiers on the anticipation-precision frontier
[indexEnsemble, indexFrontier, stdError, meanError, minError, maxError] = selectFrontierClassifier(startPerfect, startNber, stdErrorMax);

% Plot perfect classifiers in anticipation-precision plane and highlight the anticipation-precision frontier
plotFrontier

%% Apply the trained algorithm to 2022–2025: has the recession started?

% Compute recession probability on 2022–2025
detectRecession

% Plot individual and aggregate recession probabilities
plotProbability

%% Placebo test

%% Series of backtests

%% Application of the method to IP data


