% selectFrontierClassifier - Identify classifiers on the anticipation-precision frontier
%
% Syntax:
%   [indexEnsemble, indexFrontier, stdError, meanError, minError, maxError] = selectFrontierClassifier(startPerfect, startNber, stdErrorMax)
%
% Description:
% This function computes detection errors for perfect classifiers (those that
% detected the correct number of recessions) and identifies classifiers on the
% anticipation-precision frontier. The frontier consists of classifiers that
% minimize mean anticipation for each level of precision (standard deviation).
% It also extracts a high-precision ensemble subset from the frontier.
%
% Input arguments:
% * startPerfect - matrix [nNber x nPerfect], detected recession start dates from perfect classifiers
% * startNber - column vector [nNber x 1], actual NBER recession start dates
% * stdErrorMax - scalar, maximum standard deviation threshold for ensemble selection (in months)
%
% Output arguments:
% * indexEnsemble - row vector, indices of high-precision frontier classifiers (std error < stdErrorMax)
% * indexFrontier - row vector, indices of all classifiers on the frontier
% * stdError - row vector, standard deviation of errors for all perfect classifiers (in months)
% * meanError - row vector, mean errors for all perfect classifiers (in months)
% * minError - row vector, minimum errors for all perfect classifiers (in months)
% * maxError - row vector, maximum errors for all perfect classifiers (in months)
%
% Notes:
% * Errors are measured in months (positive = early detection, negative = late detection)
% * Classifiers are sorted by standard deviation (precision)
% * Frontier identifies classifiers with best mean anticipation at each precision level
% * The frontier is constructed by selecting classifiers with strictly improving mean errors
% * Ensemble consists of frontier classifiers meeting the precision threshold
%
% Example:
%   [ensemble, frontier, std, mean, min, max] = selectFrontierClassifier(startPerfect, startNber, 6);

function [indexEnsemble, indexFrontier, stdError, meanError, minError, maxError] = selectFrontierClassifier(startPerfect, startNber, stdErrorMax)

%% Compute distance from detected start dates to NBER start dates in months
nPerfect = size(startPerfect, 2);

% Replicate NBER dates to match dimensions of detected dates
startNber = repmat(startNber, 1, nPerfect);

% Compute errors in months (positive = early, negative = late)
errorMat = (startPerfect - startNber) .* 12;

%% Compute detection errors for each classifier
% Mean error (average anticipation/delay across recessions)
meanError = mean(errorMat);

% Minimum error (earliest anticipation or latest delay)
minError = min(errorMat);

% Maximum error (latest anticipation or earliest delay)
maxError = max(errorMat);

% Standard deviation (precision of detection timing)
stdError = std(errorMat, 1);

%% Sort classifiers by standard error (precision)
[stdErrorSorted, indexSorted] = sort(stdError);
meanErrorSorted = meanError(indexSorted);

%% Construct anticipation-precision frontier
% Initialize frontier with first (most precise) classifier
frontierSorted = [1];
nSorted = numel(indexSorted);

% Build frontier by selecting classifiers with strictly better mean error
for iSorted = 2 : nSorted
	if meanErrorSorted(iSorted) < meanErrorSorted(frontierSorted(end))
		frontierSorted = [frontierSorted, iSorted];
	end
end 

% Extract indices of perfect classifiers on the frontier
indexFrontier = indexSorted(frontierSorted);

%% Construct high-precision ensemble from frontier
% Select frontier classifiers with standard deviation below threshold
indexEnsemble = indexFrontier(stdError(indexFrontier) < stdErrorMax);

end