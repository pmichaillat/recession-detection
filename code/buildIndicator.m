% buildIndicator - Construct recession indicators from raw economic data
%
% Syntax:
%   [dataIndicator, dataParameters] = buildIndicator(rawData, procyclical)
%
% Description:
% This function transforms raw economic time series data into recession indicators
% by applying multiple smoothing methods, curvature transformations, and turning
% point detection algorithms. It generates a comprehensive set of indicator
% variations for model evaluation.
%
% Input arguments:
% * rawData - column vector, raw monthly time series data
% * procyclical - scalar (0 or 1), indicates series behavior:
%   0 = countercyclical (increases in recessions, e.g., unemployment)
%   1 = procyclical (decreases in recessions, e.g., vacancy)
%
% Output arguments:
% * dataIndicator - matrix [nMonth x nIndicators], all indicator variations
% * dataParameters - cell array [4 x nIndicators], transformation parameters with rows:
%   (1) smoothing method, (2) smoothing parameter, (3) curving parameter, (4) turning parameter
%
% Notes:
% * Smoothing methods: Simple moving average (SMA) with windows 0-11 months,
%   and exponential moving average (EMA) with weights 0.1-1.0
% * Curvature transformation: Box-Cox-like transformation with parameter 0-1
%   (0 = log, 1 = linear)
% * Turning point detection: Difference from recent minimum (countercyclical)
%   or maximum (procyclical) over windows of 1–18 months
% * Total indicators per raw series: 22 smoothing × 11 curving × 18 turning = 4,356
%
% Example:
%   [indicators, parameters] = buildIndicator(unemploymentRate, 0);

function [dataIndicator, dataParameters] = buildIndicator(rawData, procyclical)

%% Validate input arguments
% Check that procyclical is either 0 or 1
assert(ismember(procyclical, [0, 1]), 'procyclical must be 0 (countercyclical) or 1 (procyclical)');

% Compute number of monthly observations
nMonth = numel(rawData);

%% Smooth data with simple moving average
% Set parameters: backward-looking windows from 0 to 11 months
alphaMat = [0 : 1 : 11];
nAlpha = numel(alphaMat);

% Preallocate array for smoothed data
dataSma = zeros(nMonth, nAlpha);

% Apply SMA with different window sizes
for iAlpha = 1 : nAlpha
	alpha = alphaMat(iAlpha);
	% Backward-looking moving average (current month and alpha previous months)
	dataSma(:, iAlpha) = movmean(rawData, [alpha, 0]);
end

% Create tags for smoothing method and parameters
smaMethod = repmat({'SMA'}, 1, nAlpha);
smaParameter = alphaMat;

%% Smooth data with exponentially weighted moving average
% Set parameters: decay weights from 0.1 to 1.0
betaMat = [0.1 : 0.1 : 1];
nBeta = numel(betaMat);

% Preallocate array for smoothed data
dataEma = zeros(nMonth, nBeta);

% Apply EMA with different decay weights
for iBeta = 1 : nBeta
	beta = betaMat(iBeta);
	% Exponential filter: y[t] = beta*x[t] + (1-beta)*y[t-1]
	dataEma(:, iBeta) = filter(beta, [1, -(1 - beta)], rawData, rawData(1)*(1 - beta));
end

% Create tags for smoothing method and parameters
emaMethod = repmat({'EMA'}, 1, nBeta);
emaParameter = betaMat;

%% Stack smoothing results and tags
dataSmooth = [dataSma, dataEma];
smoothingMethod = [smaMethod, emaMethod];
smoothingParameter = [smaParameter, emaParameter];

%% Adjust curvature of time series from linear to logarithmic
% Define Box-Cox-like curving transformation
function y = curving(x, k)
	if k == 0
		y = log(x);
	elseif k > 0
		y = (x.^k - 1) ./ k;	
	end 
end	

% Set parameters: curvature from 0 (log) to 1 (linear)
gammaMat = [0 : 0.1 : 1];
nGamma = numel(gammaMat);

% Preallocate array for curved data
dataCurved = zeros(nMonth, nAlpha + nBeta, nGamma);

% Apply curvature transformations
for iGamma = 1 : nGamma
	gamma = gammaMat(iGamma);
	dataCurved(:, :, iGamma) = curving(dataSmooth, gamma);
end

% Create and expand tags for curvature parameters
gammaMat = reshape(gammaMat, [1, 1, nGamma]);
curvingParameter = repmat(gammaMat, 1, nAlpha + nBeta);

% Expand smoothing tags to match new dimensions
smoothingMethod = repmat(smoothingMethod, 1, 1, nGamma);
smoothingParameter = repmat(smoothingParameter, 1, 1, nGamma);

%% Detect turning points
% Set parameters: detection windows from 1 to 18 months
deltaMat = [1 : 18];
nDelta = numel(deltaMat);

% Preallocate array for indicators
dataIndicator = zeros(nMonth, nAlpha + nBeta, nGamma, nDelta);

% Compute indicators based on series type
for iDelta = 1 : nDelta
	delta = deltaMat(iDelta);
	if procyclical == 0
		% Countercyclical series (e.g., unemployment): distance from recent minimum
		% Higher values signal recession (series has increased from recent low)
		dataIndicator(:, :, :, iDelta) = dataCurved - movmin(dataCurved, [delta, 0]);
	elseif procyclical == 1
		% Procyclical series (e.g., vacancy): distance from recent maximum
		% Higher values signal recession (series has decreased from recent high)
		dataIndicator(:, :, :, iDelta) = movmax(dataCurved, [delta, 0]) - dataCurved;
	end
end

% Create and expand tags for turning point parameters
deltaMat = reshape(deltaMat, [1, 1, 1, nDelta]);
turningParameter = repmat(deltaMat, 1, nAlpha + nBeta, nGamma);

% Expand all tags to match final dimensions
smoothingMethod = repmat(smoothingMethod, 1, 1, 1, nDelta);
smoothingParameter = repmat(smoothingParameter, 1, 1, 1, nDelta);
curvingParameter = repmat(curvingParameter, 1, 1, 1, nDelta);

%% Flatten matrices for output
% Convert 4D arrays to 2D matrices (nMonth × nIndicators for data, 1 × nIndicators for parameters)
dataIndicator = flatten(dataIndicator);
smoothingMethod = flatten(smoothingMethod);
smoothingParameter = flatten(smoothingParameter);
curvingParameter = flatten(curvingParameter);
turningParameter = flatten(turningParameter);

% Create cell array with all parameters
dataParameters = [smoothingMethod;
                  num2cell(smoothingParameter);
                  num2cell(curvingParameter);
                  num2cell(turningParameter)];

end