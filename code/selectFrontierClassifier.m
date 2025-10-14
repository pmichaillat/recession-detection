% selectFrontierClassifier - Identify classifiers on the anticipation-precision frontier
%
% Syntax:
%   [indexFrontier, errors] = selectFrontierClassifier(startPerfect, startNber)
%
% Description:
% This function computes detection errors for perfect classifiers (those that
% detected the correct number of recessions) and identifies classifiers on the
% anticipation-precision frontier. The frontier consists of classifiers that
% minimize mean anticipation for each level of precision (standard deviation).
%
% Input arguments:
% * startPerfect - matrix [nNber x nPerfect], detected recession start dates from perfect classifiers
% * startNber - column vector [nNber x 1], actual NBER recession start dates
%
% Output arguments:
% * indexFrontier - row vector, indices of all classifiers on the frontier
% * errors - matrix [4 x nPerfect], with standard deviation of errors for all perfect classifiers in months (first row), mean errors for all perfect classifiers in months (second row), minimum errors for all perfect classifiers in months (third row), and maximum errors for all perfect classifiers in months (fourth row)
%
% Notes:
% * Errors are measured in months (positive = early detection, negative = late detection)
% * Classifiers are sorted by standard deviation (precision)
% * Frontier identifies classifiers with best mean anticipation at each precision level
% * The frontier is constructed by selecting classifiers with strictly improving mean errors
%
% Example:
%   [frontier, errors] = selectFrontierClassifier(startPerfect, startNber);

function [indexFrontier, errors] = selectFrontierClassifier(startPerfect, startNber)

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

% Collect moments of errors for all classifiers

errors = [stdError; meanError; minError; maxError];

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

end