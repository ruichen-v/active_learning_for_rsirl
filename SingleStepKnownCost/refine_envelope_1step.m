% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

function [P_V_next, tau_prime, refined, msg] = refine_envelope_1step(...
    g_star, dg_du_star, P_V_d, J_stat, tau_star)
global par;
% global expr;
% global util;
% g_star: g(x*, u*)
% dg_du_star: dg*/du | (x*, u*), numerator layout
% PolyParam_d: current Polyhedron A,b (before &simplex)
% J: indicator of limit reaching condition (+1: upper, -1: lower, 0: none)
% L: # of disturbance realizations

% returns polytope params for new envolope

assert(length(g_star) == par.L);
assert(length(J_stat) == par.u_dim);

yalmip('clear');

%%
v = sdpvar(par.L,1);
% cost_star = sdpvar(L,1);
% grad_coststar_u = sdpvar(L, u_dim);

% slack = sdpvar(par.u_dim, 1);

%% Constraints
% Constr = [sum(v) == 1; v >= 0; slack >= 0];
Constr = [sum(v) == 1; v >= 0;];

for j = 1:par.u_dim
    switch (J_stat(j))
        case 1
            Constr = [Constr; dg_du_star(:, j)'*v <= 0];
        case -1
            Constr = [Constr; dg_du_star(:, j)'*v >= 0];
        case 0
            Constr = [Constr; -1e-3 <= dg_du_star(:, j)'*v <= 1e-3];
        otherwise
            assert(false);
    end
end

% ADD poly_d bootstrap constr
P_d = constructP(P_V_d);
if ~isempty(P_V_d)
    Constr = [Constr; P_d.A*v <= P_d.b];
end

%% Problem
% Objective = -g_star'*v + sum(slack);
Objective = -g_star'*v;
diagnostics = optimize(Constr, Objective, sdpsettings(...
                                                    'solver', 'mosek', ...
                                                    'verbose', 0));
tau_prime = g_star'*value(v);

% slack_val = value(slack);

vsimplex = [1,1,1];
costheta = vsimplex*g_star/(norm(vsimplex)*norm(g_star));
assert(costheta <= 1+1e-10 && costheta >= -1-1e-10);

refined = true;
fprintf('tau_prime: %.4f, tau_star: %.4f\n', tau_prime, tau_star);
if costheta > 1-1e-5 || costheta < -1+1e-5
    msg = sprintf('[FAIL] Hyperplane parallel to simplex, angle %.5f.\n', acos(costheta)/pi*180);
    P_V_next = P_V_d;
    refined = false;
elseif diagnostics.problem ~= 0
    msg = sprintf('[FAIL] Optimization fail: %s.\n', diagnostics.info);
    P_V_next = P_V_d;
    refined = false;
elseif tau_prime <= tau_star - 0.01
    msg = sprintf('[FAIL] tau_prime smaller than tau_star by %.4f\n', ...
                tau_star - tau_prime);
    P_V_next = P_V_d;
    refined = false;
else
    P_d_next = P_d & Polyhedron('A', g_star', 'b', tau_prime);
    try
        P_d_next = P_d_next.minVRep().minHRep();

        P_V_next = suppressV(P_d_next.V);
    catch
        P_V_next = P_V_d;
    end
    msg = sprintf('[SUCCEED] Refined.\n');
    refined = true;
    
%     P_simp = Polyhedron('V', eye(par.L));
%     P_pos = Polyhedron('A', [-1 0 0;0 -1 0; 0 0 -1],'b',[0;0;0]);

%     figure; hold on;

%     P_simp.plot('color','b', 'alpha', 0.3);
    % P_pos.plot('color','g', 'alpha', 0.0);

%     P_new = P_pos & Polyhedron('A', g_star', 'b', tau_prime); g_star
%     P_new.plot('color','y', 'alpha', 0.1);
%     axis equal;
    
end

