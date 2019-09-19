% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

function [ustar, tau_star, v_star] = expert(x)
% Expert generates action

global par;
global expr;

yalmip('clear');

par.u_dim = size(par.u_limit, 1);
tau = sdpvar(1,1);
u = sdpvar(par.u_dim, 1);

Constr = [par.u_limit(:,1) <= u <= par.u_limit(:,2)];
V = expr.P_gt.V;
g = cost(x, u, expr.fparam, expr.Cparam, par.L);

for i = 1:size(V,1)
    v = V(i, :)';
    Constr = [Constr; tau >= g'*v];
end

Objective = tau;
diagnostics = optimize(Constr, Objective, sdpsettings( ...
                        'solver', 'mosek', ...
                        'verbose', 0));

ustar = value(u);
tau_star = value(tau);

crm_at_vertices = V*value(g);
optim_vertex = find(crm_at_vertices == max(crm_at_vertices));
v_star = V(optim_vertex(1), :)';

end

