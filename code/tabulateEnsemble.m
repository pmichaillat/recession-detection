% tabulateEnsemble - Create and save table of ensemble classifier parameters and errors
%
% Syntax:
%   tabulateEnsemble(parametersEnsemble, thresholdEnsemble, errorsEnsemble, tableId, outputFolder)
%
% Description:
% This function creates a formatted table containing the parameters and detection
% errors for ensemble classifiers, displays it in the command window, and saves
% it as a CSV file. The table includes all transformation parameters (smoothing,
% curving, turning, mixing) along with threshold values and error statistics.
%
% Input arguments:
% * parametersEnsemble - cell array [6 x nEnsemble], classifier parameters with rows:
%   (1) smoothing method, (2) smoothing parameter, (3) curving parameter,
%   (4) turning parameter, (5) mixing method, (6) mixing parameter
% * thresholdEnsemble - row vector [1 x nEnsemble], threshold values for each classifier
% * errorsEnsemble - matrix [4 x nEnsemble], detection errors in months with rows:
%   (1) standard deviation, (2) mean error, (3) minimum error, (4) maximum error
% * tableId - string or char, identifier for table naming (e.g., 'Ensemble')
% * outputFolder - string or char, path to output folder
%
% Output:
% * table[tableId].csv - CSV file containing classifier parameters and errors
%
% Notes:
% * Each row in the output table represents one classifier from the ensemble
% * Cell array and numeric data are combined into a single table automatically
% * Table is both displayed in command window and saved to CSV
% * Errors are measured in months
%
% Example:
%   tabulateEnsemble(params, thresholds, errors, 'Ensemble', './output');

function tabulateEnsemble(parametersEnsemble, thresholdEnsemble, errorsEnsemble, tableId, outputFolder)

% Define table column headers
header = {'Smoothing method', 'Smoothing parameter', 'Curving parameter', 'Turning parameter', 'Mixing method', 'Mixing parameter', 'Threshold', 'Standard error', 'Mean error', 'Min error', 'Max error'};

% Extract individual columns from cell array (6 rows → 6 columns when transposed)
smoothingMethod = parametersEnsemble(1, :)';
smoothingParam = cell2mat(parametersEnsemble(2, :))';
curvingParam = cell2mat(parametersEnsemble(3, :))';
turningParam = cell2mat(parametersEnsemble(4, :))';
mixingMethod = parametersEnsemble(5, :)';
mixingParam = cell2mat(parametersEnsemble(6, :))';

% Extract individual columns from numeric arrays
threshold = thresholdEnsemble';
stdError = errorsEnsemble(1, :)';
meanError = errorsEnsemble(2, :)';
minError = errorsEnsemble(3, :)';
maxError = errorsEnsemble(4, :)';

% Create table from individual columns (handles mixed cell and numeric types)
tbl = table(smoothingMethod, smoothingParam, curvingParam, turningParam, mixingMethod, mixingParam, threshold, stdError, meanError, minError, maxError, 'VariableNames', header);

% Display table in command window with formatted header
fprintf('\nTable %s\n---------------------------------\n\n', tableId)
disp(tbl)

% Save table as CSV file (overwrite if exists)
writetable(tbl, fullfile(outputFolder, ['table_', tableId, '.csv']), 'WriteMode', 'overwrite')

end