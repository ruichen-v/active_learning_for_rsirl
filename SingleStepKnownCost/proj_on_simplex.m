% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

function [phi, phi_norm, angle] = proj_on_simplex(g, L)

% global par;

% unit normal of simplex plane
n = ones(L, 1); n = n./norm(n);

% x=-1, y=1, other = 0, normalize
m = [-1; 1; zeros(L-2, 1)];
m = m./norm(m);
% mp: perpendicular to m, on simplex
mp = [-1; -1; zeros(L-2, 1)];
mp = mp - (mp'*n)*n;
mp = mp./norm(mp);

phi = g - (g'*n)*n;

if norm(phi) <= 1e-4
    fprintf('g parallel to n with projection length %.5f\n', norm(phi));
    angle = '?'; phi_norm = [0;0;0];
    return;
end

cos_alpha = g'*m/norm(phi);
angle = acos(cos_alpha)/pi*180;

if g'*mp < 0
    angle = -angle; % (-pi, pi]
end

phi_norm = phi./norm(phi);

end

