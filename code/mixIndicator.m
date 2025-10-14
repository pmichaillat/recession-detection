% mixIndicator - Combine two sets of indicators using linear and minmax mixing
%
% Syntax:
%   [indicator, parameters] = mixIndicator(indicator1, indicator2, dataParameters)
%
% Description:
% This function combines two sets of indicators (e.g., from unemployment and
% vacancy rates) using linear convex combinations and minmax mixing. It creates
% multiple mixed indicators by varying the mixing parameter from 0 to 1.
%
% Input arguments:
% * indicator1 - matrix [nMonth x nIndicators], first set of indicators
% * indicator2 - matrix [nMonth x nIndicators], second set of indicators
% * dataParameters - cell array [4 x nIndicators], transformation parameters from buildIndicator
%
% Output arguments:
% * indicator - matrix [nMonth x nMixedIndicators], all mixed indicator variations
% * parameters - cell array [6 x nMixedIndicators], all transformation parameters with rows:
%   (1) smoothing method, (2) smoothing parameter, (3) curving parameter,
%   (4) turning parameter, (5) mixing method, (6) mixing parameter
%
% Notes:
% * Linear mixing: z = zeta*x + (1-zeta)*y (convex combination)
% * Minmax mixing: z = zeta*min(x,y) + (1-zeta)*max(x,y) (robust to outliers)
% * Mixing parameter zeta ranges from 0 to 1 in steps of 0.1 (11 values)
% * Total output: 2 mixing methods × 11 parameters × nIndicators = 22 × nIndicators
% * Both input indicator sets must have the same dimensions
%
% Example:
%   [mixed, params] = mixIndicator(uIndicator, vIndicator, uParams);

function [indicator, parameters] = mixIndicator(indicator1, indicator2, dataParameters)

%% Check arguments to the function

% Verify that indicators have same size
assert(isequal(size(indicator1), size(indicator2)), 'Indicator matrices must have the same size');

% Verify that parameterization is correct
assert(isequal(size(indicator1, 2), size(dataParameters, 2)), 'Indicator matrix and parameter matrix must have the same number of columns');

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

% Create mixing parameter tags
mixingParameter = repmat(reshape(zetaMat, [1, 1, nZeta]), 1, nIndicator);

% Create mixing method tags
linearMethod = repmat({'linear'}, 1, nIndicator, nZeta);
minmaxMethod = repmat({'minmax'}, 1, nIndicator, nZeta);

% Expand existing parameters to match mixing dimension
dataParameters = repmat(dataParameters, 1, 1, nZeta);

%% Flatten matrices before stacking
% Flatten indicator results
linearIndicator = flatten(linearIndicator);
minmaxIndicator = flatten(minmaxIndicator);

% Flatten parameter tags
linearMethod = flatten(linearMethod);
minmaxMethod = flatten(minmaxMethod);
mixingParameter = flatten(mixingParameter);
dataParameters = flatten(dataParameters);

%% Stack results and parameters
% Stack linear and minmax results horizontally
indicator = [linearIndicator, minmaxIndicator];

% Stack mixing method tags
mixingMethod = [linearMethod, minmaxMethod];

% Replicate other parameters to match doubled column count
dataParameters = repmat(dataParameters, 1, 2);
mixingParameter = repmat(mixingParameter, 1, 2);

% Create cell array with all parameters
parameters = [dataParameters;
              mixingMethod;
              num2cell(mixingParameter)];

end