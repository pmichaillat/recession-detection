% computeRecessionProbability - Calculate recession probabilities from ensemble classifiers
%
% Syntax:
%   recessionProbability = computeRecessionProbability(indicatorEnsemble, thresholdEnsemble, errorsEnsemble)
%
% Description:
% This function computes the probability of recession for each month based on
% ensemble classifier signals. It tracks when each classifier detects a recession
% (indicator crosses threshold), measures how long the recession has lasted, and
% uses the classifier's error distribution to compute the probability that a
% true NBER recession is occurring.
%
% Input arguments:
% * indicatorEnsemble - matrix [nMonth x nEnsemble], recession indicators
% * thresholdEnsemble - row vector [1 x nEnsemble], threshold for each classifier
% * errorsEnsemble - matrix [4 x nEnsemble], detection errors with rows:
%   (1) standard deviation, (2) mean error, (3) minimum error, (4) maximum error
%
% Output arguments:
% * recessionProbability - matrix [nMonth x nEnsemble], recession probability for each classifier (0-1)
%
% Notes:
% * Recession starts when indicator crosses above threshold during expansion
% * Recession ends when indicator returns to zero
% * Recession duration is measured in months since detection
% * Probability assumes detection errors are normally distributed
% * Probability = P(true recession started | classifier detected recession d months ago)
% * Uses normcdf with mean and std from classifier's historical errors
% * Probability is zero during expansion periods
%
% Example:
%   probs = computeRecessionProbability(indicators, thresholds, errors);

function [recessionProbability] = computeRecessionProbability(indicatorEnsemble, thresholdEnsemble, errorsEnsemble)

% Get dimensions
[nMonth, nEnsemble] = size(indicatorEnsemble);

% Replicate thresholds for comparison with indicators
thresholdMat = repmat(thresholdEnsemble, nMonth - 1, 1);

%% Compute recession durations implied by the classifiers
% Mark indices where indicators cross threshold from below
% Threshold is crossed between current month and next month
crossThreshold = ((indicatorEnsemble(1 : end - 1, :) < thresholdMat) & (indicatorEnsemble(2 : end, :) >= thresholdMat));

% Initialize expansion state tracker (true = in expansion, false = in recession)
isExpansion = true(nMonth, nEnsemble);

% Initialize recession duration counter (months since recession detected)
recessionDuration = zeros(nMonth, nEnsemble);

% Track recession starts, ends, and durations month by month
for iMonth = 1 : (nMonth - 1)
    % Recession starts if threshold crossed during expansion
    newRecession = crossThreshold(iMonth, :) & isExpansion(iMonth, :);
    
    % Recession ends when indicator returns to zero
    newExpansion = (indicatorEnsemble(iMonth + 1, :) == 0) & ~isExpansion(iMonth, :);
    
    % Update expansion state for next month
    isExpansion(iMonth + 1, :) = isExpansion(iMonth, :) + newExpansion - newRecession;
    
    % Update recession duration for next month (increments during recession, resets to zero during expansion)
    recessionDuration(iMonth + 1, :) = (recessionDuration(iMonth, :) + 1) .* (~isExpansion(iMonth + 1, :));
end   

%% Use classifier error structure and detected recession durations to compute individual recession probabilities 
% Replicate mean and standard deviation of errors for all months
stdErrorMat = repmat(errorsEnsemble(1, :), nMonth, 1);
meanErrorMat = repmat(errorsEnsemble(2, :), nMonth, 1);

% Compute recession probability assuming normal distribution of detection errors
% P(true recession | detected d months ago) = normcdf(d-1, -mean_error, std_error)
% During expansion, probability is set to zero
recessionProbability = normcdf(recessionDuration - 1, -meanErrorMat, stdErrorMat) .* (~isExpansion);

end