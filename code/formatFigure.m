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
% * Axis configurations (dataAxis)
%
% Output:
% * format - structure containing all formatting properties for plotting functions
%
% Notes:
% * This script should be run before creating any figures
% * The predefined cell arrays can be applied using plot(..., format.property{:})
% * Axis properties assume beginDate and endDate are defined

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
	'XTick', [1930 : 10 : 2020]
};

%% Predefine recession dates
[startNber, endNber] = getNber(inputFolder, beginDate, endDate);

%% Package all formatting properties into a structure
format.orange = orange;
format.purple = purple;
format.pink = pink;
format.purpleStandard = purpleStandard;
format.purpleLight = purpleLight;
format.purpleMedium = purpleMedium;
format.pinkLight = pinkLight;
format.pinkMedium = pinkMedium;
format.grayLight = grayLight;
format.grayMedium = grayMedium;
format.grayDark = grayDark;
format.thick = thick;
format.medium = medium;
format.thin = thin;
format.hair = hair;
format.transparency = transparency;
format.diameter = diameter;
format.grayArea = grayArea;
format.orangeLine = orangeLine;
format.orangeMediumLine = orangeMediumLine;
format.orangeThinLine = orangeThinLine;
format.orangeDashLine = orangeDashLine;
format.orangeDashMediumLine = orangeDashMediumLine;
format.purpleLine = purpleLine;
format.purpleMediumLine = purpleMediumLine;
format.purpleThinLine = purpleThinLine;
format.pinkLine = pinkLine;
format.pinkMediumLine = pinkMediumLine;
format.pinkThinLine = pinkThinLine;
format.orangeScatter = orangeScatter;
format.purpleScatter = purpleScatter;
format.purpleOpaqueBand = purpleOpaqueBand;
format.purpleBand = purpleBand;
format.purpleTransparentBand = purpleTransparentBand;
format.orangeOpaqueBand = orangeOpaqueBand;
format.orangeBand = orangeBand;
format.orangeTransparentBand = orangeTransparentBand;
format.grayBand = grayBand;
format.dataAxis = dataAxis;
format.startNber = startNber;
format.endNber = endNber;