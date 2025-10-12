% flatten - Reshape array into 2D matrix with original first dimension preserved
%
% Syntax:
%   y = flatten(x)
%
% Description:
% This function reshapes a multidimensional array into a 2D matrix where the first dimension is preserved and all other dimensions are collapsed into the second dimension.
%
% Input arguments:
% * x - numeric array of any dimensionality
%
% Output arguments:
% * y - 2D matrix with size [size(x,1), prod(size(x,2:end))]
%
% Notes:
% * The first dimension size is always preserved
% * All trailing dimensions are flattened into a single dimension
% * For a 3D array of size [m,n,p], output will be [m, n*p]
%
% Example:
%   x = rand(3, 4, 5);
%   y = flatten(x);  % y will be 3-by-20

function y = flatten(x)

% Reshape array to preserve first dimension and flatten all others
y = reshape(x, size(x, 1), []);

end