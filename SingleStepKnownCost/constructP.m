% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

function P = constructP(V)
global par;
    P_simp = Polyhedron('V', eye(par.L));
    if ~isempty(V)
        P_tmp = Polyhedron('V', V);
        P = P_simp & Polyhedron('A', P_tmp.A, 'b', P_tmp.b);
    else
        P = P_simp;
    end
end

