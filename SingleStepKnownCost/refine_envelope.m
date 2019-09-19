% Copyright (c) 2019 Rui Chen
%
% This work is licensed under the terms of the MIT license.
% For a copy, see <https://opensource.org/licenses/MIT>.

function [V_next, V_list, tau_prime_list, refined, msg] =  refine_envelope(...
                            x_exp, u_exp, V, ...
                            V_list, tau_prime_list, t, ...
                            vstar_list, taustar_list, ax)
    global par;
    global expr;
    
    % g(x*, u*)
    g_star = cost(x_exp, u_exp, expr.fparam, expr.Cparam, par.L);
    % dg_du(x*, u*)
    dg_du_star = dcost_du(u_exp, x_exp, expr.fparam, expr.Cparam, par.L);
    % J+/-
    J_stat = zeros(par.u_dim, 1);
    J_stat(abs(u_exp - par.u_limit(:, 1)) <= 1e-5) = par.J_lower;
    J_stat(abs(u_exp - par.u_limit(:, 2)) <= 1e-5) = par.J_upper;

    fprintf('\n\n================ Iteration %d ================\n', t);
    [V_next, tau_prime, refined, msg] = refine_envelope_1step(...
        g_star, dg_du_star, V, J_stat, taustar_list(t));
    
    visualize(V_next, ax, t, g_star, tau_prime, refined);

    fprintf('V: %.4f, %.4f,%.4f\n', ...
            vstar_list(1, t), vstar_list(2, t), vstar_list(3, t));
    
    V_list{end+1} = V_next;
    tau_prime_list = [tau_prime_list, tau_prime]; 
end