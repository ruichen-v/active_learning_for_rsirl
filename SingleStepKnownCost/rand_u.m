% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

function u = rand_u(u_limit)
% global par;
    u_dim = size(u_limit, 1);
    u = u_limit(:, 1) + ...
        rand(u_dim, 1) .* (u_limit(:, 2)-u_limit(:, 1));
end

