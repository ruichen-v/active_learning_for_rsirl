% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

function [x_next, w] = env(x, u, verbose, j)
global par;
global expr;
% global util;

if ~exist('verbose', 'var')
    verbose = true;
end

if ~exist('j', 'var')
    j = randi(par.L);
    if verbose
        fprintf('--- Use standard disturbance %d.\n', j);
    end
else
    if verbose
        fprintf('+++ Use active disturbance %d.\n', j);
    end
end
A = expr.fparam.Aw{j};
B = expr.fparam.Bw{j};
x_next = A*x + B*u;
x_next = x_next / norm(x_next);

w = j;

end

