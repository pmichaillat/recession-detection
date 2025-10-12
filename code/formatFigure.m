% formatFigure.m - Set default figure properties and define plotting styles
%
% Description:
% This script configures default MATLAB figure and axes properties for consistent formatting across all plots. It also predefines color palettes, line widths, and plotting style properties for reuse in visualizations.
%
% Default figure properties:
% * Figure size: 10 x 5.625 inches (16:9 aspect ratio)
% * Font: Helvetica, 18pt
% * Renderer: painters (for vector graphics)
% * Grid: Y-axis only
% * Tick marks: outward facing
%
% Predefined variables:
% * Color palette (orange, purple, pink, gray variants)
% * Line widths (thick, medium, thin, hair)
% * Transparency levels
% * Marker sizes
% * Line, scatter, band, and area plot properties
% * Axis configurations (dataAxis, trainingAxis, detectionAxis)
%
% Notes:
% * This script should be run before creating any figures
% * The predefined cell arrays can be applied using plot(..., property{:})
% * Axis properties assume startDate, endDate, and endTraining are defined

%% Set default properties for figures
% Define figure dimensions in inches (16:9 aspect ratio)
widthFigure = 10;
heightFigure = 5.625;

% Configure default figure and axes properties
set(groot, ...
	'defaultFigureRenderer', 'painters', ...
	'defaultFigureUnits', 'inches', ...
	'defaultFigurePosition', [1, 1, widthFigure, heightFigure], ...
	'defaultFigurePaperPosition', [0, 0, widthFigure, heightFigure], ...
	'defaultFigurePaperSize', [widthFigure, heightFigure], ...
	'defaultAxesFontName', 'Helvetica', ...
	'defaultAxesFontSize', 18, ...
	'defaultAxesLabelFontSizeMultiplier', 1, ...
	'defaultAxesTitleFontSizeMultiplier', 1, ...
	'defaultAxesTitleFontWeight', 'normal', ...
	'defaultAxesXColor', 'black', ...
	'defaultAxesYColor', 'black', ...
	'defaultAxesGridColor', 'black', ...
	'defaultAxesLineWidth', 0.9, ...
	'defaultAxesYGrid', 'on', ...
	'defaultAxesXGrid', 'off', ...
	'defaultAxesTickDirMode', 'manual', ...
	'defaultAxesTickDir', 'out', ...
	'defaultAxesTickLength', [0.005, 0.005], ...
	'defaultAxesMinorGridLineStyle', 'none'...
);	

%% Predefine color palette
% Primary colors
orange = '#d95f02';
purple = '#59539d';
pink = '#e7298a';

% Purple variants
purpleStandard = '#7570b3';
purpleLight = '#bcbddc';
purpleMedium = '#9e9ac8';

% Pink variants
pinkLight = '#c994c7';
pinkMedium = '#df65b0';

% Gray variants
grayLight = '#bdbdbd';
grayMedium = '#737373';
grayDark = '#252525';

%% Predefine line widths
thick = 2.7;
medium = thick ./ 2;
thin = thick ./ 3;
hair = thick ./ 4;

%% Predefine face transparency
transparency = 0.3;

%% Predefine size of markers
diameter = 9;

%% Predefine area properties
% Shaded area for recessions or highlighting
grayArea = {
	'FaceColor', 'black', ...
	'LineStyle', 'none', ...
	'FaceAlpha', 0.2
};

%% Predefine line properties
% Orange lines
orangeLine = {
	'Color', orange, ...
	'LineWidth', thick
};
orangeMediumLine = {
	'Color', orange, ...
	'LineWidth', medium
};
orangeThinLine = {
	'Color', orange, ...
	'LineWidth', thin
};
orangeDashLine = {
	'Color', orange, ...
	'LineWidth', thick, ...
	'LineStyle', '-.'
};
orangeDashMediumLine = {
	'Color', orange, ...
	'LineWidth', medium, ...
	'LineStyle', '-.'
};

% Purple lines
purpleLine = {
	'Color', purple, ...
	'LineWidth', thick
};
purpleMediumLine = {
	'Color', purple, ...
	'LineWidth', medium
};
purpleThinLine = {
	'Color', purple, ...
	'LineWidth', thin
};

% Pink lines
pinkLine = {
	'Color', pink, ...
	'LineWidth', thick
};
pinkMediumLine = {
	'Color', pink, ...
	'LineWidth', medium
};
pinkThinLine = {
	'Color', pink, ...
	'LineWidth', thin
};

%% Predefine scatter plot properties
orangeScatter = {
	'Color', pink, ...
	'MarkerSize', 7, ...
	'MarkerFaceColor', orange, ...
	'LineStyle', '-', ...
	'LineWidth', medium, ...
	'Marker', 'o'
};
purpleScatter = {
	'Color', pink, ...
	'MarkerSize', 7, ...
	'MarkerFaceColor', purple, ...
	'LineStyle', '-', ...
	'LineWidth', medium, ...
	'Marker', 'o'
};

%% Predefine confidence band properties
% Purple bands with varying transparency
purpleOpaqueBand = {
	'Color', [89/255, 83/255, 157/255, 0.2], ...
	'LineWidth', medium
};
purpleBand = {
	'Color', [89/255, 83/255, 157/255, 0.1], ...
	'LineWidth', thin
};
purpleTransparentBand = {
	'Color', [89/255, 83/255, 157/255, 0.05], ...
	'LineWidth', hair
};

% Orange bands with varying transparency
orangeOpaqueBand = {
	'Color', [217/255, 95/255, 2/255, 0.2], ...
	'LineWidth', medium
};
orangeBand = {
	'Color', [217/255, 95/255, 2/255, 0.1], ...
	'LineWidth', thin
};
orangeTransparentBand = {
	'Color', [217/255, 95/255, 2/255, 0.05], ...
	'LineWidth', hair
};

% Gray band
grayBand = {
	'Color', [0.5, 0.5, 0.5, 0.1], ...
	'LineWidth', thin
};

%% Predefine axis properties
% Full data range axis
dataAxis = {
	'XLim', [beginDate, endDate], ...
	'XTick', [1930, 1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010, 2020]
};