% mixIndicator - Combine two sets of indicators using linear and minmax mixing
%
% Syntax:
%   [indicator, tagSmoothingMethod, tagSmoothingParameter, tagCurvingParameter, tagTurningParameter, tagMixingMethod, tagMixingParameter] = mixIndicator(indicator1, indicator2, tagSmoothingMethod, tagSmoothingParameter, tagCurvingParameter, tagTurningParameter)
%
% Description:
% This function combines two sets of indicators (e.g., from unemployment and
% vacancy rates) using linear convex combinations and minmax mixing. It creates
% multiple mixed indicators by varying the mixing parameter from 0 to 1.
%
% Input arguments:
% * indicator1 - matrix [nMonth x nIndicators], first set of indicators
% * indicator2 - matrix [nMonth x nIndicators], second set of indicators
% * tagSmoothingMethod - cell array, smoothing method labels from buildIndicator
% * tagSmoothingParameter - matrix, smoothing parameters from buildIndicator
% * tagCurvingParameter - matrix, curvature parameters from buildIndicator
% * tagTurningParameter - matrix, turning point parameters from buildIndicator
%
% Output arguments:
% * indicator - matrix [nMonth x nMixedIndicators], all mixed indicator variations
% * tagSmoothingMethod - cell array, expanded smoothing method labels
% * tagSmoothingParameter - matrix, expanded smoothing parameters
% * tagCurvingParameter - matrix, expanded curvature parameters
% * tagTurningParameter - matrix, expanded turning point parameters
% * tagMixingMethod - cell array, mixing method labels ('linear' or 'minmax')
% * tagMixingParameter - matrix, mixing weight parameters (0 to 1)
%
% Notes:
% * Linear mixing: z = zeta*x + (1-zeta)*y (convex combination)
% * Minmax mixing: z = zeta*min(x,y) + (1-zeta)*max(x,y) (robust to outliers)
% * Mixing parameter zeta ranges from 0 to 1 in steps of 0.1 (11 values)
% * Total output: 2 mixing methods × 11 parameters × nIndicators per input
% * Both input indicator sets must have the same dimensions
%
% Example:
%   [mixed, sm, sp, cp, tp, mm, mp] = mixIndicator(uIndicators, vIndicators, sm, sp, cp, tp);

function [indicator, tagSmoothingMethod, tagSmoothingParameter, tagCurvingParameter, tagTurningParameter, tagMixingMethod, tagMixingParameter] = mixIndicator(indicator1, indicator2, tagSmoothingMethod, tagSmoothingParameter, tagCurvingParameter, tagTurningParameter)

%% Produce linear and minmax mixtures of indicators
% Define minmax mixing function
% Combines minimum and maximum of two series with weight parameter
function z = mixing(x, y, k)
	z = k .* min(x, y) + (1 - k) .* max(x, y);
end	

% Set parameters: mixing weights from 0 to 1
zetaMat = [0 : 0.1 : 1];
nZeta = numel(zetaMat);
nIndicator = size(indicator1, 2);

% Get number of months from indicator data
nMonth = size(indicator1, 1);

% Preallocate arrays for mixed indicators
linearIndicator = zeros(nMonth, nIndicator, nZeta);
minmaxIndicator = zeros(nMonth, nIndicator, nZeta);

% Apply both mixing methods for all parameter values
for iZeta = 1 : nZeta
	zeta = zetaMat(iZeta);
	% Linear convex combination: weighted average of two indicators
	linearIndicator(:, :, iZeta) = zeta .* indicator1 + (1 - zeta) .* indicator2;
	% Minmax combination: weighted combination of min and max values
	minmaxIndicator(:, :, iZeta) = mixing(indicator1, indicator2, zeta);
end

% Create tags for mixing methods and parameters
zetaMat = reshape(zetaMat, [1, 1, nZeta]);
tagLinear = repmat({'linear'}, nMonth, nIndicator, nZeta);
tagMinmax = repmat({'minmax'}, nMonth, nIndicator, nZeta);
tagLinearParameter = repmat(zetaMat, nMonth, nIndicator);
tagMinmaxParameter = repmat(zetaMat, nMonth, nIndicator);

% Expand existing tags to match new dimensions
tagSmoothingMethod = repmat(tagSmoothingMethod, 1, 1, nZeta);
tagSmoothingParameter = repmat(tagSmoothingParameter, 1, 1, nZeta);
tagCurvingParameter = repmat(tagCurvingParameter, 1, 1, nZeta);
tagTurningParameter = repmat(tagTurningParameter, 1, 1, nZeta);

%% Flatten matrices before stacking
% Flatten indicator results
linearIndicator = flatten(linearIndicator);
minmaxIndicator = flatten(minmaxIndicator);

% Flatten all tags
tagSmoothingMethod = flatten(tagSmoothingMethod);
tagSmoothingParameter = flatten(tagSmoothingParameter);
tagCurvingParameter = flatten(tagCurvingParameter);
tagTurningParameter = flatten(tagTurningParameter);
tagLinear = flatten(tagLinear);
tagLinearParameter = flatten(tagLinearParameter);
tagMinmax = flatten(tagMinmax);
tagMinmaxParameter = flatten(tagMinmaxParameter);

%% Stack results and tags
% Stack linear and minmax results horizontally
indicator = [linearIndicator, minmaxIndicator];

% Stack mixing method tags
tagMixingMethod = [tagLinear, tagMinmax];
tagMixingParameter = [tagLinearParameter, tagMinmaxParameter];

% Replicate other tags to match doubled column count
tagSmoothingMethod = repmat(tagSmoothingMethod, 1, 2);
tagSmoothingParameter = repmat(tagSmoothingParameter, 1, 2);
tagCurvingParameter = repmat(tagCurvingParameter, 1, 2);
tagTurningParameter = repmat(tagTurningParameter, 1, 2);

end