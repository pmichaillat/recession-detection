% selectPerfectClassifier - Identify classifiers that detect exact number of recessions
%
% Syntax:
%   [indexPerfect, thresholdPerfect, startPerfect] = selectPerfectClassifier(indicator, timeline, beginTraining, endTraining, nNber)
%
% Description:
% This function identifies classifiers (recession indicator-threshold combinations) that detect exactly the specified number of recessions during the training period. It evaluates all indicators for numerous threshold values and tracks which classifiers produce the correct count.
%
% Input arguments:
% * indicator - matrix [nMonth x nIndicator], all indicator variations
% * timeline - column vector, date vector in decimal year format
% * beginTraining - scalar, beginning date of training period in decimal years
% * endTraining - scalar, end date of training period in decimal years
% * nNber - scalar, target number of recessions to detect (from NBER data)
%
% Output arguments:
% * indexPerfect - row vector, column indices of indicators detecting nNber recessions
% * thresholdPerfect - row vector, optimal thresholds for each perfect indicator
% * startPerfect - matrix [nNber x nPerfect], detected recession start dates
%
% Notes:
% * A recession starts when indicator crosses above threshold during expansion
% * A recession ends when indicator returns to zero
% * Threshold values tested range from 0.0001 to 0.5 in steps of 0.0001
% * Perfect classifiers are those detecting exactly nNber recessions in training period
%
% Example:
%   [idx, thresh, starts] = selectPerfectClassifier(uIndicator, timeline, 1950.0, 2019.0, 10);

function [indexPerfect, thresholdPerfect, startPerfect] = selectPerfectClassifier(indicator, timeline, beginTraining, endTraining, nNber)

%% Construct variables for training period
% Extract training period data
trainingIndex = timeline >= beginTraining & timeline <= endTraining;
timelineTraining = timeline(trainingIndex);
indicatorTraining = indicator(trainingIndex, :);

% Get dimensions
nTraining = size(indicatorTraining, 1);
nIndicator = size(indicator, 2);

%% For all thresholds, select classifiers generating nNber recessions
% Set threshold values to test
thresholdMat = [0.0001 : 0.0001 : 0.5];
nThreshold = numel(thresholdMat);

% Preallocate arrays for results
indexPerfect = [];
thresholdPerfect = [];
datePerfect = [];

% Test each threshold value
for iThreshold = 1 : nThreshold
    % Select current threshold
    threshold = thresholdMat(iThreshold)
    
    % Mark indices where indicators cross threshold from below
    % (indicator rises from below threshold to at or above threshold)
    crossThreshold = ((indicatorTraining(1 : end - 1, :) < threshold) & (indicatorTraining(2 : end, :) >= threshold));
    
    % Initialize expansion state tracker (true = in expansion, false = in recession)
    isExpansion = true(nTraining, nIndicator);
    newRecession = false(nTraining - 1, nIndicator);
    
    % Track recession starts and ends month by month
    for iMonth = 1 : (nTraining - 1)
        % Recession starts if threshold crossed during expansion
        newRecession(iMonth, :) = crossThreshold(iMonth, :) & isExpansion(iMonth, :);
        
        % Recession ends when indicator returns to zero
        newExpansion = (indicatorTraining(iMonth + 1, :) == 0) & ~isExpansion(iMonth, :);
        
        % Update expansion state for next month
        isExpansion(iMonth + 1, :) = isExpansion(iMonth, :) + newExpansion - newRecession(iMonth, :);
    end
    
    % Count number of recessions detected by each classifier
    nRecession = sum(newRecession, 1);
    
    % Identify classifiers that detected exactly nNber recessions
    indexNew = find(nRecession == nNber);
    thresholdNew = repmat(threshold, 1, numel(indexNew));
    
    % Add new perfect indicators to collection
    indexPerfect = [indexPerfect, indexNew];
    thresholdPerfect = [thresholdPerfect, thresholdNew];
    
    % Collect recession start dates for new perfect indicators
    if ~isempty(indexNew)
        % Find all detected recession start dates for these indicators
        [rows, cols] = find(newRecession(:, indexNew));
        
        % Organize dates by classifier (each column = one classifier)
        dateNew = reshape(rows, nNber, []);
        
        % Add to collection
        datePerfect = [datePerfect, dateNew];
    end
end

% Convert month indices to actual dates in decimal year format
startPerfect = timelineTraining(1 + datePerfect);

end